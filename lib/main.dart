import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'package:countify/widgets/liquid_button.dart';
import 'widgets/statistics_card.dart';
import 'widgets/highest_count_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dialogs/history_dialog.dart';
import 'models/achievement.dart';
import 'services/achievement_service.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/achievement_dialog.dart';
import 'services/counter_service.dart';
import 'screens/achievement_screen.dart';
import 'services/vibration_service.dart';
import 'services/sound_service.dart';
import 'theme/app_theme_colors.dart';
import 'screens/settings_screen.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'services/toast_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThemeService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void refreshTheme() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      darkTheme: AppTheme.dark,

      themeMode: ThemeService.themeMode,

      home: const Countify(),
    );
  }
}
class Countify extends StatefulWidget {
  const Countify({super.key});

  @override
  State<Countify> createState() => _CountifyState();
}

class _CountifyState extends State<Countify> {
  int count = 0;
  int increaseCountValue = 0;
  int decreaseCountValue = 0;
  int resetCountValue = 0;
  List<String> history = [];

  int highestCount = 0;
  int dailyGoal = 100;
  bool goalCompleted = false;

  Color countColor = AppColors.white;
  double counterScale = 1.0;
  Set<int> unlockedAchievements = {};
  DateTime? _lastResetToastTime;
  Future<void> increaseCount() async {
    setState(() {
      count = CounterService.increase(count);
      increaseCountValue++;

      countColor = AppColors.success;

      if (count > highestCount) {
        highestCount = count;
      }

      // Bigger punch
      counterScale = 1.15;

      history.add(
        "🟢 Count Increased\n"
            "Count: $count\n"
            "${getFormattedDateTime()}",
      );
      saveHighestCount();
      saveCount();
      saveHistory();
      saveStatistics();
    });
    await checkAchievement();
    // Scale Back
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;

      setState(() {
        counterScale = 1.0;
      });
    });

    // Color Back
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        countColor = Theme.of(context)
            .extension<AppThemeColors>()!
            .primaryText;
      });
    });
  }
  void decreaseCount() {
    if (count <= 0) return;

    setState(() {
      count--;
      decreaseCountValue++;

      countColor = AppColors.danger;

      // Bigger punch
      counterScale = 1.15;

      history.add(
        "🔴 Count Decreased\n"
            "Count: $count\n"
            "${getFormattedDateTime()}",
      );
      saveCount();
      saveHistory();
      saveStatistics();
    });

    // Scale Back
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;

      setState(() {
        counterScale = 1.0;
      });
    });

    // Color Back
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        countColor = Theme.of(context)
            .extension<AppThemeColors>()!
            .primaryText;
      });
    });
  }
  void resetCount() {
    setState(() {
      count = 0;
      resetCountValue++;
      countColor = Colors.orange;
      counterScale = 1.1;

      history.add(
        "🟠 Counter Reset\n"
            "Count: $count\n"
            "${getFormattedDateTime()}",
      );
      saveCount();
      saveHistory();
      saveStatistics();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          countColor = Theme.of(context)
              .extension<AppThemeColors>()!
              .primaryText;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          counterScale = 1.0;
        });
      }
    });
  }
  void showResetToast(bool alreadyZero) {
    final now = DateTime.now();

    if (_lastResetToastTime != null &&
        now.difference(_lastResetToastTime!) <
            const Duration(seconds: 2)) {
      return;
    }

    _lastResetToastTime = now;

    if (alreadyZero) {
      ToastService.info(
        context,
        "Already Reset",
        "Counter is already 0.",
      );
    } else {
      ToastService.success(
        context,
        "Counter Reset",
        "Counter reset successfully.",
      );
    }
  }
  Future<void> checkAchievement() async {
    final achievement =
    AchievementService.checkAchievement(count);

    if (achievement == null) return;

    if (unlockedAchievements.contains(
        achievement.milestone)) {
      return;
    }

    unlockedAchievements.add(
        achievement.milestone);

    await saveAchievements();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AchievementDialog(
        title: achievement.title,
        description: achievement.description,
      ),
    );
  }
  double get goalProgress {
    if (dailyGoal == 0) return 0;
    return (count / dailyGoal).clamp(0.0, 1.0);
  }
  String getFormattedDateTime() {
    final now = DateTime.now();

    final date = DateFormat("dd MMM yyyy").format(now);
    final time = DateFormat("hh:mm:ss a").format(now);

    return "📅 $date\n🕒 $time";
  }
  Future<void> saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();

  await  prefs.setStringList(
      "unlockedAchievements",
      unlockedAchievements
          .map((e) => e.toString())
          .toList(),
    );
  }

  Future<void> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();

    final list =
        prefs.getStringList("unlockedAchievements") ?? [];

    unlockedAchievements =
        list.map((e) => int.parse(e)).toSet();
  }
  Future<void> loadCount() async {
    final loadedCount = await StorageService.loadCount();
    final loadedHighestCount = await StorageService.loadHighestCount();
    final loadedHistory = await StorageService.loadHistory();
    final statistics = await StorageService.loadStatistics();
    final loadedAchievements = await StorageService.loadAchievements();
    final loadedGoal = await StorageService.loadDailyGoal();

    setState(() {

      count = loadedCount;
      highestCount = loadedHighestCount;
      history = loadedHistory;
      dailyGoal = loadedGoal;

      increaseCountValue = statistics["increaseCount"]!;
      decreaseCountValue = statistics["decreaseCount"]!;
      resetCountValue = statistics["resetCount"]!;
      unlockedAchievements = loadedAchievements;
    });
  }
  Future<void> saveCount() async {
    await StorageService.saveCount(count);
  }
  Future<void> saveHighestCount() async {
    await StorageService.saveHighestCount(highestCount);
  }
  Future<void> saveHistory() async {
    await StorageService.saveHistory(history);
  }
  Future<void> saveStatistics() async {
    await StorageService.saveStatistics(
      increaseCount: increaseCountValue,
      decreaseCount: decreaseCountValue,
      resetCount: resetCountValue,
    );
  }
  @override
  void initState() {
    super.initState();
    SoundService.init();
    VibrationService.init();
    loadCount();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
    Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final counterFontSize = screenWidth > 600 ? 90.0 : screenWidth * 0.18;
    final sectionSpacing = screenWidth > 600 ? 35.0 : 25.0;
    if (countColor == AppColors.white) {
      countColor = colors.primaryText;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.grey.shade300,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1.5,
            color: isDark
                ? Colors.white24
                : Colors.grey.shade300,
          ),
        ),
        title:  Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_graph_rounded,
              color: colors.primaryText,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              "Countify",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colors.primaryText,
                letterSpacing: 1,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                showHistoryDialog(
                  context: context,
                  history: history,
                  onClearHistory: () {
                    setState(() {
                      history.clear();
                    });
                    saveHistory();
                  },
                );
              },
              icon:  Icon(
                Icons.history_rounded,
                color: colors.primaryText,
                size: 28,
              ),

            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );

                final goal = await StorageService.loadDailyGoal();

                setState(() {
                  dailyGoal = goal;
                });
              },
              icon:  Icon(
                Icons.settings_rounded,
                color: colors.primaryText,
                size: 28,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            color: Color(0xFFFFD700), // Gold

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AchievementScreen(
                    unlockedAchievements: unlockedAchievements,
                  ),
                ),
              );
            },
          ),
        ],
      ),
        body: SafeArea(
          child: Container(
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.gradientStart,
                colors.gradientMiddle,
                colors.gradientEnd,
              ],
            ),
          ),
          child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Text(
                  "Current Count",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    transform: Matrix4.identity()..scale(counterScale),
                    transformAlignment: Alignment.center,

                    width: screenWidth > 600 ? 320 : screenWidth * 0.7,
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 25,
                    ),

                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: countColor.withOpacity(0.35),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? countColor.withOpacity(counterScale > 1 ? 0.55 : 0.22)
                              : Colors.blue.withOpacity(counterScale > 1 ? 0.20 : 0.10),
                          blurRadius: counterScale > 1 ? 40 : 20,
                          spreadRadius: counterScale > 1 ? 6 : 2,
                          offset: const Offset(0, 10),

                        ),
                      ],
                    ),

                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.65,
                              end: 1.0,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          "$count",
                          key: ValueKey(count),
                          style:  TextStyle(
                            fontSize: counterFontSize,
                            fontWeight: FontWeight.w800,
                            color: countColor,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: countColor.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sectionSpacing),
                DailyGoalCard(
                  count: count,
                  dailyGoal: dailyGoal,
                ),

                SizedBox(height: sectionSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LiquidButton(
                      icon: Icons.add,
                      color: Colors.green.shade300,
                      onPressed: increaseCount,
                    ),
                    const SizedBox(width: 20),
                    LiquidButton(
                      icon: Icons.remove,
                      color: Colors.red.shade300,
                      onPressed: decreaseCount,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                LiquidButton(
                  icon: Icons.refresh,
                  color: Colors.orange.shade100,
                  onPressed: () {
                    if (count > 0) {
                      resetCount();
                      showResetToast(false);
                    } else {
                      showResetToast(true);
                    }
                  },
                ),
                const SizedBox(height: 25),
                HighestCountCard(
                  highestCount: highestCount,
                ),
                const SizedBox(height: 20),
                StatisticsCard(
                  increaseCount: increaseCountValue,
                  decreaseCount: decreaseCountValue,
                  resetCount: resetCountValue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}