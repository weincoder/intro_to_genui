import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Escenarios de la mascota búho de ValoraCode.
enum OwlScenario {
  /// Saludo amigable — splash y bienvenida.
  greeting,

  /// Estado vacío — sin datos todavía.
  empty,

  /// Operación exitosa — celebración.
  success,

  /// Trabajando / cargando — concentrado.
  working,

  /// Meditando — pantalla de herramientas y más.
  meditation,
}

/// CustomPainter que dibuja la mascota búho de ValoraCode.
///
/// [animValue] es un valor 0..1 proveniente de un AnimationController.repeat();
/// produce un efecto de flotación suave.
class OwlPainter extends CustomPainter {
  final OwlScenario scenario;
  final double animValue;

  const OwlPainter({this.scenario = OwlScenario.greeting, this.animValue = 0});

  // ─── Coordenadas clave (fracciones del canvas) ──────────────────────────────
  static const double _cx = 0.50; // center x fraction
  static const double _bodyTopY = 0.18; // top of head fraction
  static const double _bodyBottomY = 0.86; // bottom of body fraction

  @override
  void paint(Canvas canvas, Size size) {
    final bob = math.sin(animValue * 2 * math.pi) * size.height * 0.018;

    canvas.save();
    canvas.translate(0, bob);

    _drawShadow(canvas, size);
    _drawBody(canvas, size);
    _drawWings(canvas, size);
    _drawBelly(canvas, size);
    _drawFace(canvas, size);
    _drawEarTufts(canvas, size);
    _drawEyes(canvas, size);
    _drawBeak(canvas, size);
    _drawFeet(canvas, size);
    if (scenario == OwlScenario.working) _drawDocument(canvas, size);
    if (scenario == OwlScenario.success) _drawSparkles(canvas, size);
    if (scenario == OwlScenario.meditation) _drawOrbs(canvas, size);
    _drawGlasses(canvas, size); // always on top of eyes

    canvas.restore();
  }

  // ─── Shadow ─────────────────────────────────────────────────────────────────

  void _drawShadow(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * _cx, size.height * 0.93),
        width: size.width * 0.50,
        height: size.height * 0.06,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  // ─── Body ────────────────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final cy = size.height * ((_bodyTopY + _bodyBottomY) / 2);
    final bodyH = size.height * (_bodyBottomY - _bodyTopY);
    final bodyW = size.width * 0.66;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: bodyW, height: bodyH),
      Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(-0.25, -0.35),
              radius: 0.88,
              colors: const [
                Color(0xFF5A4AE0),
                Color(0xFF2C1A90),
                Color(0xFF1A0047),
              ],
              stops: const [0.0, 0.52, 1.0],
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx, cy),
                width: bodyW,
                height: bodyH,
              ),
            ),
    );
  }

  // ─── Wings ───────────────────────────────────────────────────────────────────

  void _drawWings(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final midY = size.height * 0.58;

    final wingPaint = Paint()
      ..color = const Color(0xFF2B1888)
      ..style = PaintingStyle.fill;

    // Left wing
    final left = Path()
      ..moveTo(cx - size.width * 0.30, midY - size.height * 0.06)
      ..cubicTo(
        cx - size.width * 0.54,
        midY - size.height * 0.12,
        cx - size.width * 0.57,
        midY + size.height * 0.18,
        cx - size.width * 0.32,
        midY + size.height * 0.24,
      )
      ..cubicTo(
        cx - size.width * 0.26,
        midY + size.height * 0.26,
        cx - size.width * 0.22,
        midY + size.height * 0.16,
        cx - size.width * 0.30,
        midY - size.height * 0.06,
      );
    canvas.drawPath(left, wingPaint);

    // Right wing
    final right = Path()
      ..moveTo(cx + size.width * 0.30, midY - size.height * 0.06)
      ..cubicTo(
        cx + size.width * 0.54,
        midY - size.height * 0.12,
        cx + size.width * 0.57,
        midY + size.height * 0.18,
        cx + size.width * 0.32,
        midY + size.height * 0.24,
      )
      ..cubicTo(
        cx + size.width * 0.26,
        midY + size.height * 0.26,
        cx + size.width * 0.22,
        midY + size.height * 0.16,
        cx + size.width * 0.30,
        midY - size.height * 0.06,
      );
    canvas.drawPath(right, wingPaint);

    // Feather lines
    final linePaint = Paint()
      ..color = const Color(0xFF4233CE).withValues(alpha: 0.50)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      final t = i / 4.0;
      canvas.drawLine(
        Offset(
          cx - size.width * 0.50 + size.width * 0.22 * t,
          midY + size.height * (-0.10 + 0.18 * t),
        ),
        Offset(
          cx - size.width * 0.28 + size.width * 0.06 * t,
          midY + size.height * (0.06 + 0.10 * t),
        ),
        linePaint,
      );
      canvas.drawLine(
        Offset(
          cx + size.width * 0.50 - size.width * 0.22 * t,
          midY + size.height * (-0.10 + 0.18 * t),
        ),
        Offset(
          cx + size.width * 0.28 - size.width * 0.06 * t,
          midY + size.height * (0.06 + 0.10 * t),
        ),
        linePaint,
      );
    }
  }

  // ─── Belly ───────────────────────────────────────────────────────────────────

  void _drawBelly(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final cy = size.height * 0.63;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.42,
        height: size.height * 0.36,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFF7B6FEA).withValues(alpha: 0.58),
                const Color(0xFF4233CE).withValues(alpha: 0.16),
              ],
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx, cy),
                width: size.width * 0.42,
                height: size.height * 0.36,
              ),
            ),
    );

    // Feather texture arcs
    final texturePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int i = -2; i <= 2; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx + i * size.width * 0.07, cy + size.height * 0.04),
          width: size.width * 0.13,
          height: size.height * 0.09,
        ),
        math.pi * 0.2,
        math.pi * 0.6,
        false,
        texturePaint,
      );
    }
  }

  // ─── Face disc ───────────────────────────────────────────────────────────────

  void _drawFace(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final cy = size.height * 0.38;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: size.width * 0.54,
        height: size.height * 0.40,
      ),
      Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(0, -0.2),
              radius: 0.90,
              colors: const [Color(0xFF7A6EE5), Color(0xFF3A2AB2)],
            ).createShader(
              Rect.fromCenter(
                center: Offset(cx, cy),
                width: size.width * 0.54,
                height: size.height * 0.40,
              ),
            ),
    );

    // Soft inner disc
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy * 1.01),
        width: size.width * 0.46,
        height: size.height * 0.33,
      ),
      Paint()..color = const Color(0xFF6B5EE3).withValues(alpha: 0.38),
    );
  }

  // ─── Ear tufts ───────────────────────────────────────────────────────────────

  void _drawEarTufts(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final topY = size.height * 0.18;

    final darkPaint = Paint()
      ..color = const Color(0xFF2B1888)
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = const Color(0xFF4233CE).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    for (final sign in [-1.0, 1.0]) {
      final bx = cx + sign * size.width * 0.22;
      // Outer triangle
      final outer = Path()
        ..moveTo(bx - sign * size.width * 0.04, topY + size.height * 0.03)
        ..lineTo(bx, topY - size.height * 0.08)
        ..lineTo(bx + sign * size.width * 0.07, topY + size.height * 0.03)
        ..close();
      canvas.drawPath(outer, darkPaint);
      // Inner highlight triangle
      final inner = Path()
        ..moveTo(bx - sign * size.width * 0.01, topY + size.height * 0.02)
        ..lineTo(bx + sign * size.width * 0.01, topY - size.height * 0.04)
        ..lineTo(bx + sign * size.width * 0.04, topY + size.height * 0.02)
        ..close();
      canvas.drawPath(inner, accentPaint);
    }
  }

  // ─── Eyes ────────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final eyeY = size.height * 0.34;
    final eyeR = size.width * 0.115;
    final gap = size.width * 0.165;

    _drawEyebrows(canvas, size, eyeY - eyeR * 1.35, gap);

    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * gap;

      // White sclera
      canvas.drawCircle(
        Offset(ex, eyeY),
        eyeR,
        Paint()..color = Colors.white.withValues(alpha: 0.93),
      );

      // Iris gradient
      canvas.drawCircle(
        Offset(ex, eyeY),
        eyeR * 0.77,
        Paint()
          ..shader =
              RadialGradient(
                center: const Alignment(-0.25, -0.25),
                colors: const [
                  Color(0xFF9A8EFF),
                  Color(0xFF4233CE),
                  Color(0xFF0A0025),
                ],
                stops: const [0.0, 0.48, 1.0],
              ).createShader(
                Rect.fromCircle(center: Offset(ex, eyeY), radius: eyeR * 0.77),
              ),
      );

      // Pupil
      canvas.drawCircle(
        Offset(ex, eyeY),
        eyeR * 0.36,
        Paint()..color = const Color(0xFF060015),
      );

      // Primary highlight
      canvas.drawCircle(
        Offset(ex - eyeR * 0.20, eyeY - eyeR * 0.24),
        eyeR * 0.19,
        Paint()..color = Colors.white.withValues(alpha: 0.94),
      );

      // Secondary highlight
      canvas.drawCircle(
        Offset(ex + eyeR * 0.22, eyeY + eyeR * 0.12),
        eyeR * 0.08,
        Paint()..color = Colors.white.withValues(alpha: 0.60),
      );

      // Eye ring border
      canvas.drawCircle(
        Offset(ex, eyeY),
        eyeR,
        Paint()
          ..color = const Color(0xFF4233CE).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawEyebrows(Canvas canvas, Size size, double y, double gap) {
    final cx = size.width * _cx;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final angles = switch (scenario) {
      OwlScenario.empty => (-0.18, 0.18), // worried
      OwlScenario.success => (0.16, -0.16), // happy arched
      OwlScenario.working => (-0.10, -0.10), // focused frown
      OwlScenario.greeting => (-0.08, 0.08), // friendly slight raise
      OwlScenario.meditation => (0.12, -0.12), // serene slight arch
    };

    final hw = size.width * 0.09;
    for (final (sign, angle) in [(-1.0, angles.$1), (1.0, angles.$2)]) {
      canvas.save();
      canvas.translate(cx + sign * gap, y);
      canvas.rotate(angle);
      canvas.drawLine(Offset(-hw, 0), Offset(hw, 0), paint);
      canvas.restore();
    }
  }

  // ─── Beak ────────────────────────────────────────────────────────────────────

  void _drawBeak(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final beakTopY = size.height * 0.415;
    final beakBottomY = size.height * 0.475;
    final halfW = size.width * 0.065;

    final beakPath = Path()
      ..moveTo(cx - halfW, beakTopY)
      ..lineTo(cx, beakBottomY)
      ..lineTo(cx + halfW, beakTopY)
      ..cubicTo(
        cx + halfW * 0.5,
        beakTopY + (beakBottomY - beakTopY) * 0.3,
        cx - halfW * 0.5,
        beakTopY + (beakBottomY - beakTopY) * 0.3,
        cx - halfW,
        beakTopY,
      );

    canvas.drawPath(
      beakPath,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Color(0xFFFFD166), Color(0xFFFF9F1C)],
            ).createShader(
              Rect.fromPoints(
                Offset(cx - halfW, beakTopY),
                Offset(cx + halfW, beakBottomY),
              ),
            )
        ..style = PaintingStyle.fill,
    );

    // Center seam line
    canvas.drawLine(
      Offset(cx - halfW * 0.9, beakTopY + (beakBottomY - beakTopY) * 0.45),
      Offset(cx + halfW * 0.9, beakTopY + (beakBottomY - beakTopY) * 0.45),
      Paint()
        ..color = const Color(0xFFFF9F1C).withValues(alpha: 0.8)
        ..strokeWidth = 0.8,
    );
  }

  // ─── Feet ────────────────────────────────────────────────────────────────────

  void _drawFeet(Canvas canvas, Size size) {
    final cy = size.height * 0.89;
    final paint = Paint()
      ..color = const Color(0xFFFFD166)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final sign in [-1.0, 1.0]) {
      final fx = size.width * (_cx + sign * 0.14);
      for (int toe = -1; toe <= 1; toe++) {
        canvas.drawLine(
          Offset(fx, cy),
          Offset(fx + toe * size.width * 0.07, cy + size.height * 0.055),
          paint,
        );
      }
    }
  }

  // ─── Scenario props ──────────────────────────────────────────────────────────

  void _drawDocument(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final cy = size.height * 0.70;
    final w = size.width * 0.30;
    final h = size.height * 0.18;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF7B6FEA),
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.50)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(cx - w * 0.35, cy - h * 0.22 + i * h * 0.22),
        Offset(cx + w * 0.35, cy - h * 0.22 + i * h * 0.22),
        linePaint,
      );
    }
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final positions = [
      Offset(size.width * 0.08, size.height * 0.22),
      Offset(size.width * 0.90, size.height * 0.18),
      Offset(size.width * 0.04, size.height * 0.56),
      Offset(size.width * 0.94, size.height * 0.54),
    ];
    final r = size.width * 0.040;
    for (final pos in positions) {
      _drawSparkle(canvas, pos, r);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFFD166)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      canvas.drawLine(
        center + Offset(math.cos(angle) * r * 0.30, math.sin(angle) * r * 0.30),
        center + Offset(math.cos(angle) * r, math.sin(angle) * r),
        paint,
      );
    }
    canvas.drawCircle(
      center,
      r * 0.22,
      Paint()..color = const Color(0xFFFFD166),
    );
  }

  // ─── Glasses ──────────────────────────────────────────────────────────────────

  void _drawGlasses(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final eyeY = size.height * 0.34;
    final eyeR = size.width * 0.115;
    final gap = size.width * 0.165;

    final framePaint = Paint()
      ..color = const Color(0xFF1A0047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.030
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.015
      ..strokeCap = StrokeCap.round;

    // Left and right lens frames
    for (final sign in [-1.0, 1.0]) {
      final lx = cx + sign * gap;
      canvas.drawCircle(Offset(lx, eyeY), eyeR * 1.08, framePaint);
      // Small glint on top-left of each lens
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(lx - eyeR * 0.30, eyeY - eyeR * 0.38),
          radius: eyeR * 0.28,
        ),
        -2.4,
        1.2,
        false,
        glintPaint,
      );
    }

    // Bridge connecting the two lenses
    final bridgeY = eyeY - eyeR * 0.10;
    final leftEdge = cx - gap + eyeR * 1.05;
    final rightEdge = cx + gap - eyeR * 1.05;
    final bridgePath = Path()
      ..moveTo(leftEdge, bridgeY)
      ..cubicTo(
        leftEdge + (rightEdge - leftEdge) * 0.25,
        bridgeY - eyeR * 0.20,
        rightEdge - (rightEdge - leftEdge) * 0.25,
        bridgeY - eyeR * 0.20,
        rightEdge,
        bridgeY,
      );
    canvas.drawPath(
      bridgePath,
      Paint()
        ..color = const Color(0xFF1A0047)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.022
        ..strokeCap = StrokeCap.round,
    );

    // Side arms (temples)
    final armPaint = Paint()
      ..color = const Color(0xFF1A0047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.022
      ..strokeCap = StrokeCap.round;
    for (final sign in [-1.0, 1.0]) {
      final ex = cx + sign * gap;
      canvas.drawLine(
        Offset(ex + sign * eyeR * 1.05, eyeY - eyeR * 0.05),
        Offset(ex + sign * eyeR * 1.60, eyeY + eyeR * 0.25),
        armPaint,
      );
    }
  }

  @override
  bool shouldRepaint(OwlPainter old) =>
      old.animValue != animValue || old.scenario != scenario;

  // ─── Meditation orbs ─────────────────────────────────────────────────────────

  void _drawOrbs(Canvas canvas, Size size) {
    final cx = size.width * _cx;
    final cy = size.height * 0.52;
    final orbitR = size.width * 0.60;
    final orbPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = animValue * 2 * math.pi + i * (2 * math.pi / 5);
      final x = cx + math.cos(angle) * orbitR;
      final y = cy + math.sin(angle) * orbitR * 0.38;
      final r =
          size.width * (0.022 + 0.010 * math.sin(angle + animValue * math.pi));
      final alpha = (0.35 + 0.45 * math.sin(angle + animValue * math.pi * 2))
          .clamp(0.0, 1.0);
      orbPaint.color = const Color(0xFF9B8FF5).withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), r, orbPaint);
    }
  }
}
