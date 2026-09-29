import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../services/theme_detection_service.dart';
import '../screens/workspace_screen.dart';

class CounterCard extends StatefulWidget {
  final String counterName;
  final String category;
  final int currentCount;
  final int highestCount;
  final int todayCount;
  final bool isActive;
  final CounterThemeStyle themeStyle;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onRename;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onOpen;
  final VoidCallback? onLongPress;
  final VoidCallback? onWorkspace;

  const CounterCard({
    super.key,
    required this.counterName,
    required this.category,
    required this.currentCount,
    required this.highestCount,
    required this.todayCount,
    required this.isActive,
    required this.themeStyle,
    required this.onOpen,
    this.onRename,
    this.onDuplicate,
    this.onDelete,
    this.onWorkspace,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
  });

  @override
  State<CounterCard> createState() => _CounterCardState();
}

class _CounterCardState extends State<CounterCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    
    // 1. Only run animation if active
    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CounterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 1. Sync animation state with isActive
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        // Return to 0.0 to save CPU and ensure clean static state
        _animationController.animateTo(0.0, duration: const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ================================================================
  // THEME CONFIG
  // ================================================================

  Color get primary => themeData.primaryColor;
  Color get secondary => themeData.secondaryColor;
  IconData get counterIcon => themeData.icon;
  String get buttonLabel => themeData.buttonLabel;
  String get description => themeData.description;

  ThemeDataModel get themeData {
    if (widget.category.isNotEmpty && widget.category.toLowerCase() != "custom") {
      final model = ThemeDetectionService.detect(widget.category);
      if (model.themeName.toLowerCase() != "adaptive") return model;
    }
    return ThemeDetectionService.detect(widget.counterName);
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.isSelectionMode ? widget.onLongPress : widget.onOpen,
      child: AnimatedScale(
        scale: widget.isActive ? 1.0 : 0.98,
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // LAYER 1: Animated Background & Border & Glow
              // Using AnimatedBuilder here to wrap ONLY the visual VFX
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    final anim = _animationController.value;
                    
                    // Optimization 3: Fixed blur radius, animate opacity/alpha
                    final double pulseBorderWidth = widget.isSelected 
                        ? 2.5 
                        : (widget.isActive ? (2.0 + anim * 0.8) : 1.2);

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(
                              const Color(0xFF08090C),
                              primary,
                              widget.isSelected ? .25 : (widget.isActive ? .18 : .10),
                            )!,
                            Color.lerp(
                              const Color(0xFF040506),
                              secondary,
                              widget.isSelected ? .20 : (widget.isActive ? .15 : .08),
                            )!,
                          ],
                        ),
                        border: Border.all(
                          color: widget.isSelected 
                              ? Colors.white 
                              : (widget.isActive 
                                  ? primary.withOpacity(0.4 + anim * 0.6) 
                                  : primary.withOpacity(.30)),
                          width: pulseBorderWidth,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(widget.isSelected ? .30 : (widget.isActive ? (.15 + anim * .10) : .05)),
                            blurRadius: 45,
                            spreadRadius: widget.isActive ? 2 : 0,
                            offset: Offset(0, widget.isActive ? 15 : 10),
                          ),
                          if (widget.isActive)
                            BoxShadow(
                              color: primary.withOpacity(0.05 + anim * 0.1),
                              blurRadius: 65,
                              spreadRadius: 8,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // LAYER 2: Background Decoration (CustomPaint)
              // Isolated with RepaintBoundary and AnimatedBuilder
              Positioned.fill(
                child: Opacity(
                  opacity: widget.isSelected ? 0.4 : (widget.isActive ? 1.0 : 0.5),
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, _) {
                        final anim = _animationController.value;
                        return Transform.translate(
                          offset: Offset(anim * 3, anim * -5),
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: _CounterDecorationPainter(
                                category: widget.category,
                                primary: primary,
                                secondary: secondary,
                                animationValue: anim,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // LAYER 3: Static Content
              // This layer is NOT rebuilt on every frame, eliminating lag
              Opacity(
                opacity: widget.isActive ? 1.0 : 0.75,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      if (!widget.isSelectionMode) ...[
                        _buildCountPreview(),
                        const SizedBox(height: 18),
                        _buildStatistics(),
                        const SizedBox(height: 20),
                        _buildStatusAndActions(),
                      ] else
                        _buildSelectionPreview(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            "${widget.currentCount}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            "TOTAL COUNT",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isSelectionMode)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 12),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: widget.isSelected ? Colors.white : Colors.white24,
                  width: 2,
                ),
              ),
              child: widget.isSelected
                  ? Icon(Icons.check, size: 18, color: primary)
                  : null,
            ),
          ),

        _buildIcon(),
        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.counterName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    themeData.themeName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.60),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _categoryBadge(),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        if (!widget.isSelectionMode)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMenu(),
              const SizedBox(height: 6),
              _buildStatusBadge(),
            ],
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isActive
            ? primary.withOpacity(.25)
            : Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.isActive
              ? primary.withOpacity(.50)
              : Colors.white.withOpacity(.09),
          width: widget.isActive ? 1.5 : 1.0,
        ),
        boxShadow: widget.isActive ? [
          BoxShadow(
            color: primary.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isActive ? Colors.white : Colors.white.withOpacity(.35),
              boxShadow: widget.isActive ? [
                BoxShadow(
                  color: Colors.white.withOpacity(.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.isActive ? "ACTIVE" : "Inactive",
            style: TextStyle(
              color: widget.isActive ? Colors.white : Colors.white.withOpacity(.50),
              fontSize: 10,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      height: 62,
      width: 62,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeData.primaryColor, themeData.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: themeData.primaryColor.withOpacity(.30),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(themeData.icon, color: Colors.white, size: 31),
    );
  }

  Widget _categoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: themeData.primaryColor.withOpacity(.11),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: themeData.primaryColor.withOpacity(.18)),
      ),
      child: Text(
        themeData.themeName,
        style: TextStyle(
          color: themeData.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 27,
      icon: Icon(
        Icons.more_horiz_rounded,
        color: Colors.white.withOpacity(.72),
      ),
      onSelected: (value) {
        switch (value) {
          case "rename": widget.onRename?.call(); break;
          case "duplicate": widget.onDuplicate?.call(); break;
          case "delete": widget.onDelete?.call(); break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: "rename",
          child: Row(children: [Icon(Icons.edit_rounded), SizedBox(width: 10), Text("Rename")]),
        ),
        PopupMenuItem(
          value: "duplicate",
          child: Row(children: [Icon(Icons.copy_rounded), SizedBox(width: 10), Text("Duplicate")]),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: "delete",
          child: Row(children: [Icon(Icons.delete_outline_rounded), SizedBox(width: 10), Text("Delete")]),
        ),
      ],
    );
  }

  Widget _buildCountPreview() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withOpacity(.065), Colors.black.withOpacity(.08)],
        ),
        border: Border.all(color: primary.withOpacity(.20), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -40,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [primary.withOpacity(.18), Colors.transparent]),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountIcon(),
              const SizedBox(height: 10),
              Text(
                "${widget.currentCount}",
                style: const TextStyle(color: Colors.white, fontSize: 48, height: .95, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              Text(
                "CURRENT COUNT",
                style: TextStyle(
                  color: Colors.white.withOpacity(.40),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountIcon() {
    final isIslamic = widget.category.toLowerCase() == "islamic";
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [primary, secondary]),
        boxShadow: [BoxShadow(color: primary.withOpacity(.28), blurRadius: 18)],
      ),
      child: isIslamic
          ? Stack(
              alignment: Alignment.center,
              children: [
                Positioned(left: 9, child: _bead(6)),
                Positioned(right: 9, child: _bead(6)),
                Positioned(top: 9, child: _bead(5)),
                Positioned(bottom: 9, child: _bead(5)),
                const Icon(Icons.touch_app_rounded, color: Colors.white, size: 26),
              ],
            )
          : Icon(themeData.icon, color: Colors.white, size: 27),
    );
  }

  Widget _bead(double size) => Container(
        height: size,
        width: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.80)),
      );

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(child: _statItem(title: "Current", value: "${widget.currentCount}")),
        _statDivider(),
        Expanded(child: _statItem(title: "Highest", value: "${widget.highestCount}")),
        _statDivider(),
        Expanded(child: _statItem(title: "Today", value: "+${widget.todayCount}", valueColor: primary)),
      ],
    );
  }

  Widget _statItem({required String title, required String value, Color? valueColor}) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _statDivider() => Container(width: 1, height: 40, color: Colors.white.withOpacity(.08));

  Widget _buildStatusAndActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: widget.onOpen,
              icon: const Icon(Icons.play_arrow_rounded, size: 21),
              label: const Text("Open", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                if (widget.onWorkspace != null) {
                  widget.onWorkspace!.call();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkspaceScreen(category: widget.category),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.dashboard_customize_rounded, size: 20),
              label: const Text(
                "Workspace",
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// PREMIUM CATEGORY DECORATION
// ====================================================================

class _CounterDecorationPainter extends CustomPainter {
  final String category;
  final Color primary;
  final Color secondary;
  final double animationValue;

  const _CounterDecorationPainter({
    required this.category,
    required this.primary,
    required this.secondary,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final lowerCategory = category.toLowerCase();

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [primary.withOpacity(.35), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(size.width * .9, size.height * 0.1), radius: size.width * 0.7));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    switch (lowerCategory) {
      case "islamic": _paintIslamic(canvas, size); break;
      case "fitness": _paintFitness(canvas, size); break;
      case "education": _paintEducation(canvas, size); break;
      case "programming": _paintProgramming(canvas, size); break;
      case "nature": _paintNature(canvas, size); break;
      case "productivity": _paintProductivity(canvas, size); break;
      case "sports": _paintSports(canvas, size); break;
      default: _paintDefault(canvas, size);
    }
  }

  void _paintIslamic(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = primary.withOpacity(0.35);
    const spacing = 45.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawStar(canvas, Offset(x, y), 8, 10, paint);
      }
    }
    final extraStarPaint = Paint()..style = PaintingStyle.fill..color = Colors.white.withOpacity(0.2 + 0.15 * animationValue);
    _drawStar(canvas, Offset(size.width * 0.2, size.height * 0.3), 5, 8, extraStarPaint);
    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.75), 6, 7, extraStarPaint);
    _drawStar(canvas, Offset(size.width * 0.8, size.height * 0.6), 5, 9, extraStarPaint);
    _drawStar(canvas, Offset(size.width * 0.5, size.height * 0.15), 4, 6, extraStarPaint);

    final moonCenter = Offset(size.width - 70, 80);
    final moonGlowPaint = Paint()..color = primary.withOpacity(0.4 + 0.2 * animationValue)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(moonCenter, 45, moonGlowPaint);
    final bounds = Rect.fromCircle(center: moonCenter, radius: 60);
    canvas.saveLayer(bounds, Paint());
    canvas.drawCircle(moonCenter, 40, Paint()..color = primary.withOpacity(0.5));
    canvas.drawCircle(moonCenter.translate(15, -8), 35, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    final starPaint = Paint()..color = Colors.white.withOpacity(0.5 + 0.3 * animationValue);
    _drawStar(canvas, moonCenter.translate(-25, 5), 5, 9, starPaint);
    _drawStar(canvas, moonCenter.translate(5, -35), 5, 5, starPaint);
  }

  void _paintFitness(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill..color = primary.withOpacity(0.35);
    for (int i = 0; i < 3; i++) {
      final center = Offset(size.width * (0.2 + i * 0.3), size.height * 0.82);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 60, height: 16), const Radius.circular(8)), paint);
      canvas.drawCircle(center.translate(-30, 0), 22, paint);
      canvas.drawCircle(center.translate(-38, 0), 16, paint);
      canvas.drawCircle(center.translate(30, 0), 22, paint);
      canvas.drawCircle(center.translate(38, 0), 16, paint);
    }
    final linePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 35..color = primary.withOpacity(0.25);
    canvas.drawLine(Offset(size.width * 0.5, -20), Offset(size.width + 20, size.height * 0.4), linePaint);
    canvas.drawLine(Offset(size.width * 0.3, -20), Offset(size.width + 20, size.height * 0.6), linePaint);
  }

  void _paintSports(Canvas canvas, Size size) {
    _drawFloodlight(canvas, Offset(60, 60), primary, size);
    _drawFloodlight(canvas, Offset(size.width - 60, 60), primary, size);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3.5..color = Colors.white.withOpacity(0.35);
    canvas.drawCircle(Offset(size.width / 2, size.height + 50), 130, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height + 50), 200, paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
  }

  void _drawFloodlight(Canvas canvas, Offset pos, Color color, Size size) {
    final glow = Paint()..shader = RadialGradient(colors: [color.withOpacity(0.45), Colors.transparent]).createShader(Rect.fromCircle(center: pos, radius: 90));
    canvas.drawCircle(pos, 90, glow);
    canvas.drawRect(Rect.fromCenter(center: pos, width: 44, height: 44), Paint()..color = color.withOpacity(0.5));
    final bulb = Paint()..color = Colors.white.withOpacity(0.8);
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(pos.translate(-12 + (i % 2) * 24, -12 + (i ~/ 2) * 24), 6, bulb);
    }
    final Path beamPath = Path();
    beamPath.moveTo(pos.dx - 22, pos.dy + 22);
    beamPath.lineTo(pos.dx + 22, pos.dy + 22);
    if (pos.dx < size.width / 2) {
      beamPath.lineTo(size.width * 0.7, size.height);
      beamPath.lineTo(size.width * 0.1, size.height);
    } else {
      beamPath.lineTo(size.width * 0.9, size.height);
      beamPath.lineTo(size.width * 0.3, size.height);
    }
    beamPath.close();
    final beamGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white.withOpacity(0.25 * (0.5 + 0.5 * animationValue)), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, pos.dy, size.width, size.height - pos.dy));
    canvas.drawPath(beamPath, Paint()..shader = beamGradient..style = PaintingStyle.fill);
  }

  void _paintProgramming(Canvas canvas, Size size) {
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), Paint()..color = primary.withOpacity(0.12));
    }
    for (double j = 0; j < size.height; j += 30) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), Paint()..color = primary.withOpacity(0.12));
    }
    _drawText(canvas, "{ }", Offset(size.width - 70, 50), 28, primary.withOpacity(0.5));
    _drawText(canvas, "</>", Offset(40, size.height - 60), 24, primary.withOpacity(0.45));
    double flicker1 = (math.sin(animationValue * math.pi * 3) + 1.0) / 2.0 * 0.4 + 0.1;
    double flicker2 = (math.cos(animationValue * math.pi * 2.5) + 1.0) / 2.0 * 0.4 + 0.1;
    _drawText(canvas, "10101", Offset(size.width - 100, size.height - 120), 20, Colors.white.withOpacity(flicker1));
    _drawText(canvas, "0110", Offset(35, 120), 18, Colors.white.withOpacity(flicker2));
  }

  void _paintNature(Canvas canvas, Size size) {
    final paint = Paint()..color = primary.withOpacity(0.35);
    final path = Path();
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.25, size.width * 0.75, size.height * 0.55);
    path.quadraticBezierTo(size.width * 0.88, size.height * 0.45, size.width, size.height * 0.35);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(60, 60), 80, Paint()..shader = RadialGradient(colors: [primary.withOpacity(0.4), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(60, 60), radius: 80)));
  }

  void _paintEducation(Canvas canvas, Size size) {
    final paint = Paint()..color = primary.withOpacity(0.35)..strokeWidth = 3.5;
    for (int i = 0; i < 10; i++) {
      canvas.drawLine(Offset(20, 40.0 + i * 25), Offset(size.width - 20, 40.0 + i * 25), paint);
    }
    _drawText(canvas, "A+", Offset(size.width - 70, 70), 38, primary.withOpacity(0.55));
  }

  void _paintProductivity(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3.5..color = primary.withOpacity(0.35);
    canvas.drawCircle(Offset(size.width - 60, 60), 50, paint);
    canvas.drawLine(Offset(size.width - 60, 60), Offset(size.width - 60, 35), paint);
    canvas.drawLine(Offset(size.width - 60, 60), Offset(size.width - 35, 60), paint);
  }

  void _paintDefault(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width, 0), 180, Paint()..color = primary.withOpacity(0.3));
    canvas.drawCircle(Offset(0, size.height), 130, Paint()..color = primary.withOpacity(0.3));
  }

  void _drawStar(Canvas canvas, Offset center, int points, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      double r = i.isEven ? radius : radius / 2.5;
      double angle = (i * math.pi) / points;
      Offset p = Offset(center.dx + math.cos(angle) * r, center.dy + math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CounterDecorationPainter oldDelegate) =>
      oldDelegate.category != category ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.animationValue != animationValue;
}
