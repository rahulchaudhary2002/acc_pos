import 'package:flutter/material.dart';

/// A purpose-drawn LPG gas cylinder glyph (cylindrical body, neck, and a
/// carrying-ring handle on top) — replaces `Icons.propane_tank`, which reads
/// as a squarish BBQ propane tank rather than the tall domestic LPG cylinder
/// this app is branded around. Used everywhere that branding icon appears:
/// login screen, every tab's header (mirrors `PosTerminal.jsx`'s single
/// `Fuel` icon shown across all tabs), and product cards.
class GasCylinderIcon extends StatelessWidget {
  final double size;
  final Color color;

  const GasCylinderIcon({super.key, this.size = 24, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GasCylinderPainter(color),
    );
  }
}

class _GasCylinderPainter extends CustomPainter {
  final Color color;

  _GasCylinderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Carrying-ring handle at the very top.
    final ringRect = Rect.fromLTWH(w * 0.32, h * 0.02, w * 0.36, h * 0.20);
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09;
    canvas.drawOval(ringRect, ringPaint);

    // Neck connecting the ring to the body.
    final neckRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.40, h * 0.19, w * 0.20, h * 0.15),
      topLeft: Radius.circular(w * 0.02),
      topRight: Radius.circular(w * 0.02),
    );
    canvas.drawRRect(neckRect, fill);

    // Main cylindrical body.
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.32, w * 0.70, h * 0.58),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(bodyRect, fill);

    // Base ring the cylinder stands on.
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.90, w * 0.80, h * 0.08),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(baseRect, fill);
  }

  @override
  bool shouldRepaint(covariant _GasCylinderPainter oldDelegate) => oldDelegate.color != color;
}
