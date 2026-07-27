import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:countify/widgets/wave_clipper.dart';
class CustomButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isPressed = false;
  double waterLevel = 0;
  bool showBubbles = false;
  Widget bubble() {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: -25,
      ),
      duration: const Duration(milliseconds: 800),

      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),

          child: Opacity(
            opacity: 1 - (value.abs() / 25),

            child: Container(
              width: 8,
              height: 8,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.white.withOpacity(0.7),

                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,

      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            isPressed = true;
          });
        },

        onTapUp: (_) {

          setState(() {
            isPressed = false;
            waterLevel = 80;
            showBubbles = true;
          });

          widget.onPressed();


          Future.delayed(
            const Duration(milliseconds: 500),
                () {
              if (mounted) {
                setState(() {
                  waterLevel = 0;
                  showBubbles = false;
                });
              }
            },
          );
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
            waterLevel = 0;
          });
        },

        child: AnimatedScale(
          scale: isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 120),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  color: const Color(0xFF263248).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(26),

                  border: Border.all(
                    color: widget.color.withOpacity(0.6),
                    width: 1.5,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.55),
                      blurRadius: 28,
                      spreadRadius: 3,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Stack(
                  alignment: Alignment.center,

                  children: [

                    // Water layer
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: waterLevel,

                      child: ClipPath(
                        clipper: WaveClipper(),
                        child: Container(
                          color: widget.color.withOpacity(0.35),
                        ),
                      ),
                    ),
                    if (showBubbles)
                      Positioned(
                        bottom: 20,
                        child: Row(
                          children: [
                            bubble(),
                            const SizedBox(width: 8),
                            bubble(),
                          ],
                        ),
                      ),
                    // Icon
                    Icon(
                      widget.icon,
                      size: 35,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
