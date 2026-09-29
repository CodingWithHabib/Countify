import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final bool enableGlow;
  final bool enableFloat;
  final bool enablePulse;
  final VoidCallback? onTap;

  const LiveAnimatedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.iconSize = 22,
    this.enableGlow = true,
    this.enableFloat = true,
    this.enablePulse = true,
    this.onTap,
  });

  @override
  State<LiveAnimatedIcon> createState() => _LiveAnimatedIconState();
}

class _LiveAnimatedIconState extends State<LiveAnimatedIcon>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.enableFloat || widget.enablePulse || widget.enableGlow) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LiveAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.isAnimating &&
        (widget.enableFloat || widget.enablePulse || widget.enableGlow)) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _scale = 0.88;
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _scale = 1.0;
      });
      widget.onTap!();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double val = _controller.value;
            final double pulseScale = widget.enablePulse ? 1.0 + (val * 0.06) : 1.0;
            final double floatY = widget.enableFloat ? math.sin(val * math.pi) * 2.5 : 0.0;
            final double glowSpread = widget.enableGlow ? 2.0 + (val * 6.0) : 2.0;
            final double glowBlur = widget.enableGlow ? 8.0 + (val * 8.0) : 6.0;

            return Transform.translate(
              offset: Offset(0, floatY),
              child: Transform.scale(
                scale: pulseScale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color.withOpacity(0.28),
                        widget.color.withOpacity(0.12),
                      ],
                    ),
                    border: Border.all(
                      color: widget.color.withOpacity(0.45),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.25 * (widget.enableGlow ? val : 0.5)),
                        blurRadius: glowBlur,
                        spreadRadius: glowSpread,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          widget.color.withOpacity(0.9),
                        ],
                      ).createShader(bounds),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: widget.iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
