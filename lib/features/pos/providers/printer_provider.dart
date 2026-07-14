import 'dart:convert';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/thermal_receipt_builder.dart';

const _prefsKey = 'pos_printer_settings';

/// Why a print can fail, kept as a code (not a message) so the UI can map it
/// to a localized string via `AppLocalizations`.
enum PrinterErrorCode { bluetoothOff, permissionDenied, noPrinterSelected, connectionFailed, printFailed }

class PrinterException implements Exception {
  final PrinterErrorCode code;
  const PrinterException(this.code);

  @override
  String toString() => 'PrinterException(${code.name})';
}

/// A Bluetooth thermal printer as listed by the OS (already paired on
/// Android; discovered nearby on iOS).
class PrinterDevice {
  final String name;
  final String mac;

  const PrinterDevice({required this.name, required this.mac});
}

/// Bluetooth thermal-printer connection for direct bill printing (the
/// MYXprint-style flow): the printer chosen in Others → Printer Connection is
/// persisted here and reused by the invoice previews' "Print Bill" action, so
/// the cashier picks it once and every later bill prints in one tap.
///
/// Printing sends native ESC/POS text/column commands (built by
/// `thermal_receipt_builder.dart`) rather than rasterizing the A5 preview
/// PDF — rasterizing squeezed a full page into 58/80mm and came out with
/// tiny, blurry text; native commands render at the printer's own font and
/// size cleanly to whichever paper width is configured.
class PrinterProvider extends ChangeNotifier {
  PrinterDevice? savedPrinter;
  int paperWidthMm = 58; // 58 | 80
  bool isPrinting = false;

  bool get hasSavedPrinter => savedPrinter != null;

  /// Characters per line at the printer's standard font — 32 on 58mm rolls,
  /// 48 on 80mm.
  int get charsPerLine => paperWidthMm == 80 ? 48 : 32;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final name = map['name'] as String?;
        final mac = map['mac'] as String?;
        if (name != null && mac != null) savedPrinter = PrinterDevice(name: name, mac: mac);
        paperWidthMm = map['paperWidthMm'] as int? ?? paperWidthMm;
      } catch (_) {
        // Corrupt/old-shape prefs — fall back to defaults rather than crash.
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({'name': savedPrinter?.name, 'mac': savedPrinter?.mac, 'paperWidthMm': paperWidthMm}),
    );
  }

  Future<void> selectPrinter(PrinterDevice device) async {
    if (savedPrinter?.mac != device.mac && await PrintBluetoothThermal.connectionStatus) {
      await PrintBluetoothThermal.disconnect;
    }
    savedPrinter = device;
    notifyListeners();
    await _persist();
  }

  Future<void> forgetPrinter() async {
    if (await PrintBluetoothThermal.connectionStatus) await PrintBluetoothThermal.disconnect;
    savedPrinter = null;
    notifyListeners();
    await _persist();
  }

  Future<void> setPaperWidth(int mm) async {
    paperWidthMm = mm;
    notifyListeners();
    await _persist();
  }

  /// Paired (Android) / nearby (iOS) Bluetooth printers for the picker sheet.
  Future<List<PrinterDevice>> scanDevices() async {
    if (!await _ensurePermissions()) throw const PrinterException(PrinterErrorCode.permissionDenied);
    if (!await PrintBluetoothThermal.bluetoothEnabled) throw const PrinterException(PrinterErrorCode.bluetoothOff);
    final paired = await PrintBluetoothThermal.pairedBluetooths;
    return paired.map((b) => PrinterDevice(name: b.name, mac: b.macAdress)).toList();
  }

  Future<bool> _ensurePermissions() async {
    if (await PrintBluetoothThermal.isPermissionBluetoothGranted) return true;
    // Android 12+ runtime permissions (map to the single Bluetooth permission
    // on iOS); on older Androids permission_handler reports them granted.
    final statuses = await [Permission.bluetoothConnect, Permission.bluetoothScan].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> _connect() async {
    final printer = savedPrinter;
    if (printer == null) throw const PrinterException(PrinterErrorCode.noPrinterSelected);
    if (await PrintBluetoothThermal.connectionStatus) return;
    if (!await _ensurePermissions()) throw const PrinterException(PrinterErrorCode.permissionDenied);
    if (!await PrintBluetoothThermal.bluetoothEnabled) throw const PrinterException(PrinterErrorCode.bluetoothOff);
    if (!await PrintBluetoothThermal.connect(macPrinterAddress: printer.mac)) {
      throw const PrinterException(PrinterErrorCode.connectionFailed);
    }
  }

  /// Prints the invoice on the saved printer. Throws [PrinterException].
  Future<void> printReceipt(ThermalReceiptData data) async {
    if (isPrinting) return;
    isPrinting = true;
    notifyListeners();
    try {
      await _connect();
      final generator = await _generator();
      final bytes = buildThermalReceiptBytes(generator, data, charsPerLine: charsPerLine);
      if (!await PrintBluetoothThermal.writeBytes(bytes)) {
        throw const PrinterException(PrinterErrorCode.printFailed);
      }
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }

  /// Small text ticket to confirm the configured printer actually prints.
  Future<void> testPrint() async {
    if (isPrinting) return;
    isPrinting = true;
    notifyListeners();
    try {
      await _connect();
      final generator = await _generator();
      var bytes = generator.reset();
      bytes += generator.text(
        'PRINTER TEST',
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
      );
      bytes += generator.text('Annapurna Accounting POS', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Printer connected successfully.', styles: const PosStyles(align: PosAlign.center));
      // Full-width ruler: if this line stops short of the paper edge (or
      // wraps), the Paper Size setting doesn't match the printer.
      bytes += generator.hr(ch: '=', len: charsPerLine);
      bytes += generator.text('Paper: ${paperWidthMm}mm / $charsPerLine chars', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(3);
      bytes += generator.cut();
      if (!await PrintBluetoothThermal.writeBytes(bytes)) {
        throw const PrinterException(PrinterErrorCode.printFailed);
      }
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }

  Future<Generator> _generator() async {
    final profile = await CapabilityProfile.load();
    return Generator(paperWidthMm == 80 ? PaperSize.mm80 : PaperSize.mm58, profile);
  }
}
