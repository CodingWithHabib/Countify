import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import '../services/toast_service.dart';
import '../models/counter_model.dart';
import '../models/history_entry.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/analytics_chart.dart';
import '../widgets/statistics_card.dart';
import '../widgets/live_animated_icon.dart';

class StatisticsScreen extends StatefulWidget {
  final int currentCount;
  final int highestCount;
  final int increaseCount;
  final int decreaseCount;
  final int resetCount;
  final int currentStreak;
  final int bestStreak;
  final int dailyGoal;

  const StatisticsScreen({
    super.key,
    required this.currentCount,
    required this.highestCount,
    required this.increaseCount,
    required this.decreaseCount,
    required this.resetCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.dailyGoal,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late int _currentCount;
  late int _highestCount;
  late int _increaseCount;
  late int _decreaseCount;
  late int _resetCount;
  late int _currentStreak;
  late int _bestStreak;
  late int _dailyGoal;
  bool _isLoading = true;

  // Multi-Scope & Filter State
  List<CounterModel> _counters = [];
  List<HistoryEntry> _historyEntries = [];
  String _selectedCounterId = "all";
  Map<String, int> _selectedCounterStats = {};
  String _selectedPeriod = "All Time"; // All Time, Today, This Week, This Month

  late AnimationController _pulseController;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.currentCount;
    _highestCount = widget.highestCount;
    _increaseCount = widget.increaseCount;
    _decreaseCount = widget.decreaseCount;
    _resetCount = widget.resetCount;
    _currentStreak = widget.currentStreak;
    _bestStreak = widget.bestStreak;
    _dailyGoal = widget.dailyGoal;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseController.repeat(reverse: true);

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _bgAnimationController.repeat(reverse: true);

    _loadFreshStats();
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadFreshStats();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadFreshStats() async {
    try {
      final stats = await StorageService.loadStatistics();
      final highest = await StorageService.loadHighestCount();
      final streakData = await StorageService.loadStreak();
      final goal = await StorageService.loadDailyGoal();
      final counters = await StorageService.loadCounters();
      final history = await StorageService.loadHistoryEntries();

      if (mounted) {
        setState(() {
          _increaseCount = stats["increaseCount"] ?? widget.increaseCount;
          _decreaseCount = stats["decreaseCount"] ?? widget.decreaseCount;
          _resetCount = stats["resetCount"] ?? widget.resetCount;
          _highestCount = highest > 0 ? highest : widget.highestCount;
          _currentStreak = streakData["currentStreak"] ?? widget.currentStreak;
          _bestStreak = streakData["bestStreak"] ?? widget.bestStreak;
          _dailyGoal = goal > 0 ? goal : widget.dailyGoal;
          _counters = counters;
          _historyEntries = history;
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

  Future<void> _updateSelectedCounterScope(String id) async {
    if (id == "all") {
      setState(() {
        _selectedCounterId = "all";
        _selectedCounterStats = {};
      });
    } else {
      final stats = await StorageService.loadCounterStatistics(id);
      if (mounted) {
        setState(() {
          _selectedCounterId = id;
          _selectedCounterStats = stats;
        });
      }
    }
  }

  // Filtered History Entries for Period & Selected Counter
  List<HistoryEntry> get _filteredHistory {
    final now = DateTime.now();

    return _historyEntries.where((entry) {
      // Counter Filter
      if (_selectedCounterId != "all" && entry.counterId != _selectedCounterId) {
        return false;
      }

      // Time Period Filter
      final dt = entry.timestamp;
      if (_selectedPeriod == "Today") {
        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
      } else if (_selectedPeriod == "This Week") {
        final diff = now.difference(dt).inDays;
        return diff >= 0 && diff < 7;
      } else if (_selectedPeriod == "This Month") {
        return dt.year == now.year && dt.month == now.month;
      }
      return true; // All Time
    }).toList();
  }

  // Calculate Metrics based on active scope
  int get activeIncreaseCount {
    final historyCount = _filteredHistory
        .where((e) => e.action == HistoryAction.increase)
        .length;

    if (_selectedPeriod == "All Time") {
      if (_selectedCounterId == "all") return _increaseCount;
      if (historyCount > 0) return historyCount;
      return _selectedCounterStats["increaseCount"] ?? 0;
    }
    return historyCount;
  }

  int get activeDecreaseCount {
    final historyCount = _filteredHistory
        .where((e) => e.action == HistoryAction.decrease)
        .length;

    if (_selectedPeriod == "All Time") {
      if (_selectedCounterId == "all") return _decreaseCount;
      if (historyCount > 0) return historyCount;
      return _selectedCounterStats["decreaseCount"] ?? 0;
    }
    return historyCount;
  }

  int get activeResetCount {
    final historyCount = _filteredHistory
        .where((e) => e.action == HistoryAction.reset)
        .length;

    if (_selectedPeriod == "All Time") {
      if (_selectedCounterId == "all") return _resetCount;
      if (historyCount > 0) return historyCount;
      return _selectedCounterStats["resetCount"] ?? 0;
    }
    return historyCount;
  }

  int get activeTotalActions =>
      activeIncreaseCount + activeDecreaseCount + activeResetCount;

  int get activeCurrentCount {
    if (_selectedCounterId == "all") return _currentCount;
    final counter = _counters.firstWhere(
      (c) => c.id == _selectedCounterId,
      orElse: () => CounterModel(
        id: "",
        name: "",
        count: _currentCount,
        highestCount: _highestCount,
      ),
    );
    return counter.count;
  }

  int get activeHighestCount {
    if (_selectedCounterId == "all") return _highestCount;
    final counter = _counters.firstWhere(
      (c) => c.id == _selectedCounterId,
      orElse: () => CounterModel(
        id: "",
        name: "",
        count: _currentCount,
        highestCount: _highestCount,
      ),
    );
    return counter.highestCount;
  }

  double get productivityScore {
    final total = activeTotalActions;
    if (total == 0) return 0.0;
    final double actionRatio = (activeIncreaseCount / total);
    final double goalRatio =
        _dailyGoal > 0 ? (activeCurrentCount / _dailyGoal).clamp(0.0, 1.0) : 0.5;
    return ((actionRatio * 0.6 + goalRatio * 0.4) * 100).clamp(0.0, 100.0);
  }

  String get masteryRating {
    final score = productivityScore;
    if (score >= 85) return "Master Legend 👑";
    if (score >= 65) return "Unstoppable Achiever ⚡";
    if (score >= 45) return "Steady Progress 📈";
    return "Getting Started 🚀";
  }

  // Peak Hour & Time Distribution Analysis
  Map<String, dynamic> get _hourlyPeakAnalysis {
    try {
      final history = _filteredHistory;
      if (history.isEmpty) {
        return {
          "peakHour": "N/A",
          "peakCount": 0,
          "morning": 0,
          "afternoon": 0,
          "evening": 0,
          "night": 0,
        };
      }

      final Map<int, int> hourCounts = {};
      int morning = 0; // 6:00 - 11:59
      int afternoon = 0; // 12:00 - 17:59
      int evening = 0; // 18:00 - 23:59
      int night = 0; // 0:00 - 5:59

      for (var entry in history) {
        final hour = entry.timestamp.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;

        if (hour >= 6 && hour < 12) {
          morning++;
        } else if (hour >= 12 && hour < 18) {
          afternoon++;
        } else if (hour >= 18 && hour < 24) {
          evening++;
        } else {
          night++;
        }
      }

      int bestHour = 0;
      int maxCount = 0;
      hourCounts.forEach((h, c) {
        if (c > maxCount) {
          maxCount = c;
          bestHour = h;
        }
      });

      final startFormat = DateFormat("hh a").format(DateTime(2025, 1, 1, bestHour));
      final endFormat = DateFormat("hh a").format(DateTime(2025, 1, 1, (bestHour + 1) % 24));

      return {
        "peakHour": "$startFormat - $endFormat",
        "peakCount": maxCount,
        "morning": morning,
        "afternoon": afternoon,
        "evening": evening,
        "night": night,
      };
    } catch (_) {
      return {
        "peakHour": "N/A",
        "peakCount": 0,
        "morning": 0,
        "afternoon": 0,
        "evening": 0,
        "night": 0,
      };
    }
  }

  // Category Distribution Analysis
  Map<String, int> get _categoryDistribution {
    final Map<String, int> distribution = {};
    for (var counter in _counters) {
      final cat = counter.category.isEmpty ? "General" : counter.category;
      distribution[cat] = (distribution[cat] ?? 0) + counter.count;
    }
    return distribution;
  }

  void _shareDetailedReport() {
    ShareService.shareStatistics(
      currentCount: activeCurrentCount,
      highestCount: activeHighestCount,
      currentStreak: _currentStreak,
      bestStreak: _bestStreak,
      increaseCount: activeIncreaseCount,
      decreaseCount: activeDecreaseCount,
      resetCount: activeResetCount,
    );
  }

  Future<void> _confirmResetStats() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final colors = Theme.of(ctx).extension<AppThemeColors>()!;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.amber.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LiveAnimatedIcon(
                      icon: Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 44,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "ANALYTICS RESET ⚠️",
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Reset Analytics?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  _selectedCounterId == "all"
                      ? "Are you sure you want to reset all global action statistics? This action cannot be undone."
                      : "Are you sure you want to reset statistics for this specific counter?",
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300,
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: colors.primaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          "Reset Stats",
                          style: TextStyle(
                            color: Colors.white,
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

    if (confirm == true) {
      if (_selectedCounterId == "all") {
        await StorageService.resetStatistics();
      } else {
        await StorageService.resetCounterStatistics(_selectedCounterId);
      }
      await _loadFreshStats();

      if (mounted) {
        ToastService.success(
          context,
          "Statistics Reset",
          "Action metrics have been successfully reset.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final peakInfo = _hourlyPeakAnalysis;
    final categoryMap = _categoryDistribution;

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
              icon: Icons.analytics_rounded,
              color: Color(0xFF3B82F6),
              size: 28,
              iconSize: 15,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                "Analytics & Stats",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: "Export Analytics Report",
            onPressed: _shareDetailedReport,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: "Reset Action Stats",
            onPressed: _confirmResetStats,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Moving Ambient Background Mesh
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              final double progress = _bgAnimationController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (progress * 40),
                    left: -80 + (progress * 30),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3B82F6)
                              .withOpacity(isDark ? 0.12 : 0.15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100 - (progress * 50),
                    right: -60 + (progress * 20),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B5CF6)
                              .withOpacity(isDark ? 0.10 : 0.12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Scope Selector (All Counters + Specific Counters)
                        if (_counters.isNotEmpty) ...[
                          _buildCounterScopeFilter(colors, isDark),
                          const SizedBox(height: 12),
                        ],

                        // Time Period Switcher Pills
                        _buildPeriodFilterBar(colors, isDark),
                        const SizedBox(height: 18),

                        // Productivity & Efficiency Gauge
                        _buildProductivityScoreCard(colors, isDark),
                        const SizedBox(height: 18),

                        // Overview Metric Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildAnimatedStatCard(
                                title: "Current",
                                value: activeCurrentCount,
                                icon: Icons.countertops_rounded,
                                color: const Color(0xFF3B82F6),
                                colors: colors,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildAnimatedStatCard(
                                title: "Highest",
                                value: activeHighestCount,
                                icon: Icons.emoji_events_rounded,
                                color: const Color(0xFFF59E0B),
                                colors: colors,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildAnimatedStatCard(
                                title: "Streak",
                                value: _currentStreak,
                                icon: Icons.local_fire_department_rounded,
                                color: const Color(0xFFEF4444),
                                colors: colors,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Interactive Chart Section
                        AnalyticsChart(
                          increaseCount: activeIncreaseCount,
                          decreaseCount: activeDecreaseCount,
                          resetCount: activeResetCount,
                        ),

                        const SizedBox(height: 20),

                        // Detailed Action Breakdown Card
                        StatisticsCard(
                          increaseCount: activeIncreaseCount,
                          decreaseCount: activeDecreaseCount,
                          resetCount: activeResetCount,
                        ),

                        const SizedBox(height: 22),

                        // Peak Hourly Activity & Time Distribution Card
                        _buildHourlyPeakCard(peakInfo, colors, isDark),

                        const SizedBox(height: 22),

                        // Category Breakdown Card (if counters exist)
                        if (categoryMap.isNotEmpty) ...[
                          _buildCategoryBreakdownCard(categoryMap, colors, isDark),
                          const SizedBox(height: 22),
                        ],

                        // Total Actions Tile
                        _buildTotalActionsTile(colors, isDark),

                        const SizedBox(height: 22),

                        // Quick Insights Section
                        Text(
                          "Smart Performance Insights",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildInsightTile(
                          context: context,
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF10B981),
                          title: "Primary Action Preference",
                          value: activeIncreaseCount >= activeDecreaseCount &&
                                  activeIncreaseCount >= activeResetCount
                              ? "Increments (${activeTotalActions == 0 ? 0 : ((activeIncreaseCount / activeTotalActions) * 100).toInt()}%)"
                              : activeDecreaseCount >= activeResetCount
                                  ? "Decrements"
                                  : "Resets",
                          isDark: isDark,
                        ),
                        _buildInsightTile(
                          context: context,
                          icon: Icons.flag_rounded,
                          color: const Color(0xFF3B82F6),
                          title: "Daily Target Completion",
                          value: activeCurrentCount >= _dailyGoal && _dailyGoal > 0
                              ? "Target Completed! 🎉"
                              : "$activeCurrentCount / $_dailyGoal Counts",
                          isDark: isDark,
                        ),
                        _buildInsightTile(
                          context: context,
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFF97316),
                          title: "Streak Consistency",
                          value: "$_currentStreak Day${_currentStreak == 1 ? '' : 's'} (Best: $_bestStreak)",
                          isDark: isDark,
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Counter Filter Chips Row
  Widget _buildCounterScopeFilter(AppThemeColors colors, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const LiveAnimatedIcon(
              icon: Icons.tune_rounded,
              color: Color(0xFF8B5CF6),
              size: 28,
              iconSize: 15,
            ),
            const SizedBox(width: 8),
            Text(
              "Analytics Scope",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colors.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildCounterChip(
                id: "all",
                name: "All Counters",
                isSelected: _selectedCounterId == "all",
                isDark: isDark,
                colors: colors,
              ),
              ..._counters.map(
                (c) => _buildCounterChip(
                  id: c.id,
                  name: c.name,
                  isSelected: _selectedCounterId == c.id,
                  isDark: isDark,
                  colors: colors,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterChip({
    required String id,
    required String name,
    required bool isSelected,
    required bool isDark,
    required AppThemeColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : colors.primaryText,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF3B82F6),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : (isDark ? Colors.white12 : Colors.black12),
          ),
        ),
        onSelected: (val) {
          if (val) {
            _updateSelectedCounterScope(id);
          }
        },
      ),
    );
  }

  // Period Filter Switcher Pills
  Widget _buildPeriodFilterBar(AppThemeColors colors, bool isDark) {
    final periods = ["All Time", "Today", "This Week", "This Month"];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
        ),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : colors.secondaryText,
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

  // Productivity Score Gauge Banner
  Widget _buildProductivityScoreCard(AppThemeColors colors, bool isDark) {
    final score = productivityScore;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 7.5,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${score.toInt()}%",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LiveAnimatedIcon(
                      icon: Icons.stars_rounded,
                      color: Color(0xFFF59E0B),
                      size: 26,
                      iconSize: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "EFFICIENCY RATING",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  masteryRating,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Based on action consistency, goal progress & period activity.",
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Animated Stat Card
  Widget _buildAnimatedStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark
            ? color.withOpacity(0.08)
            : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
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
        children: [
          LiveAnimatedIcon(
            icon: icon,
            color: color,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                val.toInt().toString(),
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
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
    );
  }

  // Peak Hourly Activity Card
  Widget _buildHourlyPeakCard(
      Map<String, dynamic> peakInfo, AppThemeColors colors, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiveAnimatedIcon(
                icon: Icons.access_time_filled_rounded,
                color: Colors.amber,
                size: 38,
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Peak Activity Time",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    Text(
                      "Most productive hour of the day",
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  peakInfo["peakHour"] ?? "N/A",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Time distribution breakdown
          Row(
            children: [
              Expanded(
                child: _buildTimeQuadPill(
                  label: "Morning",
                  icon: Icons.wb_twilight_rounded,
                  count: peakInfo["morning"] ?? 0,
                  color: const Color(0xFFF59E0B),
                  colors: colors,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeQuadPill(
                  label: "Afternoon",
                  icon: Icons.wb_sunny_rounded,
                  count: peakInfo["afternoon"] ?? 0,
                  color: const Color(0xFFEF4444),
                  colors: colors,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeQuadPill(
                  label: "Evening",
                  icon: Icons.nights_stay_rounded,
                  count: peakInfo["evening"] ?? 0,
                  color: const Color(0xFF8B5CF6),
                  colors: colors,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTimeQuadPill(
                  label: "Night",
                  icon: Icons.bedtime_rounded,
                  count: peakInfo["night"] ?? 0,
                  color: const Color(0xFF3B82F6),
                  colors: colors,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeQuadPill({
    required String label,
    required IconData icon,
    required int count,
    required Color color,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: colors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Category Breakdown Card
  Widget _buildCategoryBreakdownCard(
      Map<String, int> categories, AppThemeColors colors, bool isDark) {
    final totalCounts = categories.values.fold(0, (a, b) => a + b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.teal.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiveAnimatedIcon(
                icon: Icons.category_rounded,
                color: Colors.teal,
                size: 38,
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Text(
                "Category Volume",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...categories.entries.map((e) {
            final double pct =
                totalCounts > 0 ? (e.value / totalCounts) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.primaryText,
                        ),
                      ),
                      Text(
                        "${e.value} counts (${(pct * 100).toInt()}%)",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 5,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(Colors.teal),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Total Actions Tile
  Widget _buildTotalActionsTile(AppThemeColors colors, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const LiveAnimatedIcon(
            icon: Icons.touch_app_rounded,
            color: Colors.purple,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Interactive Action Volume",
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: activeTotalActions.toDouble()),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) {
                    return Text(
                      "${val.toInt()} Actions Executed",
                      style: TextStyle(
                        color: colors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required bool isDark,
  }) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          LiveAnimatedIcon(
            icon: icon,
            color: color,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
