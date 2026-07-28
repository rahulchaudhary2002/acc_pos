import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('compare rotation directions centered', () async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat(150 * PdfPageFormat.mm, 200 * PdfPageFormat.mm),
      build: (context) => pw.Column(
        children: [
          pw.Container(
            height: 300,
            child: pw.Center(
              child: pw.Transform.rotate(
                angle: -0.5,
                child: pw.Text('CANCELLED angle=-0.5', style: pw.TextStyle(fontSize: 20, color: PdfColors.red)),
              ),
            ),
          ),
          pw.Container(
            height: 300,
            child: pw.Center(
              child: pw.Transform.rotate(
                angle: 0.5,
                child: pw.Text('CANCELLED angle=0.5', style: pw.TextStyle(fontSize: 20, color: PdfColors.blue)),
              ),
            ),
          ),
        ],
      ),
    ));
    await File('/tmp/rotate_test2.pdf').writeAsBytes(await doc.save());
  });
}
