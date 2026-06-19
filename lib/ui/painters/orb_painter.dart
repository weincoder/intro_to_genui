import 'dart:math' as math;

import 'package:flutter/material.dart';

class OrbConfig {
  final double xFraction;
  final double yFraction;
  final double radiusFraction; // fraction of size.shortestSide
  final double opacity;
  final double floatPhase; // 0..1 phase offset

  const OrbConfig({
    required this.xFraction,
    required this.yFraction,
    required this.radiusFraction,
    required this.opacity,
    this.floatPhase = 0,
  });
}

/// Paints glass-like 3D orbs that float with animation.
/// [animValue] should be a value from 0..1 driven by an AnimationController.
class OrbPainter extends CustomPainter {
  final double animValue;

  static const List<OrbConfig> _configs = [
    OrbConfig(
      xFraction: 0.18,
      yFraction: 0.72,
      radiusFraction: 0.40,
      opacity: 0.92,
      floatPhase: 0.0,
    ),
    OrbConfig(
      xFraction: 0.80,
      yFraction: 0.10,
      radiusFraction: 0.21,
      opacity: 0.80,
      floatPhase: 0.28,
    ),
    OrbConfig(
      xFraction: 0.55,
      yFraction: 0.02,
      radiusFraction: 0.12,
      opacity: 0.65,
      floatPhase: 0.55,
    ),
    OrbConfig(
      xFraction: 0.92,
      yFraction: 0.30,
      radiusFraction: 0.14,
      opacity: 0.60,
      floatPhase: 0.72,
    ),
  ];

  const OrbPainter({this.animValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final baseRadius = size.shortestSide;
    for (final cfg in _configs) {
      // 6 full float cycles during the animation lifecycle
      final floatOffset =
          math.sin((animValue * 6 + cfg.floatPhase) * 2 * math.pi) * 14;
      final center = Offset(
        cfg.xFraction * size.width,
        cfg.yFraction * size.height + floatOffset,
      );
      _drawOrb(canvas, center, cfg.radiusFraction * baseRadius, cfg.opacity);
    }
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, double opacity) {
    // 1. Drop shadow
    canvas.drawCircle(
      center + const Offset(6, 14),
      radius * 0.85,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
        ..color = const Color(0xFF4233CE).withValues(alpha: opacity * 0.28),
    );

    // 2. Main body — dark purple radial gradient (depth illusion)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.95,
          colors: [
            const Color(0xFF6B5BE8).withValues(alpha: opacity),
            const Color(0xFF2E1D9A).withValues(alpha: opacity),
            const Color(0xFF180040).withValues(alpha: opacity * 0.97),
          ],
          stops: const [0.0, 0.48, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // 3. Glass rim border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.5, -0.5),
          radius: 1.05,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.06),
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // 4. Primary top-left glare
    final glareCenter = center + Offset(-radius * 0.28, -radius * 0.32);
    canvas.drawOval(
      Rect.fromCenter(
        center: glareCenter,
        width: radius * 0.58,
        height: radius * 0.36,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.62),
                Colors.white.withValues(alpha: 0.0),
              ],
            ).createShader(
              Rect.fromCenter(
                center: glareCenter,
                width: radius * 0.58,
                height: radius * 0.36,
              ),
            ),
    );

    // 5. Secondary bottom-right shimmer
    final shimmer = center + Offset(radius * 0.40, radius * 0.40);
    canvas.drawCircle(
      shimmer,
      radius * 0.20,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: shimmer, radius: radius * 0.20)),
    );
  }

  @override
  bool shouldRepaint(OrbPainter old) => old.animValue != animValue;
}
