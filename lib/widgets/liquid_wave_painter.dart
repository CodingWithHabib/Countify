import 'dart:math';
import 'package:flutter/material.dart';

class LiquidWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  LiquidWavePainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 💎 Back Water (Very Transparent)
    final Paint backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFBFEFFF).withOpacity(0.05),
          const Color(0xFF79D8FF).withOpacity(0.10),
        ],
      ).createShader(rect);

    // 💎 Front Water (Transparent)
    final Paint frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8EDFFF).withOpacity(0.12),
          const Color(0xFF39BFFF).withOpacity(0.20),
        ],
      ).createShader(rect);

    //---------------- BACK WAVE ----------------//

    final backLevel = size.height * 0.42;
    final backWave = Path();

    backWave.moveTo(0, backLevel);

    for (double x = 0; x <= size.width; x += 2) {
      final y =
          backLevel +
              sin(
                (x / size.width * 2 * pi) +
                    animationValue * 2 * pi * 0.7,
              ) *
                  5;

      backWave.lineTo(x, y);
    }

    backWave
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(backWave, backPaint);

    //---------------- FRONT WAVE ----------------//

    final frontLevel = size.height * 0.38;
    final frontWave = Path();

    frontWave.moveTo(0, frontLevel);

    for (double x = 0; x <= size.width; x += 2) {
      final y =
          frontLevel +
              sin(
                (x / size.width * 2 * pi) +
                    animationValue * 2 * pi,
              ) *
                  7;

      frontWave.lineTo(x, y);
    }

    frontWave
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(frontWave, frontPaint);
//---------------- MIDDLE WAVE ----------------//

    final middlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF9FE7FF).withOpacity(0.18),
          const Color(0xFF5CCEFF).withOpacity(0.28),
        ],
      ).createShader(rect);

    final middleLevel = size.height * 0.40;

    final middleWave = Path();

    middleWave.moveTo(0, middleLevel);

    for (double x = 0; x <= size.width; x += 2) {
      final y =
          middleLevel +
              sin(
                (x / size.width * 2 * pi) +
                    animationValue * 2 * pi * 1.4,
              ) *
                  6;

      middleWave.lineTo(x, y);
    }

    middleWave
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(middleWave, middlePaint);
    //---------------- FOAM ----------------//

    final foamPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final foam = Path();

    foam.moveTo(0, frontLevel);

    for (double x = 0; x <= size.width; x += 2) {
      final y =
          frontLevel +
              sin(
                (x / size.width * 2 * pi) +
                    animationValue * 2 * pi,
              ) *
                  7;

      foam.lineTo(x, y);
    }

    canvas.drawPath(foam, foamPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidWavePainter oldDelegate) => true;
}