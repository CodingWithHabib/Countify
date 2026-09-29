import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import '../models/streak_milestone.dart';
import '../services/vibration_service.dart';
import '../services/sound_service.dart';
import 'live_animated_icon.dart';

class StreakMilestoneDialog extends StatefulWidget {
  final StreakMilestone milestone;

  const StreakMilestoneDialog({
    super.key,
    required this.milestone,
  });

  static void show(BuildContext context, StreakMilestone milestone) {
    VibrationService.vibrateStrong();
    SoundService.playClick(pitch: 1.4);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StreakMilestoneDialog(milestone: milestone),
    );
  }

  @override
  State<StreakMilestoneDialog> createState() => _StreakMilestoneDialogState();
}

class _StreakMilestoneDialogState extends State<StreakMilestoneDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final milestone = widget.milestone;

    return Stack(
      alignment: Alignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: milestone.color.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: milestone.color.withOpacity(0.3),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Glowing Icon
                LiveAnimatedIcon(
                  icon: milestone.icon,
                  color: milestone.color,
                  size: 80,
                  iconSize: 42,
                ),
                const SizedBox(height: 20),
                Text(
                  "🎉 STREAK MILESTONE UNLOCKED! 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: milestone.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  milestone.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: milestone.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: milestone.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    "🔥 ${milestone.days} Day${milestone.days == 1 ? '' : 's'} Streak Achieved!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: milestone.color,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  milestone.reward,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: milestone.color),
                        ),
                        icon: Icon(Icons.share_rounded, size: 18, color: milestone.color),
                        label: Text("Share", style: TextStyle(color: milestone.color, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text:
                                  "🔥 I just achieved a ${milestone.days}-day streak on Countify! Milestone Unlocked: ${milestone.title}! 🚀",
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: milestone.color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.local_fire_department_rounded, size: 18, color: Colors.white),
                        label: const Text(
                          "Keep Burning",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Confetti Blast Overlay
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 35,
              emissionFrequency: 0.05,
              gravity: 0.2,
              colors: const [
                Colors.orange,
                Colors.amber,
                Colors.red,
                Colors.blue,
                Colors.purple,
                Colors.green,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
