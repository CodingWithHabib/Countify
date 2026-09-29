import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/live_animated_icon.dart';

const List<String> achievementCategories = [
  "Beginner",
  "Intermediate",
  "Advanced",
  "Legendary",
];

class AchievementScreen extends StatefulWidget {
  final Set<int> unlockedAchievements;
  final int currentCount;

  const AchievementScreen({
    super.key,
    required this.unlockedAchievements,
    required this.currentCount,
  });

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with TickerProviderStateMixin {
  Set<String> expandedCategories = {
    "Beginner",
    "Intermediate",
    "Advanced",
    "Legendary",
  };

  String activeFilter = "All"; // All, Unlocked, Locked
  bool isLoading = true;

  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _loadExpandedCategories();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  // Load saved open/close category state from SharedPreferences
  Future<void> _loadExpandedCategories() async {
    final saved = await StorageService.loadExpandedAchievementCategories();
    if (mounted) {
      setState(() {
        expandedCategories = saved;
        isLoading = false;
      });
    }
  }

  // Save open/close state to SharedPreferences
  Future<void> _toggleCategory(String category) async {
    setState(() {
      if (expandedCategories.contains(category)) {
        expandedCategories.remove(category);
      } else {
        expandedCategories.add(category);
      }
    });
    await StorageService.saveExpandedAchievementCategories(expandedCategories);
  }

  // Toggle Expand All / Collapse All
  Future<void> _toggleExpandAll() async {
    setState(() {
      if (expandedCategories.length == achievementCategories.length) {
        expandedCategories.clear();
      } else {
        expandedCategories = Set.from(achievementCategories);
      }
    });
    await StorageService.saveExpandedAchievementCategories(expandedCategories);
  }

  String get rankTitle {
    final total = achievements.length;
    final unlocked = widget.unlockedAchievements.length;
    final pct = total > 0 ? unlocked / total : 0.0;

    if (pct >= 1.0) return "Countify Immortal 👑";
    if (pct >= 0.75) return "Grandmaster Rank 🏆";
    if (pct >= 0.50) return "Pro Achiever ⚡";
    if (pct >= 0.25) return "Rising Star 📈";
    return "Novice Pioneer 🌱";
  }

  void _showAchievementDetailDialog(
      Achievement achievement, bool isUnlocked) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final colors = Theme.of(ctx).extension<AppThemeColors>()!;
        final progress = (widget.currentCount / achievement.milestone)
            .clamp(0.0, 1.0);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isUnlocked
                    ? Colors.amber.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUnlocked ? Colors.amber : Colors.blue)
                      .withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LiveAnimatedIcon(
                  icon: isUnlocked ? achievement.icon : Icons.lock_rounded,
                  color: isUnlocked ? Colors.amber : Colors.grey,
                  size: 72,
                  iconSize: 36,
                ),
                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isUnlocked ? Colors.green : Colors.amber)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    isUnlocked
                        ? "UNLOCKED BADGE 🔓"
                        : "MILESTONE TARGET 🎯",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isUnlocked ? Colors.green : Colors.amber,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                  ),
                ),

                const SizedBox(height: 18),

                if (!isUnlocked) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Progress",
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${widget.currentCount} / ${achievement.milestone}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? Colors.white12
                          : Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.amber),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                Row(
                  children: [
                    if (isUnlocked) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(color: Colors.amber),
                          ),
                          icon: const Icon(Icons.share_rounded,
                              size: 18, color: Colors.amber),
                          label: const Text(
                            "Share",
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text:
                                    "🏆 I unlocked the '${achievement.title}' achievement on Countify! ${achievement.description} 🚀",
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isUnlocked ? Colors.amber : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          isUnlocked ? "Awesome!" : "Close",
                          style: TextStyle(
                            color: isUnlocked ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final achievementList = achievements;
    final unlockedCount = widget.unlockedAchievements.length;
    final totalCount = achievementList.length;

    Achievement? nextAchievement;
    for (final achievement in achievementList) {
      if (!widget.unlockedAchievements.contains(achievement.milestone)) {
        nextAchievement = achievement;
        break;
      }
    }

    final allExpanded =
        expandedCategories.length == achievementCategories.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A).withOpacity(0.85)
            : Colors.white.withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LiveAnimatedIcon(
              icon: Icons.workspace_premium_rounded,
              color: Colors.amber,
              size: 32,
              iconSize: 17,
            ),
            const SizedBox(width: 8),
            Text(
              "Achievements",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colors.primaryText,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              allExpanded
                  ? Icons.unfold_less_rounded
                  : Icons.unfold_more_rounded,
            ),
            tooltip: allExpanded ? "Collapse All" : "Expand All",
            onPressed: _toggleExpandAll,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Moving Ambient Mesh Background
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              final double progress = _bgAnimationController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (progress * 30),
                    right: -60 + (progress * 20),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.withOpacity(isDark ? 0.12 : 0.15),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overall Progress Header Card
                        _buildHeaderCard(
                            unlockedCount: unlockedCount,
                            total: totalCount,
                            colors: colors,
                            isDark: isDark),

                        const SizedBox(height: 18),

                        // Filter Chips Bar (All | Unlocked | Locked)
                        _buildFilterBar(colors, isDark, unlockedCount, totalCount),

                        const SizedBox(height: 18),

                        // Next Target Achievement Card
                        if (nextAchievement != null && activeFilter != "Unlocked")
                          _buildNextAchievementCard(
                            nextAchievement: nextAchievement,
                            currentCount: widget.currentCount,
                            colors: colors,
                            isDark: isDark,
                          ),

                        const SizedBox(height: 12),

                        // Category Sections
                        for (final category in achievementCategories) ...[
                          _buildCategoryHeader(
                            category,
                            unlocked: achievementList
                                .where(
                                  (a) =>
                                      a.category == category &&
                                      widget.unlockedAchievements
                                          .contains(a.milestone),
                                )
                                .length,
                            total: achievementList
                                .where((a) => a.category == category)
                                .length,
                            colors: colors,
                            isDark: isDark,
                          ),

                          if (expandedCategories.contains(category))
                            ...achievementList
                                .where((a) => a.category == category)
                                .where((a) {
                              final isUnlocked = widget.unlockedAchievements
                                  .contains(a.milestone);
                              if (activeFilter == "Unlocked") return isUnlocked;
                              if (activeFilter == "Locked") return !isUnlocked;
                              return true; // All
                            }).map(
                              (achievement) => _buildAchievementCard(
                                achievement: achievement,
                                isUnlocked: widget.unlockedAchievements
                                    .contains(achievement.milestone),
                                colors: colors,
                                isDark: isDark,
                              ),
                            ),
                        ],

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Header Progress Card
  Widget _buildHeaderCard({
    required int unlockedCount,
    required int total,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    final progress = total > 0 ? unlockedCount / total : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const LiveAnimatedIcon(
                icon: Icons.workspace_premium_rounded,
                color: Colors.amber,
                size: 64,
                iconSize: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACHIEVEMENT STATUS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rankTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$unlockedCount of $total Badges Unlocked",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Colors.amber),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(progress * 100).toStringAsFixed(0)}% Completed",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.secondaryText,
                ),
              ),
              Text(
                "${total - unlockedCount} Remaining",
                style: TextStyle(
                  fontSize: 12,
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Filter Chips Bar
  Widget _buildFilterBar(
      AppThemeColors colors, bool isDark, int unlocked, int total) {
    final filters = [
      {"name": "All", "label": "All ($total)"},
      {"name": "Unlocked", "label": "Unlocked 🔓 ($unlocked)"},
      {"name": "Locked", "label": "Locked 🔒 (${total - unlocked})"},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: filters.map((f) {
          final name = f["name"]!;
          final label = f["label"]!;
          final isSelected = activeFilter == name;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  activeFilter = name;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.black : colors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Next Achievement Card
  Widget _buildNextAchievementCard({
    required Achievement nextAchievement,
    required int currentCount,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    final milestone = nextAchievement.milestone > 0 ? nextAchievement.milestone : 1;
    final progress = (currentCount / milestone).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const LiveAnimatedIcon(
            icon: Icons.flag_rounded,
            color: Colors.amber,
            size: 46,
            iconSize: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "NEXT MILESTONE TARGET",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: colors.secondaryText,
                      ),
                    ),
                    Text(
                      "$currentCount / $milestone",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  nextAchievement.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nextAchievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                        isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category Header
  Widget _buildCategoryHeader(
    String title, {
    required int unlocked,
    required int total,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    final isExpanded = expandedCategories.contains(title);
    final categoryColor = switch (title) {
      "Beginner" => const Color(0xFF10B981),
      "Intermediate" => const Color(0xFF3B82F6),
      "Advanced" => const Color(0xFF8B5CF6),
      "Legendary" => const Color(0xFFF59E0B),
      _ => Colors.grey,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: GestureDetector(
        onTap: () => _toggleCategory(title),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: categoryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              LiveAnimatedIcon(
                icon: switch (title) {
                  "Beginner" => Icons.star_rounded,
                  "Intermediate" => Icons.workspace_premium_rounded,
                  "Advanced" => Icons.military_tech_rounded,
                  "Legendary" => Icons.auto_awesome_rounded,
                  _ => Icons.emoji_events_rounded,
                },
                color: categoryColor,
                size: 38,
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "$unlocked / $total",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Achievement Card Item
  Widget _buildAchievementCard({
    required Achievement achievement,
    required bool isUnlocked,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    final milestone = achievement.milestone > 0 ? achievement.milestone : 1;
    final itemProgress =
        (widget.currentCount / milestone).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isUnlocked
              ? Colors.amber.withOpacity(0.4)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05)),
          width: 1.2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () =>
              _showAchievementDetailDialog(achievement, isUnlocked),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                LiveAnimatedIcon(
                  icon: isUnlocked ? achievement.icon : Icons.lock_rounded,
                  color: isUnlocked ? Colors.amber : Colors.grey,
                  size: 46,
                  iconSize: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${widget.currentCount} / $milestone",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${(itemProgress * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: itemProgress,
                            minHeight: 5,
                            backgroundColor: isDark
                                ? Colors.white12
                                : Colors.grey.shade200,
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.amber),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (isUnlocked ? Colors.green : Colors.grey)
                        .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    color: isUnlocked ? Colors.green : Colors.grey,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
