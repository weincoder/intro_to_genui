import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class RetroGridPainter extends CustomPainter {
  final double opacity;
  final double gridSpacing;

  const RetroGridPainter({this.opacity = 0.12, this.gridSpacing = 32});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: opacity)
      ..strokeWidth = 0.5;

    final dotPaint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: opacity * 1.5)
      ..style = PaintingStyle.fill;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Intersection dots (PCB style)
    for (double x = 0; x <= size.width; x += gridSpacing) {
      for (double y = 0; y <= size.height; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(RetroGridPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.gridSpacing != gridSpacing;
}
