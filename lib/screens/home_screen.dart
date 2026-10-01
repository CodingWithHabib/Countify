import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme_colors.dart';

import '../services/storage_service.dart';
import '../services/counter_manager.dart';
import '../services/counter_service.dart';
import '../services/achievement_service.dart';
import '../services/vibration_service.dart';
import '../services/sound_service.dart';
import '../services/toast_service.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../models/history_entry.dart';
import '../models/counter_model.dart';
import '../models/streak_milestone.dart';

import '../widgets/achievement_overlay.dart';
import '../widgets/streak_milestone_dialog.dart';
import '../widgets/new_counter_dialog.dart';
import '../widgets/c_logo_painter.dart';
import '../dialogs/goal_dialog.dart';
import '../dialogs/more_tools_sheet.dart';

import 'streak_screen.dart';
import 'statistics_screen.dart';
import 'achievement_screen.dart';
import 'settings_screen.dart';
import 'category_hub_screen.dart';
import 'manage_counters_screen.dart';
import 'workspace_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int count = 0;
  int increaseCountValue = 0;
  int decreaseCountValue = 0;
  int resetCountValue = 0;
  List<String> history = [];
  List<HistoryEntry> historyEntries = [];
  int currentStreak = 0;
  int bestStreak = 0;
  int highestCount = 0;
  int dailyGoal = 100;
  String userName = "Habib";
  bool goalCompleted = false;

  Color countColor = AppColors.white;
  double counterScale = 1.0;
  Set<int> unlockedAchievements = {};
  DateTime? _lastResetToastTime;

  int _selectedBottomNavIndex = 0;

  late AnimationController _bgAnimationController;
  late AnimationController _ringPulseController;

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _ringPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    SoundService.init();
    VibrationService.init();
    _initBannerAd();
    loadCount().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkFirstTimeAuthPrompt();
      });
    });
  }

  void _initBannerAd() {
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: () {
        if (mounted) setState(() => _isBannerAdLoaded = true);
      },
      onAdFailed: (err) {
        if (mounted) setState(() => _isBannerAdLoaded = false);
      },
    );
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _ringPulseController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTimeAuthPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPromptedFirstLaunch =
        prefs.getBool("has_prompted_first_launch") ?? false;
    final isLoggedIn = prefs.getBool("auth_is_logged_in") ?? false;

    if (!hasPromptedFirstLaunch && !isLoggedIn && mounted) {
      await prefs.setBool("has_prompted_first_launch", true);
      _showFirstTimeWelcomeDialog();
    }
  }

  void _showFirstTimeWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF00E5FF).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.2),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Color(0xFF00E5FF), size: 26),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Welcome to Countify! ✨",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "To keep your counter data permanently saved across sessions, please Register or Sign In with your email & password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.app_registration_rounded,
                        color: Colors.black, size: 20),
                    label: const Text(
                      "REGISTER / SIGN IN ACCOUNT",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                            currentCount: count,
                            highestCount: highestCount,
                            currentStreak: currentStreak,
                            bestStreak: bestStreak,
                            unlockedAchievements: unlockedAchievements,
                          ),
                        ),
                      ).then((_) => loadCount());
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    icon: const Icon(Icons.timer_outlined,
                        color: Colors.amber, size: 18),
                    label: const Text(
                      "Continue as Guest (Unsaved Session)",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      await AuthService.signInAsGuest();
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      loadCount();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String get greetingText {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,";
    if (hour < 17) return "Good Afternoon,";
    return "Good Evening,";
  }

  Future<void> increaseCount() async {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    setState(() {
      count = CounterService.increase(count);
      increaseCountValue++;

      countColor = const Color(0xFF00E5FF);

      if (count > highestCount) {
        highestCount = count;
      }

      counterScale = 1.15; // Smooth bubble pop

      history.add(
        "🟢 Count Increased\n"
        "Count: $count\n"
        "${getFormattedDateTime()}",
      );
      saveHighestCount();
      saveCount();
      saveHistory();
      saveStatistics();
      addHistoryEntry(
        action: HistoryAction.increase,
        count: count,
      );
    });

    await updateStreak();
    await checkAchievement();

    if (count == dailyGoal) {
      AdService.showInterstitialAd();
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        counterScale = 1.0;
      });
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        countColor = colors.primaryText;
      });
    });
  }

  Future<void> updateStreak() async {
    final streakData = await StorageService.loadStreak();

    int currentStreak = streakData["currentStreak"] ?? 0;
    int bestStreak = streakData["bestStreak"] ?? 0;
    String lastActiveDate = streakData["lastActiveDate"] ?? "";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastActiveDate.isEmpty) {
      currentStreak = 1;
    } else {
      final parsed = DateTime.tryParse(lastActiveDate);
      if (parsed != null) {
        final lastDate = DateTime(parsed.year, parsed.month, parsed.day);
        final difference = today.difference(lastDate).inDays;
        if (difference == 1) {
          currentStreak++;
        } else if (difference > 1) {
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }

    await StorageService.saveStreak(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastActiveDate: now.toIso8601String(),
    );

    if (mounted) {
      setState(() {
        this.currentStreak = currentStreak;
        this.bestStreak = bestStreak;
      });
    }

    await _checkAndCelebrateStreakMilestone(currentStreak);
  }

  Future<void> _checkAndCelebrateStreakMilestone(int streak) async {
    if (streak <= 0) return;
    final milestone = StreakMilestone.getMilestoneForDays(streak);
    if (milestone != null) {
      final isAlreadyCelebrated =
          await StorageService.isStreakMilestoneCelebrated(streak);
      if (!isAlreadyCelebrated) {
        await StorageService.markStreakMilestoneCelebrated(streak);
        if (mounted) {
          StreakMilestoneDialog.show(context, milestone);
        }
      }
    }
  }

  void decreaseCount() {
    if (count <= 0) return;
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    setState(() {
      count--;
      decreaseCountValue++;

      countColor = const Color(0xFFEF4444);
      counterScale = 1.15; // Smooth bubble pop

      history.add(
        "🔴 Count Decreased\n"
        "Count: $count\n"
        "${getFormattedDateTime()}",
      );
      saveCount();
      saveHistory();
      saveStatistics();
      addHistoryEntry(
        action: HistoryAction.decrease,
        count: count,
      );
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        counterScale = 1.0;
      });
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        countColor = colors.primaryText;
      });
    });
  }

  void resetCount() {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    setState(() {
      count = 0;
      resetCountValue++;
      countColor = const Color(0xFFF59E0B);
      counterScale = 1.12;

      history.add(
        "🟠 Counter Reset\n"
        "Count: $count\n"
        "${getFormattedDateTime()}",
      );
      saveCount();
      saveHistory();
      saveStatistics();
      addHistoryEntry(
        action: HistoryAction.reset,
        count: count,
      );
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          countColor = colors.primaryText;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
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
        now.difference(_lastResetToastTime!) < const Duration(seconds: 2)) {
      return;
    }

    _lastResetToastTime = now;

    if (alreadyZero) {
      ToastService.info(context, "Already Reset", "Counter is already 0.");
    } else {
      ToastService.success(
        context,
        "Counter Reset",
        "Counter reset successfully.",
      );
    }
  }

  Future<void> checkAchievement() async {
    final achievement = AchievementService.checkAchievement(count);
    if (achievement == null) return;

    if (unlockedAchievements.contains(achievement.milestone)) {
      return;
    }

    unlockedAchievements.add(achievement.milestone);
    await saveAchievements();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AchievementOverlay(
        title: achievement.title,
        description: achievement.description,
      ),
    );
  }

  String getFormattedDateTime() {
    final now = DateTime.now();
    final date = DateFormat("dd MMM yyyy").format(now);
    final time = DateFormat("hh:mm:ss a").format(now);
    return "📅 $date\n🕒 $time";
  }

  Future<void> addHistoryEntry({
    required HistoryAction action,
    required int count,
  }) async {
    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      counterId: "default",
      counterName: "Countify",
      action: action,
      count: count,
      timestamp: DateTime.now(),
    );

    historyEntries.insert(0, entry);
    await StorageService.saveHistoryEntries(historyEntries);
  }

  Future<void> saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "unlockedAchievements",
      unlockedAchievements.map((e) => e.toString()).toList(),
    );
  }

  Future<void> loadCount() async {
    final session = await AuthService.init();
    final loadedCount = await StorageService.loadCount();
    final loadedHighestCount = await StorageService.loadHighestCount();
    await CounterManager.createDefaultCounter(
      count: loadedCount,
      highestCount: loadedHighestCount,
    );
    final loadedHistory = await StorageService.loadHistory();
    historyEntries = await StorageService.loadHistoryEntries();
    final statistics = await StorageService.loadStatistics();
    final loadedAchievements = await StorageService.loadAchievements();
    final loadedGoal = await StorageService.loadDailyGoal();
    final streakData = await StorageService.loadStreak();
    final awake = await StorageService.loadKeepScreenAwake();
    await WakelockPlus.toggle(enable: awake);

    if (mounted) {
      setState(() {
        count = loadedCount;
        highestCount = loadedHighestCount;
        history = loadedHistory;
        dailyGoal = loadedGoal;
        userName = session.isGuest ? "Guest User" : session.name;

        increaseCountValue = statistics["increaseCount"] ?? 0;
        decreaseCountValue = statistics["decreaseCount"] ?? 0;
        resetCountValue = statistics["resetCount"] ?? 0;
        unlockedAchievements = loadedAchievements;
        currentStreak = streakData["currentStreak"] ?? 0;
        bestStreak = streakData["bestStreak"] ?? 0;
      });
      _checkAndCelebrateStreakMilestone(currentStreak);
    }
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

  Widget _buildStylizedCLogo() {
    return const LiveCountifyLogo(size: 38);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    final double goalProgress =
        dailyGoal > 0 ? (count / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final int goalPct = (goalProgress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            _buildStylizedCLogo(),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Countify",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: colors.primaryText,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Small Steps • Big Changes",
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 🔥 Transparent Glass Streak Pill
          _buildCircleActionPill(
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFF97316),
            badgeText: currentStreak > 0 ? "$currentStreak" : null,
            badgeColor: const Color(0xFFEF4444),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StreakScreen(
                    currentStreak: currentStreak,
                    bestStreak: bestStreak,
                    lastActiveDate: "",
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // 🏆 Transparent Glass Achievements Pill
          _buildCircleActionPill(
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFFF59E0B),
            badgeText: unlockedAchievements.isNotEmpty
                ? "${unlockedAchievements.length}"
                : null,
            badgeColor: const Color(0xFF10B981),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AchievementScreen(
                    unlockedAchievements: unlockedAchievements,
                    currentCount: count,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Mountain Landscape Background
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/nature_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF0F172A),
              ),
            ),
          ),

          // Gentle Gradient Overlay for Readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.30),
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
              ),
            ),
          ),

          // Main Scrollable Dashboard Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Header Banner
                  _buildGreetingBanner(colors),

                  const SizedBox(height: 20),

                  // Central Hero Section
                  _buildCentralHeroSection(colors),

                  const SizedBox(height: 20),

                  // Daily Goal Glass Capsule
                  _buildDailyGoalCapsule(colors, goalProgress, goalPct),

                  const SizedBox(height: 20),

                  // 3 Large Glass Action Touch Cards (Increase | Decrease | Reset)
                  _buildThreeTouchActionCards(),

                  const SizedBox(height: 22),

                  // Quick Access Bar
                  _buildQuickAccessBar(colors),

                  const SizedBox(height: 18),

                  // Native Embedded AdMob Glass Card on Main Screen
                  if (_isBannerAdLoaded && _bannerAd != null)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 6, bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.08),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6, left: 6, right: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00E5FF).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "SPONSOR",
                                          style: TextStyle(
                                            color: Color(0xFF00E5FF),
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Supported Partner",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.info_outline_rounded, size: 12, color: Colors.white38),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: _bannerAd!.size.width.toDouble(),
                                height: _bannerAd!.size.height.toDouble(),
                                child: AdWidget(ad: _bannerAd!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 90), // Space for bottom nav
                ],
              ),
            ),
          ),

          // Transparent Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildLuxuryBottomNav(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActionPill({
    required IconData icon,
    required Color color,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.35),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          if (badgeText != null)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Greeting Header Banner
  Widget _buildGreetingBanner(AppThemeColors colors) {
    final dateStr = DateFormat("E, d MMM").format(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text("👑", style: TextStyle(fontSize: 18)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Progress is not about being perfect, it's about being consistent.",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Date Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white24,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: Color(0xFF00E5FF)),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Central Hero Section
  Widget _buildCentralHeroSection(AppThemeColors colors) {
    return Row(
      children: [
        // Left Compact Glass Card (Today's Count)
        Expanded(
          flex: 3,
          child: _buildCompactBubbleSideCard(
            title: "Today's Count",
            value: "$increaseCountValue",
            icon: Icons.arrow_upward_rounded,
            iconColor: const Color(0xFF10B981),
            colors: colors,
          ),
        ),

        const SizedBox(width: 8),

        // Center Hero Glass Bubble Orb with Smooth Scale Animation
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: counterScale,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                child: AnimatedBuilder(
                  animation: _ringPulseController,
                  builder: (context, child) {
                    final val = _ringPulseController.value;
                    return Container(
                      width: 165,
                      height: 165,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: const [
                            Color(0xFF00E5FF),
                            Color(0xFF10B981),
                            Color(0xFF3B82F6),
                            Color(0xFF00E5FF),
                          ],
                          transform: GradientRotation(val * 2 * 3.14159),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.38 + (val * 0.15)),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF090F1D).withOpacity(0.78),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.28),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.25),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 240),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: Tween<double>(begin: 0.8, end: 1.0)
                                        .animate(CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  "$count",
                                  key: ValueKey(count),
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: countColor,
                                    shadows: [
                                      Shadow(
                                        color: countColor.withOpacity(0.7),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Current Count",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 3D Glowing Pedestal Platform Base
              Container(
                width: 110,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFF00E5FF),
                      Color(0xFF3B82F6),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Right Compact Glass Card (Highest Count)
        Expanded(
          flex: 3,
          child: _buildCompactBubbleSideCard(
            title: "Highest Count",
            value: "$highestCount",
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFF8B5CF6),
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBubbleSideCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required AppThemeColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.25),
              border: Border.all(
                color: iconColor.withOpacity(0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Daily Goal Transparent Glass Capsule Card
  Widget _buildDailyGoalCapsule(
      AppThemeColors colors, double goalProgress, int goalPct) {
    return GestureDetector(
      onTap: () async {
        final goal = await showGoalDialog(
          context: context,
          dailyGoal: dailyGoal,
        );
        if (goal != null) {
          setState(() {
            dailyGoal = goal;
          });
          await StorageService.saveDailyGoal(goal);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.2),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withOpacity(0.5),
                ),
              ),
              child: const Icon(Icons.track_changes_rounded,
                  color: Color(0xFF00E5FF), size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Daily Goal",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "$count / $dailyGoal",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: goalProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "$goalPct%",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00E5FF),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white60, size: 20),
          ],
        ),
      ),
    );
  }

  // 3 Large Glass Action Touch Cards (Increase | Decrease | Reset)
  Widget _buildThreeTouchActionCards() {
    return Row(
      children: [
        // Increase Card
        Expanded(
          child: _buildActionTouchCard(
            title: "Increase",
            subtitle: "+1 Count",
            icon: Icons.add_rounded,
            color: const Color(0xFF10B981),
            onTap: increaseCount,
          ),
        ),
        const SizedBox(width: 10),
        // Decrease Card
        Expanded(
          child: _buildActionTouchCard(
            title: "Decrease",
            subtitle: "-1 Count",
            icon: Icons.remove_rounded,
            color: const Color(0xFFEF4444),
            onTap: decreaseCount,
          ),
        ),
        const SizedBox(width: 10),
        // Reset Card
        Expanded(
          child: _buildActionTouchCard(
            title: "Reset",
            subtitle: "Back to 0",
            icon: Icons.refresh_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () {
              if (count > 0) {
                resetCount();
                showResetToast(false);
              } else {
                showResetToast(true);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTouchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        await SoundService.playClick();
        await VibrationService.vibrate();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Access Bar
  Widget _buildQuickAccessBar(AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.bolt_rounded,
                    color: Color(0xFF00E5FF), size: 18),
                SizedBox(width: 6),
                Text(
                  "Quick Access",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageCountersScreen(),
                  ),
                );
              },
              child: const Text(
                "View All >",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickAccessPill(
              label: "History",
              icon: Icons.access_time_rounded,
              color: const Color(0xFF3B82F6),
              onTap: () async {
                final latestHistory =
                    await StorageService.loadHistoryEntries();
                if (!mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(history: latestHistory),
                  ),
                );
                loadCount();
              },
            ),
            _buildQuickAccessPill(
              label: "Settings",
              icon: Icons.settings_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
                await ThemeService.init();
                if (mounted) {
                  MyApp.of(context)?.refreshTheme();
                  await loadCount();
                }
              },
            ),
            _buildQuickAccessPill(
              label: "More",
              icon: Icons.more_horiz_rounded,
              color: const Color(0xFFEC4899),
              onTap: () {
                showMoreToolsSheet(
                  context: context,
                  count: count,
                  highestCount: highestCount,
                  increaseCountValue: increaseCountValue,
                  decreaseCountValue: decreaseCountValue,
                  resetCountValue: resetCountValue,
                  currentStreak: currentStreak,
                  bestStreak: bestStreak,
                  dailyGoal: dailyGoal,
                  onReload: loadCount,
                  onRefreshTheme: () => MyApp.of(context)?.refreshTheme(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessPill({
    required String label,
    required IconData icon,
    required Color color,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withOpacity(0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (badgeText != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Transparent Glassmorphic Bottom Navigation Bar
  Widget _buildLuxuryBottomNav(AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: "Home",
            isSelected: _selectedBottomNavIndex == 0,
            onTap: () {
              setState(() {
                _selectedBottomNavIndex = 0;
              });
            },
          ),
          _buildBottomNavItem(
            index: 1,
            icon: Icons.grid_view_rounded,
            label: "Categories",
            isSelected: _selectedBottomNavIndex == 1,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryHubScreen(),
                ),
              );
            },
          ),

          // Center Floating Plus Button (Opens New Counter Creation Dialog & Navigates to Workspace)
          GestureDetector(
            onTap: () async {
              final newCounter = await showDialog<CounterModel>(
                context: context,
                builder: (_) => const NewCounterDialog(),
              );
              if (newCounter != null) {
                await loadCount();
                if (!mounted) return;

                ToastService.success(
                  context,
                  "Counter Created! 🎯",
                  "Opening '${newCounter.name}' in '${newCounter.category}' workspace...",
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkspaceScreen(category: newCounter.category),
                  ),
                );
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.45),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 28),
            ),
          ),

          _buildBottomNavItem(
            index: 3,
            icon: Icons.bar_chart_rounded,
            label: "Statistics",
            isSelected: _selectedBottomNavIndex == 3,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatisticsScreen(
                    currentCount: count,
                    highestCount: highestCount,
                    increaseCount: increaseCountValue,
                    decreaseCount: decreaseCountValue,
                    resetCount: resetCountValue,
                    currentStreak: currentStreak,
                    bestStreak: bestStreak,
                    dailyGoal: dailyGoal,
                  ),
                ),
              );
            },
          ),
          _buildBottomNavItem(
            index: 4,
            icon: Icons.person_rounded,
            label: "Profile",
            isSelected: _selectedBottomNavIndex == 4,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    currentCount: count,
                    highestCount: highestCount,
                    currentStreak: currentStreak,
                    bestStreak: bestStreak,
                    unlockedAchievements: unlockedAchievements,
                  ),
                ),
              );
              await loadCount();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF00E5FF) : Colors.grey,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF00E5FF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
