import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/theme_detection_service.dart';

class CounterPreview extends StatelessWidget {
  final String counterName;
  final int count;
  final ThemeDataModel theme;

  const CounterPreview({
    super.key,
    required this.counterName,
    required this.count,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      height: 335,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.backgroundColor,
            theme.surfaceColor,
          ],
        ),
        border: Border.all(
          color: theme.primaryColor.withOpacity(.58),
          width: 1.25,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [
            // =====================================================
            // THEME DECORATION
            // =====================================================

            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _AdaptiveDecorationPainter(
                    style: theme.style,
                    primary: theme.primaryColor,
                    secondary: theme.secondaryColor,
                    accent: theme.accentColor,
                    background: theme.backgroundColor,
                  ),
                ),
              ),
            ),

            // =====================================================
            // CONTENT
            // =====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                17,
                15,
                17,
                14,
              ),
              child: Column(
                children: [
                  // ------------------------------------------------
                  // TOP BADGE + MENU
                  // ------------------------------------------------

                  SizedBox(
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: _themeBadge(),
                        ),

                        Positioned(
                          right: 0,
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white.withOpacity(.65),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ------------------------------------------------
                  // MAIN ICON
                  // ------------------------------------------------

                  _buildMainIcon(),

                  const SizedBox(height: 9),

                  // ------------------------------------------------
                  // NAME
                  // ------------------------------------------------

                  Text(
                    counterName.trim().isEmpty
                        ? "Your Counter"
                        : counterName.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // ------------------------------------------------
                  // DESCRIPTION
                  // ------------------------------------------------

                  Text(
                    theme.description,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // COUNT
                  // ------------------------------------------------

                  Text(
                    "$count",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      height: .95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    "CURRENT COUNT",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.42),
                      fontSize: 9,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const Spacer(),

                  // ------------------------------------------------
                  // CONTROLS
                  // ------------------------------------------------

                  _buildControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // THEME BADGE
  // ================================================================

  Widget _themeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.primaryColor.withOpacity(.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            theme.icon,
            color: theme.primaryColor,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            theme.themeName,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // MAIN ICON
  // ================================================================

  Widget _buildMainIcon() {
    if (theme.style == CounterThemeStyle.islamic) {
      return _buildTasbeehIcon();
    }

    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        border: Border.all(
          color: theme.accentColor.withOpacity(.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(.32),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        theme.icon,
        color: Colors.white,
        size: 34,
      ),
    );
  }

  // ================================================================
  // TASBEEH ICON
  // ================================================================

  Widget _buildTasbeehIcon() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.secondaryColor,
          ],
        ),
        border: Border.all(
          color: theme.accentColor.withOpacity(.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(.35),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 13,
            child: _iconBead(7),
          ),

          Positioned(
            left: 13,
            child: _iconBead(8),
          ),

          Positioned(
            right: 13,
            child: _iconBead(8),
          ),

          Positioned(
            bottom: 13,
            child: _iconBead(7),
          ),

          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.92),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withOpacity(.45),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.touch_app_rounded,
              color: theme.primaryColor,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBead(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.accentColor.withOpacity(.95),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withOpacity(.35),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CONTROLS
  // ================================================================

  Widget _buildControls() {
    if (theme.style == CounterThemeStyle.islamic) {
      return Row(
        children: [
          _tasbeehControlButton(
            icon: Icons.remove_rounded,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    theme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: theme.accentColor.withOpacity(.55),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(.20),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBead(
                    size: 7,
                    opacity: .85,
                  ),

                  const SizedBox(width: 5),

                  _buildBead(
                    size: 5,
                    opacity: .60,
                  ),

                  const SizedBox(width: 8),

                  const Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white,
                    size: 19,
                  ),

                  const SizedBox(width: 7),

                  const Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Tap to Count",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 9),

          _tasbeehControlButton(
            icon: Icons.add_rounded,
          ),
        ],
      );
    }

    return Row(
      children: [
        _controlButton(
          icon: Icons.remove_rounded,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.accentColor.withOpacity(.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(.18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _buttonIcon(),
                  color: Colors.white,
                  size: 19,
                ),

                const SizedBox(width: 7),

                Flexible(
                  child: Text(
                    theme.buttonLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 9),

        _controlButton(
          icon: Icons.add_rounded,
        ),
      ],
    );
  }

  Widget _tasbeehControlButton({
    required IconData icon,
  }) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withOpacity(.55),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 6,
            child: _buildBead(
              size: 4,
              opacity: .65,
            ),
          ),

          Positioned(
            bottom: 6,
            child: _buildBead(
              size: 4,
              opacity: .65,
            ),
          ),

          Icon(
            icon,
            color: theme.accentColor,
            size: 23,
          ),
        ],
      ),
    );
  }

  Widget _buildBead({
    required double size,
    required double opacity,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.accentColor.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withOpacity(.25),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
  }) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(.75),
        ),
      ),
      child: Icon(
        icon,
        color: theme.primaryColor,
        size: 23,
      ),
    );
  }

  // ================================================================
  // BUTTON ICON
  // ================================================================

  IconData _buttonIcon() {
    switch (theme.style) {
      case CounterThemeStyle.islamic:
        return Icons.touch_app_rounded;

      case CounterThemeStyle.fitness:
        return Icons.flash_on_rounded;

      case CounterThemeStyle.education:
        return Icons.check_circle_outline_rounded;

      case CounterThemeStyle.programming:
        return Icons.play_arrow_rounded;

      case CounterThemeStyle.nature:
        return Icons.eco_rounded;

      case CounterThemeStyle.productivity:
        return Icons.check_rounded;

      case CounterThemeStyle.sports:
        return Icons.sports_score_rounded;

      case CounterThemeStyle.health:
        return Icons.medical_services_rounded;

      case CounterThemeStyle.finance:
        return Icons.account_balance_wallet_rounded;

      case CounterThemeStyle.creative:
        return Icons.palette_rounded;

      case CounterThemeStyle.defaultTheme:
        return Icons.auto_awesome_rounded;
    }
  }
}

// ====================================================================
// ADAPTIVE DECORATION PAINTER
// ====================================================================

class _AdaptiveDecorationPainter extends CustomPainter {
  final CounterThemeStyle style;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;

  _AdaptiveDecorationPainter({
    required this.style,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ============================================================
    // GENERAL SOFT LIGHT
    // ============================================================

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withOpacity(.18),
          primary.withOpacity(.04),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * .5,
            size.height * .35,
          ),
          radius: size.width * .65,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * .5,
        size.height * .35,
      ),
      size.width * .65,
      glowPaint,
    );

    // ============================================================
    // THEME DECORATION
    // ============================================================

    switch (style) {
      case CounterThemeStyle.islamic:
        _paintIslamic(canvas, size);
        break;

      case CounterThemeStyle.fitness:
        _paintFitness(canvas, size);
        break;

      case CounterThemeStyle.education:
        _paintEducation(canvas, size);
        break;

      case CounterThemeStyle.programming:
        _paintProgramming(canvas, size);
        break;

      case CounterThemeStyle.nature:
        _paintNature(canvas, size);
        break;

      case CounterThemeStyle.productivity:
        _paintProductivity(canvas, size);
        break;

      case CounterThemeStyle.sports:
        _paintSports(canvas, size);
        break;

      case CounterThemeStyle.health:
      case CounterThemeStyle.finance:
      case CounterThemeStyle.creative:
      case CounterThemeStyle.defaultTheme:
        _paintDefault(canvas, size);
        break;
    }
  }

  // ================================================================
  // ISLAMIC
  // ================================================================

  void _paintIslamic(
      Canvas canvas,
      Size size,
      ) {
    _paintIslamicPattern(canvas, size);
    _paintIslamicBorder(canvas, size);
    _paintCrescent(canvas, size);
    _paintLantern(canvas, size);
    _paintStars(canvas, size);
    _paintMosque(canvas, size);
  }

  void _paintIslamicPattern(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withOpacity(.075);

    const spacing = 32.0;

    for (
    double x = 0;
    x < size.width;
    x += spacing
    ) {
      for (
      double y = 0;
      y < size.height;
      y += spacing
      ) {
        _drawEightPointPattern(
          canvas,
          Offset(x, y),
          10,
          paint,
        );
      }
    }
  }

  void _drawEightPointPattern(
      Canvas canvas,
      Offset center,
      double radius,
      Paint paint,
      ) {
    final path = Path();

    for (int i = 0; i < 16; i++) {
      final angle =
          -math.pi / 2 + (i * math.pi / 8);

      final r = i.isEven
          ? radius
          : radius * .42;

      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );

      if (i == 0) {
        path.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  void _paintIslamicBorder(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withOpacity(.30);

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        8,
        8,
        size.width - 16,
        size.height - 16,
      ),
      const Radius.circular(22),
    );

    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        14,
        14,
        size.width - 28,
        size.height - 28,
      ),
      const Radius.circular(18),
    );

    canvas.drawRRect(outer, paint);
    canvas.drawRRect(inner, paint);

    _drawCornerOrnament(
      canvas,
      const Offset(23, 23),
      paint,
      flipX: false,
      flipY: false,
    );

    _drawCornerOrnament(
      canvas,
      Offset(size.width - 23, 23),
      paint,
      flipX: true,
      flipY: false,
    );

    _drawCornerOrnament(
      canvas,
      Offset(23, size.height - 23),
      paint,
      flipX: false,
      flipY: true,
    );

    _drawCornerOrnament(
      canvas,
      Offset(
        size.width - 23,
        size.height - 23,
      ),
      paint,
      flipX: true,
      flipY: true,
    );
  }

  void _drawCornerOrnament(
      Canvas canvas,
      Offset center,
      Paint paint, {
        required bool flipX,
        required bool flipY,
      }) {
    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.scale(
      flipX ? -1 : 1,
      flipY ? -1 : 1,
    );

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(25, 0)
      ..lineTo(25, 5)
      ..lineTo(7, 5)
      ..lineTo(7, 23)
      ..lineTo(0, 23)
      ..close();

    canvas.drawPath(path, paint);

    canvas.restore();
  }

  void _paintCrescent(
      Canvas canvas,
      Size size,
      ) {
    final center = Offset(
      size.width - 52,
      48,
    );

    final moonPaint = Paint()
      ..color = accent.withOpacity(.75);

    canvas.drawCircle(
      center,
      17,
      moonPaint,
    );

    final cutPaint = Paint()
      ..color = background;

    canvas.drawCircle(
      Offset(
        center.dx + 7,
        center.dy - 5,
      ),
      16,
      cutPaint,
    );
  }

  void _paintLantern(
      Canvas canvas,
      Size size,
      ) {
    final centerX = size.width * .12;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = accent.withOpacity(.55);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withOpacity(.40),
          primary.withOpacity(.20),
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, 72),
          width: 30,
          height: 45,
        ),
      );

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, 48),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, 51),
        width: 12,
        height: 5,
      ),
      linePaint,
    );

    final body = Path()
      ..moveTo(centerX - 11, 56)
      ..lineTo(centerX + 11, 56)
      ..lineTo(centerX + 8, 84)
      ..lineTo(centerX - 8, 84)
      ..close();

    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, linePaint);

    final lightPaint = Paint()
      ..color = accent.withOpacity(.35);

    canvas.drawCircle(
      Offset(centerX, 69),
      6,
      lightPaint,
    );
  }

  void _paintStars(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = accent.withOpacity(.48);

    _drawStar(
      canvas,
      Offset(size.width - 28, 30),
      4,
      paint,
    );

    _drawStar(
      canvas,
      Offset(size.width - 84, 67),
      3,
      paint,
    );

    _drawStar(
      canvas,
      Offset(size.width * .22, 50),
      3,
      paint,
    );
  }

  void _drawStar(
      Canvas canvas,
      Offset center,
      double radius,
      Paint paint,
      ) {
    final path = Path();

    for (int i = 0; i < 10; i++) {
      final angle =
          -math.pi / 2 + i * math.pi / 5;

      final currentRadius = i.isEven
          ? radius
          : radius * .38;

      final point = Offset(
        center.dx +
            math.cos(angle) * currentRadius,
        center.dy +
            math.sin(angle) * currentRadius,
      );

      if (i == 0) {
        path.moveTo(
          point.dx,
          point.dy,
        );
      } else {
        path.lineTo(
          point.dx,
          point.dy,
        );
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  void _paintMosque(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(.23);

    final baseY = size.height;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .17,
        baseY - 39,
        size.width * .66,
        39,
      ),
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * .50,
        baseY - 39,
      ),
      25,
      paint,
    );

    final domeTop = Path()
      ..moveTo(
        size.width * .46,
        baseY - 55,
      )
      ..quadraticBezierTo(
        size.width * .50,
        baseY - 78,
        size.width * .54,
        baseY - 55,
      )
      ..close();

    canvas.drawPath(domeTop, paint);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .27,
        baseY - 72,
        6,
        72,
      ),
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * .30,
        baseY - 76,
      ),
      7,
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .70,
        baseY - 72,
        6,
        72,
      ),
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * .73,
        baseY - 76,
      ),
      7,
      paint,
    );

    final windowPaint = Paint()
      ..color = primary.withOpacity(.18);

    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(
          size.width * .29 + i * 26,
          baseY - 19,
        ),
        5,
        windowPaint,
      );
    }
  }

  // ================================================================
  // FITNESS
  // ================================================================

  void _paintFitness(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(
        size.width * .85,
        size.height * .18,
      ),
      65,
      paint,
    );

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withOpacity(.15);

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(
          18,
          size.height - 35 - i * 15,
        ),
        Offset(
          size.width - 18,
          size.height - 35 - i * 15,
        ),
        linePaint,
      );
    }
  }

  // ================================================================
  // EDUCATION
  // ================================================================

  void _paintEducation(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = primary.withOpacity(.08);

    for (int i = 0; i < 7; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          22,
          38 + i * 25,
          size.width - 44,
          1,
        ),
        paint,
      );
    }
  }

  // ================================================================
  // PROGRAMMING
  // ================================================================

  void _paintProgramming(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = primary.withOpacity(.08);

    canvas.drawCircle(
      Offset(
        size.width * .85,
        size.height * .20,
      ),
      65,
      paint,
    );
  }

  // ================================================================
  // NATURE
  // ================================================================

  void _paintNature(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(
        size.width * .15,
        size.height * .18,
      ),
      55,
      paint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.width - 40,
          size.height - 45,
        ),
        width: 30,
        height: 60,
      ),
      Paint()
        ..color = accent.withOpacity(.14),
    );
  }

  // ================================================================
  // PRODUCTIVITY
  // ================================================================

  void _paintProductivity(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(
        size.width * .85,
        size.height * .18,
      ),
      55,
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * .85,
        size.height * .18,
      ),
      35,
      paint,
    );
  }

  // ================================================================
  // SPORTS
  // ================================================================

  void _paintSports(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = primary.withOpacity(.08);

    // Score-board lines
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(25, 60 + i * 30),
        Offset(size.width - 25, 60 + i * 30),
        paint,
      );
    }

    // Stadium Light Effect
    final lightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withOpacity(.15),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .85, size.height * .2),
          radius: 70,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * .85, size.height * .2),
      70,
      lightPaint,
    );

    // Light bulbs
    final bulbPaint = Paint()..color = primary.withOpacity(.3);
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        canvas.drawCircle(
          Offset(size.width * .82 + i * 20, size.height * .17 + j * 20),
          5,
          bulbPaint,
        );
      }
    }
  }

  // ================================================================
  // DEFAULT
  // ================================================================

  void _paintDefault(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(
        size.width * .85,
        size.height * .20,
      ),
      55,
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * .85,
        size.height * .20,
      ),
      35,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _AdaptiveDecorationPainter oldDelegate,
      ) {
    return oldDelegate.style != style ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.accent != accent ||
        oldDelegate.background != background;
  }
}