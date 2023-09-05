import 'package:flutter/material.dart';


class FocusBoxPainter extends CustomPainter {
  final double focusBoxSize;
  final double focusBoxOffset;
  final Color overlayColor;

  FocusBoxPainter({
    required this.focusBoxSize,
    required this.focusBoxOffset,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = (size.height / 2) - focusBoxOffset;

    Rect focusRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: focusBoxSize,
      height: focusBoxSize,
    );

    Rect outerRect = Rect.fromPoints(
      Offset(0, 0),
      Offset(size.width, size.height),
    );

    canvas.drawRect(
      outerRect,
      Paint()
        ..color = overlayColor,
    );

    canvas.drawRect(
      focusRect,
      Paint()
        ..blendMode = BlendMode.clear,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}