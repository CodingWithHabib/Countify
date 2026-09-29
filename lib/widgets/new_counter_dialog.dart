import 'package:flutter/material.dart';
import '../services/theme_detection_service.dart';
import 'dart:math' as math;
import '../models/counter_model.dart';
import '../services/storage_service.dart';
class NewCounterDialog extends StatefulWidget {
  final String? initialCategory;
  const NewCounterDialog({super.key, this.initialCategory});

  @override
  State<NewCounterDialog> createState() => _NewCounterDialogState();
}

class _NewCounterDialogState extends State<NewCounterDialog> {
  final TextEditingController nameController = TextEditingController();

  late ThemeDataModel previewTheme;

  @override
  void initState() {
    super.initState();

    previewTheme = ThemeDetectionService.detect(widget.initialCategory ?? "");

    nameController.addListener(_updatePreview);
  }

  void _updatePreview() {
    final text = nameController.text.trim();
    var detected = ThemeDetectionService.detect(text);
    if (detected.style == CounterThemeStyle.defaultTheme && widget.initialCategory != null) {
      detected = ThemeDetectionService.detect(widget.initialCategory!);
    }

    setState(() {
      previewTheme = detected;
    });
  }

  @override
  void dispose() {
    nameController.removeListener(_updatePreview);
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: screenHeight * .92,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15171D),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.55),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              22, 22, 22, 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ==================================================
                // HEADER
                // ==================================================

                _buildHeader(),

                const SizedBox(height: 22),

                // ==================================================
                // NAME
                // ==================================================

                const Text(
                  "Counter Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 9),

                _buildNameField(),

                const SizedBox(height: 21),

                // ==================================================
                // LIVE PREVIEW HEADER
                // ==================================================

                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: previewTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: previewTheme.primaryColor
                                .withOpacity(.55),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      "Live Preview",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration:
                      const Duration(milliseconds: 250),
                      child: Text(
                        previewTheme.themeName,
                        key: ValueKey(
                          previewTheme.themeName,
                        ),
                        style: TextStyle(
                          color: previewTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 11),

                // ==================================================
                // PREVIEW
                // ==================================================

                _buildPreview(),

                const SizedBox(height: 18),

                // ==================================================
                // ACTIONS
                // ==================================================

                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                previewTheme.primaryColor,
                previewTheme.secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: previewTheme.primaryColor
                    .withOpacity(.28),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            previewTheme.icon,
            color: Colors.white,
            size: 29,
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Counter",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Create your personalized counter",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.white70,
            size: 29,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // NAME FIELD
  // ================================================================

  Widget _buildNameField() {
    return TextField(
      controller: nameController,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
      ),
      cursorColor: previewTheme.primaryColor,
      decoration: InputDecoration(
        hintText: "e.g. Morning Pushups",
        hintStyle: const TextStyle(
          color: Colors.white38,
          fontSize: 17,
        ),
        prefixIcon: const Icon(
          Icons.edit_rounded,
          color: Colors.white70,
          size: 25,
        ),
        filled: true,
        fillColor: const Color(0xFF202126),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.13),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: previewTheme.primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // MAIN PREVIEW
  // ================================================================

  Widget _buildPreview() {
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
            previewTheme.backgroundColor,
            previewTheme.surfaceColor,
          ],
        ),
        border: Border.all(
          color: previewTheme.primaryColor.withOpacity(.58),
          width: 1.25,
        ),
        boxShadow: [
          BoxShadow(
            color: previewTheme.primaryColor.withOpacity(.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          children: [

            // Theme-specific decorative layer.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _AdaptiveDecorationPainter(
                    style: previewTheme.style,
                    primary: previewTheme.primaryColor,
                    secondary: previewTheme.secondaryColor,
                    accent: previewTheme.accentColor,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                17, 15, 17, 14,
              ),
              child: Column(
                children: [

                  // ------------------------------------------------
                  // THEME BADGE
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

                  AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 250),
                    child: Text(
                      nameController.text.trim().isEmpty
                          ? "Your Counter"
                          : nameController.text.trim(),
                      key: ValueKey(
                        nameController.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    previewTheme.description,
                    textAlign: TextAlign.center,
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

                  const Text(
                    "0",
                    style: TextStyle(
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: previewTheme.primaryColor.withOpacity(.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: previewTheme.primaryColor.withOpacity(.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            previewTheme.icon,
            color: previewTheme.primaryColor,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            previewTheme.themeName,
            style: TextStyle(
              color: previewTheme.primaryColor,
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
    if (previewTheme.style == CounterThemeStyle.islamic) {
      return _buildTasbeehIcon();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(previewTheme.themeName),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              previewTheme.primaryColor,
              previewTheme.secondaryColor,
            ],
          ),
          border: Border.all(
            color: previewTheme.accentColor.withOpacity(.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: previewTheme.primaryColor
                  .withOpacity(.32),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          previewTheme.icon,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildTasbeehIcon() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: const ValueKey("tasbeeh_icon"),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              previewTheme.primaryColor,
              previewTheme.secondaryColor,
            ],
          ),
          border: Border.all(
            color: previewTheme.accentColor.withOpacity(.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: previewTheme.primaryColor.withOpacity(.35),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top bead
            Positioned(
              top: 13,
              child: _iconBead(7),
            ),

            // Left bead
            Positioned(
              left: 13,
              child: _iconBead(8),
            ),

            // Right bead
            Positioned(
              right: 13,
              child: _iconBead(8),
            ),

            // Bottom bead
            Positioned(
              bottom: 13,
              child: _iconBead(7),
            ),

            // Center bead
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.92),
                boxShadow: [
                  BoxShadow(
                    color: previewTheme.accentColor.withOpacity(.45),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.touch_app_rounded,
                color: previewTheme.primaryColor,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _iconBead(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: previewTheme.accentColor.withOpacity(.95),
        boxShadow: [
          BoxShadow(
            color: previewTheme.accentColor.withOpacity(.35),
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
    // ==============================================================
    // ISLAMIC / TASBEEH
    // ==============================================================

    if (previewTheme.style == CounterThemeStyle.islamic) {
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
                    previewTheme.primaryColor,
                    previewTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: previewTheme.accentColor.withOpacity(.55),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: previewTheme.primaryColor.withOpacity(.20),
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

                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text(
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

                  const SizedBox(width: 8),

                  _buildBead(
                    size: 5,
                    opacity: .60,
                  ),

                  const SizedBox(width: 5),

                  _buildBead(
                    size: 7,
                    opacity: .85,
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

    // ==============================================================
    // OTHER THEMES
    // ==============================================================

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
                  previewTheme.primaryColor,
                  previewTheme.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: previewTheme.accentColor.withOpacity(.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: previewTheme.primaryColor.withOpacity(.18),
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
                    previewTheme.buttonLabel,
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
          color: previewTheme.accentColor.withOpacity(.55),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: previewTheme.primaryColor.withOpacity(.12),
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
            color: previewTheme.accentColor,
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
        color: previewTheme.accentColor.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: previewTheme.accentColor.withOpacity(.25),
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
          color: previewTheme.primaryColor.withOpacity(.75),
        ),
      ),
      child: Icon(
        icon,
        color: previewTheme.primaryColor,
        size: 23,
      ),
    );
  }

  // ================================================================
  // BUTTON ICON
  // ================================================================

  IconData _buttonIcon() {
    switch (previewTheme.style) {
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

  // ================================================================
  // ACTION BUTTONS
  // ================================================================

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(.45),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () async {
                final name = nameController.text.trim();

                final counters = await StorageService.loadCounters();

                final newCounter = CounterModel(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name,
                  count: 0,
                  highestCount: 0,
                  category: previewTheme.themeName,
                  todayCount: 0,
                  isActive: counters.isEmpty,
                  themeStyle: previewTheme.style,
                );

                counters.add(newCounter);

                await StorageService.saveCounters(counters);

                if (!mounted) return;

                Navigator.pop(context, newCounter);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                previewTheme.primaryColor,
                disabledBackgroundColor:
                previewTheme.primaryColor.withOpacity(.22),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Create Counter",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

  _AdaptiveDecorationPainter({
    required this.style,
    required this.primary,
    required this.secondary,
    required this.accent,
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
          center: Offset(size.width * .5, size.height * .35),
          radius: size.width * .65,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * .5, size.height * .35),
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

  // ==============================================================
  // ISLAMIC THEME
  // ==============================================================

  void _paintIslamic(Canvas canvas, Size size) {
    _paintIslamicPattern(canvas, size);
    _paintIslamicBorder(canvas, size);
    _paintCrescent(canvas, size);
    _paintLantern(canvas, size);
    _paintStars(canvas, size);
    _paintMosque(canvas, size);
  }

  // ==============================================================
  // ISLAMIC GEOMETRIC PATTERN
  // ==============================================================

  void _paintIslamicPattern(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withOpacity(.075);

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
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

      final r = i.isEven ? radius : radius * .42;

      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  // ==============================================================
  // ORNAMENTAL BORDER
  // ==============================================================

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

    // Corner ornaments
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
      Offset(size.width - 23, size.height - 23),
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

    canvas.translate(center.dx, center.dy);

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

  // ==============================================================
  // CRESCENT
  // ==============================================================

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
      ..color = const Color(0xFF10241A);

    canvas.drawCircle(
      Offset(
        center.dx + 7,
        center.dy - 5,
      ),
      16,
      cutPaint,
    );
  }

  // ==============================================================
  // LANTERN
  // ==============================================================

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

    // Hanging line
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, 48),
      linePaint,
    );

    // Top
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, 51),
        width: 12,
        height: 5,
      ),
      linePaint,
    );

    // Lantern body
    final body = Path()
      ..moveTo(centerX - 11, 56)
      ..lineTo(centerX + 11, 56)
      ..lineTo(centerX + 8, 84)
      ..lineTo(centerX - 8, 84)
      ..close();

    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, linePaint);

    // Light
    final lightPaint = Paint()
      ..color = accent.withOpacity(.35);

    canvas.drawCircle(
      Offset(centerX, 69),
      6,
      lightPaint,
    );
  }

  // ==============================================================
  // STARS
  // ==============================================================

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

      final currentRadius =
      i.isEven ? radius : radius * .38;

      final point = Offset(
        center.dx +
            math.cos(angle) * currentRadius,
        center.dy +
            math.sin(angle) * currentRadius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  // ==============================================================
  // MOSQUE SILHOUETTE
  // ==============================================================

  void _paintMosque(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(.23);

    final baseY = size.height;

    // Main building
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * .17,
        baseY - 39,
        size.width * .66,
        39,
      ),
      paint,
    );

    // Central dome
    canvas.drawCircle(
      Offset(
        size.width * .50,
        baseY - 39,
      ),
      25,
      paint,
    );

    // Dome top
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

    // Left minaret
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

    // Right minaret
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

    // Windows / arches
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

  // ==============================================================
  // OTHER THEMES
  // ==============================================================

  void _paintFitness(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(size.width * .85, size.height * .18),
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

  void _paintProgramming(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = primary.withOpacity(.08);

    canvas.drawCircle(
      Offset(size.width * .85, size.height * .20),
      65,
      paint,
    );
  }

  void _paintNature(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(size.width * .15, size.height * .18),
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
      Paint()..color = accent.withOpacity(.14),
    );
  }

  void _paintProductivity(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(size.width * .85, size.height * .18),
      55,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * .85, size.height * .18),
      35,
      paint,
    );
  }

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

  void _paintDefault(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primary.withOpacity(.10);

    canvas.drawCircle(
      Offset(size.width * .85, size.height * .20),
      55,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * .85, size.height * .20),
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
        oldDelegate.accent != accent;
  }
}