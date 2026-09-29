import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/toast_service.dart';
import '../theme/app_theme_colors.dart';
import '../models/streak_milestone.dart';

class StreakScreen extends StatefulWidget {
  final int currentStreak;
  final int bestStreak;
  final String lastActiveDate;

  const StreakScreen({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActiveDate,
  });

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen>
    with TickerProviderStateMixin {
  late int _currentStreak;
  late int _bestStreak;
  late String _lastActiveDate;
  bool _isLoading = true;

  late ConfettiController _confettiController;
  late AnimationController _bgAnimationController;

  static List<StreakMilestone> get allMilestones => StreakMilestone.allMilestones;

  @override
  void initState() {
    super.initState();
    _currentStreak = widget.currentStreak;
    _bestStreak = widget.bestStreak;
    _lastActiveDate = widget.lastActiveDate;

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _loadFreshStreak();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadFreshStreak() async {
    try {
      final streakData = await StorageService.loadStreak();
      if (mounted) {
        setState(() {
          _currentStreak = streakData["currentStreak"] ?? widget.currentStreak;
          _bestStreak = streakData["bestStreak"] ?? widget.bestStreak;
          _lastActiveDate =
              streakData["lastActiveDate"] ?? widget.lastActiveDate;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String get formattedLastActive {
    if (_lastActiveDate.isEmpty) return "Not active yet";
    try {
      final date = DateTime.parse(_lastActiveDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entryDate = DateTime(date.year, date.month, date.day);

      if (entryDate.isAtSameMomentAs(today)) {
        return "Today, ${DateFormat('hh:mm a').format(date)}";
      } else if (entryDate
          .isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
        return "Yesterday, ${DateFormat('hh:mm a').format(date)}";
      } else {
        return DateFormat("MMM dd • hh:mm a").format(date);
      }
    } catch (_) {
      return _lastActiveDate;
    }
  }

  Map<String, dynamic> get streakStatusInfo {
    if (_lastActiveDate.isEmpty) {
      return {
        "status": "START YOUR JOURNEY ⚡",
        "message": "Log your first count to ignite your streak!",
        "color": const Color(0xFF3B82F6),
        "icon": Icons.bolt_rounded,
      };
    }
    try {
      final date = DateTime.parse(_lastActiveDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entryDate = DateTime(date.year, date.month, date.day);

      if (entryDate.isAtSameMomentAs(today)) {
        return {
          "status": "STREAK ACTIVE TODAY 🔥",
          "message": "Awesome job! You've maintained your streak for today.",
          "color": const Color(0xFF10B981),
          "icon": Icons.check_circle_rounded,
        };
      } else if (entryDate
          .isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
        return {
          "status": "STREAK AT RISK ⏳",
          "message": "Log a count today to keep your streak burning!",
          "color": const Color(0xFFF59E0B),
          "icon": Icons.warning_amber_rounded,
        };
      } else {
        return {
          "status": "STREAK RESTARTED ⚡",
          "message": "Start counting today to build a brand new streak!",
          "color": const Color(0xFF3B82F6),
          "icon": Icons.refresh_rounded,
        };
      }
    } catch (_) {
      return {
        "status": "STREAK ACTIVE 🔥",
        "message": "Keep counting daily!",
        "color": Colors.orange,
        "icon": Icons.local_fire_department_rounded,
      };
    }
  }

  StreakMilestone get nextMilestone {
    for (var milestone in allMilestones) {
      if (_currentStreak < milestone.days) {
        return milestone;
      }
    }
    return allMilestones.last;
  }

  double get milestoneProgress {
    final target = nextMilestone.days;
    if (_currentStreak >= target) return 1.0;
    return (_currentStreak / target).clamp(0.0, 1.0);
  }

  void _showCelebrationDialog(StreakMilestone milestone) {
    _confettiController.play();
    VibrationService.vibrateStrong();
    SoundService.playClick(pitch: 1.4);

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Trophy Icon with Glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: milestone.color.withOpacity(0.2),
                          ),
                        ),
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: milestone.color.withOpacity(0.25),
                          child: Icon(
                            milestone.icon,
                            size: 42,
                            color: milestone.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "🎉 MILESTONE UNLOCKED! 🎉",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: milestone.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone.title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: milestone.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${milestone.days} Days Streak Achieved",
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
                        color:
                            isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: milestone.color),
                            ),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text("Share"),
                            onPressed: () {
                              SharePlus.instance.share(
                                ShareParams(
                                  text: "🔥 I just achieved a ${milestone.days}-day streak on Countify! Milestone Unlocked: ${milestone.title}! 🚀",
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: milestone.color,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text("Keep Burning"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Confetti Blast Overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: [
                  milestone.color,
                  Colors.orange,
                  Colors.amber,
                  Colors.blue,
                  Colors.green,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = streakStatusInfo;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A).withOpacity(0.85)
            : Colors.white.withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Streak Tracker",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: "Share Streak",
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: "🔥 My Countify Streak: $_currentStreak Day${_currentStreak == 1 ? '' : 's'} (Best: $_bestStreak Days)! Stay consistent with Countify! 🚀",
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Moving Glowing Aura Background
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              final double progress = _bgAnimationController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (progress * 40),
                    right: -70 + (progress * 30),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF97316)
                              .withOpacity(isDark ? 0.15 : 0.18),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 120 - (progress * 50),
                    left: -60 + (progress * 20),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEF4444)
                              .withOpacity(isDark ? 0.12 : 0.15),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Indicator Banner
                        buildStatusBanner(status, isDark),
                        const SizedBox(height: 16),

                        // Hero Burning Fire Card
                        buildHeroStreakCard(colors, isDark),
                        const SizedBox(height: 18),

                        // Stats Summary Row (Best Streak & Last Active)
                        Row(
                          children: [
                            Expanded(
                              child: buildInfoCard(
                                context,
                                title: "Best Streak",
                                value: "$_bestStreak Days",
                                icon: Icons.emoji_events_rounded,
                                color: const Color(0xFFF59E0B),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildInfoCard(
                                context,
                                title: "Last Active",
                                value: formattedLastActive,
                                icon: Icons.access_time_filled_rounded,
                                color: const Color(0xFF3B82F6),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Weekly Consistency Heatmap
                        buildWeeklyTracker(colors, isDark),

                        const SizedBox(height: 22),

                        // Next Milestone Card
                        buildNextMilestoneCard(colors, isDark),

                        const SizedBox(height: 24),

                        // All Milestones Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Streak Milestones",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.primaryText,
                              ),
                            ),
                            Text(
                              "${allMilestones.where((m) => _currentStreak >= m.days).length}/${allMilestones.length} Unlocked",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: allMilestones.length,
                          itemBuilder: (context, index) {
                            final milestone = allMilestones[index];
                            return buildMilestoneCard(
                                milestone, colors, isDark);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Consistency Tips Card
                        buildTipsCard(colors, isDark),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBanner(Map<String, dynamic> status, bool isDark) {
    final Color color = status["color"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(status["icon"] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status["status"],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status["message"],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeroStreakCard(AppThemeColors colors, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEA580C),
            Color(0xFFF97316),
            Color(0xFFF59E0B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Live Burning Flame Effect
          const LiveFlameWidget(size: 72, isLarge: true),
          const SizedBox(height: 12),

          const Text(
            "CURRENT STREAK",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),

          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _currentStreak.toDouble()),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                val.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 58,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          Text(
            _currentStreak == 1 ? "Day Burning 🔥" : "Days Burning 🔥",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeeklyTracker(AppThemeColors colors, bool isDark) {
    final now = DateTime.now();
    final daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"];
    final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Activity Tracker",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: colors.primaryText,
                ),
              ),
              Text(
                "This Week",
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isToday = dayNum == currentWeekday;
              final isPast = dayNum < currentWeekday;
              final isActive = isToday || (isPast && _currentStreak >= (currentWeekday - dayNum));

              return Column(
                children: [
                  Text(
                    daysOfWeek[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? Colors.orange : colors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.orange.withOpacity(0.2)
                          : isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                      border: Border.all(
                        color: isToday
                            ? Colors.orange
                            : isActive
                                ? Colors.orange.withOpacity(0.5)
                                : Colors.transparent,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.local_fire_department_rounded
                          : Icons.circle_outlined,
                      size: isActive ? 20 : 14,
                      color: isActive ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget buildNextMilestoneCard(AppThemeColors colors, bool isDark) {
    final milestone = nextMilestone;
    final remaining = (milestone.days - _currentStreak).clamp(0, milestone.days);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: milestone.color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: milestone.color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: milestone.color.withOpacity(0.18),
                child: Icon(milestone.icon, color: milestone.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Next Goal: ${milestone.title}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colors.primaryText,
                      ),
                    ),
                    Text(
                      milestone.reward,
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "$_currentStreak/${milestone.days}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: milestone.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: milestoneProgress,
              minHeight: 12,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(milestone.color),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remaining == 0
                    ? "Goal Achieved! Tap to celebrate 🎉"
                    : "$remaining day${remaining == 1 ? '' : 's'} remaining",
                style: TextStyle(
                  color: remaining == 0 ? milestone.color : colors.secondaryText,
                  fontWeight: remaining == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              if (_currentStreak >= milestone.days)
                GestureDetector(
                  onTap: () => _showCelebrationDialog(milestone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: milestone.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Celebrate 🎉",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMilestoneCard(
      StreakMilestone milestone, AppThemeColors colors, bool isDark) {
    final bool unlocked = _currentStreak >= milestone.days;

    return GestureDetector(
      onTap: () {
        if (unlocked) {
          _showCelebrationDialog(milestone);
        } else {
          ToastService.info(
            context,
            "Locked Milestone",
            "Reach ${milestone.days} days streak to unlock ${milestone.title}!",
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked
              ? milestone.color.withOpacity(isDark ? 0.12 : 0.08)
              : isDark
                  ? const Color(0xFF1E293B).withOpacity(0.6)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: unlocked
                ? milestone.color
                : Colors.grey.withOpacity(0.2),
            width: unlocked ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (unlocked)
              BoxShadow(
                color: milestone.color.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (unlocked)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: milestone.color.withOpacity(0.2),
                    ),
                  ),
                Icon(
                  unlocked ? milestone.icon : Icons.lock_outline_rounded,
                  color: unlocked ? milestone.color : Colors.grey,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              milestone.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: unlocked ? colors.primaryText : Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              "${milestone.days} Days",
              style: TextStyle(
                color: unlocked ? milestone.color : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTipsCard(AppThemeColors colors, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded, color: Colors.amber),
              const SizedBox(width: 10),
              Text(
                "Streak Master Rules",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildTipRow(
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
            text: "Open Countify & increment any counter daily.",
          ),
          const SizedBox(height: 12),
          buildTipRow(
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFF97316),
            text: "Skipping a full day resets your active streak.",
          ),
          const SizedBox(height: 12),
          buildTipRow(
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFF59E0B),
            text: "Tap unlocked milestone cards to celebrate & share!",
          ),
        ],
      ),
    );
  }

  Widget buildTipRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class LiveFlameWidget extends StatefulWidget {
  final double size;
  final bool isLarge;

  const LiveFlameWidget({
    super.key,
    this.size = 60,
    this.isLarge = false,
  });

  @override
  State<LiveFlameWidget> createState() => _LiveFlameWidgetState();
}

class _LiveFlameWidgetState extends State<LiveFlameWidget>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late AnimationController _flickerController;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flameController.dispose();
    _flickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_flameController, _flickerController]),
      builder: (context, child) {
        final flameVal = _flameController.value;
        final flickerVal = _flickerController.value;

        final scale = 0.96 + (flameVal * 0.08) + (flickerVal * 0.03);
        final angle = (flameVal - 0.5) * 0.08;
        final auraSize = size * (1.2 + (flameVal * 0.25));

        return SizedBox(
          width: auraSize,
          height: auraSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulsing Red/Orange Fire Aura
              Container(
                width: auraSize * 0.9,
                height: auraSize * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.deepOrange.withOpacity(0.45 * flameVal),
                      Colors.orangeAccent.withOpacity(0.2 * flickerVal),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Rotating Spark Ring
              Transform.rotate(
                angle: flameVal * math.pi * 2,
                child: Container(
                  width: size * 1.1,
                  height: size * 1.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.25 * flameVal),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Animated Sparks
              Positioned(
                top: size * (0.15 - (flickerVal * 0.1)),
                right: size * (0.2 + (flameVal * 0.05)),
                child: Container(
                  width: 4 + (flickerVal * 2),
                  height: 4 + (flickerVal * 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amberAccent.withOpacity(0.8 * flameVal),
                  ),
                ),
              ),
              Positioned(
                top: size * (0.25 - (flameVal * 0.12)),
                left: size * (0.2 + (flickerVal * 0.05)),
                child: Container(
                  width: 3 + (flameVal * 2),
                  height: 3 + (flameVal * 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orangeAccent.withOpacity(0.9 * flickerVal),
                  ),
                ),
              ),

              // Main Burning Flame Icon
              Transform.translate(
                offset: Offset(0, -flameVal * 2),
                child: Transform.rotate(
                  angle: angle,
                  child: Transform.scale(
                    scale: scale,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.red.shade700,
                            Colors.deepOrange,
                            Colors.orange,
                            Color.lerp(Colors.amber, Colors.white, flickerVal)!,
                          ],
                          stops: const [0.0, 0.35, 0.7, 1.0],
                        ).createShader(bounds);
                      },
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: size,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}