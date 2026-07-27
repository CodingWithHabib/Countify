import 'package:flutter/material.dart';
import 'liquid_wave_painter.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';

class LiquidButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const LiquidButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  double buttonScale = 1.0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          buttonScale = 0.94;
        });
      },

      onTap: () async {
        setState(() {
          buttonScale = 1.08;
        });

        await SoundService.playClick();
        await VibrationService.vibrate();
        widget.onPressed();

        Future.delayed(const Duration(milliseconds: 120), () {
          if (!mounted) return;

          setState(() {
            buttonScale = 1.0;
          });
        });
      },

      onTapCancel: () {
        setState(() {
          buttonScale = 1.0;
        });
      },

      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        scale: buttonScale,

        child: isDark
            ? SizedBox(
          width: 82,
          height: 82,

          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(41),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: LiquidWavePainter(
                        animationValue: controller.value,
                        color: const Color(0xFF8EDFFF),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 42,
                        height: 8,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.45),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(41),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.30),
                          width: 1.5,
                        ),
                      ),
                    ),

                    Center(
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
            : Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color,
                widget.color.withOpacity(0.75),
              ],
            ),

            borderRadius: BorderRadius.circular(41),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.45),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}
