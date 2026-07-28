import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('capture stack rotate direction', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: Container(
              width: 300,
              height: 200,
              color: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const SizedBox(width: 300, height: 200),
                  Transform.rotate(
                    angle: -0.5,
                    child: const Text(
                      'CANCELLED',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.red, letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('/tmp/widget_rotate_test.png').writeAsBytes(bytes!.buffer.asUint8List());
  });
}
