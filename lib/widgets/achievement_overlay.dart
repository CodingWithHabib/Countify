import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AchievementOverlay extends StatefulWidget {
  final String title;
  final String description;

  const AchievementOverlay({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<AchievementOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // TOP LEFT
              Align(
                alignment: Alignment.topLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.directional,
                  blastDirection: 0.8,
                  // ↘
                  emissionFrequency: 0.02,
                  numberOfParticles: 20,
                  maxBlastForce: 35,
                  minBlastForce: 18,
                  gravity: 0.25,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                  ],
                ),
              ),

              // TOP RIGHT
              Align(
                alignment: Alignment.topRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.directional,
                  blastDirection: 2.35,
                  // ↙
                  emissionFrequency: 0.02,
                  numberOfParticles: 20,
                  maxBlastForce: 35,
                  minBlastForce: 18,
                  gravity: 0.25,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                  ],
                ),
              ),

              // LEFT CENTER
              Align(
                alignment: Alignment.centerLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.directional,
                  blastDirection: 0.0,
                  // →
                  emissionFrequency: 0.02,
                  numberOfParticles: 20,
                  maxBlastForce: 35,
                  minBlastForce: 18,
                  gravity: 0.25,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                  ],
                ),
              ),

              // RIGHT CENTER
              Align(
                alignment: Alignment.centerRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.directional,
                  blastDirection: 3.14,
                  // ←
                  emissionFrequency: 0.02,
                  numberOfParticles: 20,
                  maxBlastForce: 35,
                  minBlastForce: 18,
                  gravity: 0.25,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                  ],
                ),
              ),

              // BOTTOM LEFT
              Align(
                alignment: Alignment.bottomLeft,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.directional,
                  blastDirection: -0.8,
                  // ↗
                  emissionFrequency: 0.02,
                  numberOfParticles: 20,
                  maxBlastForce: 35,
                  minBlastForce: 18,
                  gravity: 0.25,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                  ],
                ),
              ),

              // BOTTOM RIGHT
              Align(
                alignment: Alignment.bottomRight,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.directional,
                  blastDirection: -2.35,
                  // ↖
                  emissionFrequency: 0.02,
                  numberOfParticles: 20,
                  maxBlastForce: 35,
                  minBlastForce: 18,
                  gravity: 0.25,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.orange,
                    Colors.blue,
                    Colors.green,
                    Colors.red,
                    Colors.purple,
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                tween: Tween(begin: 0.75, end: 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width > 500
                        ? 380
                        : MediaQuery.of(context).size.width * 0.85,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2533),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.30),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.amber,
                          size: 80,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Achievement Unlocked!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}