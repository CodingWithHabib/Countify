import 'package:flutter/material.dart';

class LiveCountifyLogo extends StatefulWidget {
  final double size;
  final bool showText;

  const LiveCountifyLogo({
    super.key,
    this.size = 38,
    this.showText = false,
  });

  @override
  State<LiveCountifyLogo> createState() => _LiveCountifyLogoState();
}

class _LiveCountifyLogoState extends State<LiveCountifyLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowVal = _controller.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.25 + (glowVal * 0.2)),
                blurRadius: 14 + (glowVal * 8),
                spreadRadius: 1,
              ),
            ],
          ),
          child: CustomPaint(
            painter: CLogoPainter(progress: glowVal),
          ),
        );
      },
    );
  }
}

// Custom Painter for Countify Brand Logo (C Crescent + 3 Ascending Growth Bar Charts + Crown Accent)
class CLogoPainter extends CustomPainter {
  final double progress;

  const CLogoPainter({this.progress = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3;

    // 1. Outer C Arc (Glassmorphic Crescent)
    final cPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00E5FF),
          const Color(0xFF10B981),
          const Color(0xFF3B82F6),
          const Color(0xFF8B5CF6).withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.68, // Start angle
      4.9,  // Sweep angle
      false,
      cPaint,
    );

    // 2. Inside 'C': 3 Ascending Growth Bar Charts (📊)
    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF10B981)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final barWidth = size.width * 0.08;
    final spacing = size.width * 0.04;
    final startX = center.dx - (barWidth * 1.5) - spacing;

    // Bar 1 (Short)
    final bar1Height = size.height * 0.22;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, center.dy + (size.height * 0.1) - bar1Height, barWidth, bar1Height),
        Radius.circular(barWidth / 2),
      ),
      barPaint,
    );

    // Bar 2 (Medium)
    final bar2Height = size.height * 0.35;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + barWidth + spacing, center.dy + (size.height * 0.1) - bar2Height, barWidth, bar2Height),
        Radius.circular(barWidth / 2),
      ),
      barPaint,
    );

    // Bar 3 (Tall - Animated)
    final bar3Height = size.height * (0.45 + (progress * 0.06));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(startX + (barWidth + spacing) * 2, center.dy + (size.height * 0.1) - bar3Height, barWidth, bar3Height),
        Radius.circular(barWidth / 2),
      ),
      barPaint,
    );

    // 3. Glowing Crown Top Accent
    final crownPaint = Paint()
      ..color = const Color(0xFFF59E0B).withOpacity(0.85 + (progress * 0.15))
      ..style = PaintingStyle.fill;

    final crownPath = Path()
      ..moveTo(center.dx - (size.width * 0.12), center.dy - radius - (size.height * 0.02))
      ..lineTo(center.dx - (size.width * 0.06), center.dy - radius + (size.height * 0.04))
      ..lineTo(center.dx, center.dy - radius - (size.height * 0.06))
      ..lineTo(center.dx + (size.width * 0.06), center.dy - radius + (size.height * 0.04))
      ..lineTo(center.dx + (size.width * 0.12), center.dy - radius - (size.height * 0.02))
      ..lineTo(center.dx + (size.width * 0.08), center.dy - radius + (size.height * 0.08))
      ..lineTo(center.dx - (size.width * 0.08), center.dy - radius + (size.height * 0.08))
      ..close();

    canvas.drawPath(crownPath, crownPaint);
  }

  @override
  bool shouldRepaint(covariant CLogoPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
