import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('compare rotation directions', () async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, 100 * PdfPageFormat.mm),
      build: (context) => pw.Stack(
        children: [
          pw.Positioned(
            top: 10,
            left: 10,
            child: pw.Transform.rotate(
              angle: -0.5,
              child: pw.Text('NEGATIVE (-0.5)', style: pw.TextStyle(fontSize: 14, color: PdfColors.red)),
            ),
          ),
          pw.Positioned(
            top: 60,
            left: 10,
            child: pw.Transform.rotate(
              angle: 0.5,
              child: pw.Text('POSITIVE (0.5)', style: pw.TextStyle(fontSize: 14, color: PdfColors.blue)),
            ),
          ),
        ],
      ),
    ));
    await File('/tmp/rotate_test.pdf').writeAsBytes(await doc.save());
  });
}
