import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:toastification/toastification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/theme_detection_service.dart';
import '../services/storage_service.dart';
import '../models/history_entry.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/achievement_service.dart';
import '../services/share_service.dart';
import '../widgets/achievement_overlay.dart';
import '../theme/app_theme_colors.dart';
import 'package:intl/intl.dart';
import '../dialogs/goal_dialog.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import '../models/streak_milestone.dart';
import '../widgets/streak_milestone_dialog.dart';
import 'achievement_screen.dart';

class CounterScreen extends StatefulWidget {
  final String counterName;
  final String category;
  final String counterId;
  final int currentCount;
  final int highestCount;
  final int todayCount;
  final int dailyGoal;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String lastUpdatedDate;
  final int targetAlertCount;
  final bool isVoiceEnabled;
  final int stepSize;
  final CounterThemeStyle themeStyle;

  const CounterScreen({
    super.key,
    required this.counterName,
    required this.category,
    required this.counterId,
    required this.currentCount,
    required this.highestCount,
    required this.todayCount,
    required this.dailyGoal,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.lastUpdatedDate,
    required this.targetAlertCount,
    required this.isVoiceEnabled,
    required this.stepSize,
    required this.themeStyle,
  });

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> with TickerProviderStateMixin {
  late int count;
  late int highest;
  late int today;
  int _currentTab = 0;

  int increased = 0;
  int decreased = 0;
  int resetCount = 0;

  int targetAlertCount = 0;
  bool isVoiceEnabled = false;
  int stepSize = 1;
  bool isLocked = false;
  bool keepScreenOn = false;
  String? currentSessionNote;
  
  Color countColor = Colors.white;
  double counterScale = 1.0;
  
  final FlutterTts flutterTts = FlutterTts();

  List<HistoryEntry> historyEntries = [];
  int currentStreak = 0;
  int bestStreak = 0;
  int dailyGoal = 0;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  Set<int> unlockedAchievements = {};

  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _checkDailyReset();
    _loadStats();
    _initTts();

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    flutterTts.stop();
    _confettiController.dispose();
    super.dispose();
  }

  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(0.6); 
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    
    if (widget.lastUpdatedDate != todayStr) {
      today = 0;
    } else {
      today = widget.todayCount;
    }
    count = widget.currentCount;
    highest = widget.highestCount;
    soundEnabled = widget.soundEnabled;
    vibrationEnabled = widget.vibrationEnabled;
    dailyGoal = widget.dailyGoal;
    targetAlertCount = widget.targetAlertCount;
    isVoiceEnabled = widget.isVoiceEnabled;
    stepSize = widget.stepSize;
    countColor = primary;
  }

  Future<void> _loadStats() async {
    final stats = await StorageService.loadCounterStatistics(widget.counterId);
    final loadedHistory = await StorageService.loadHistoryEntries();
    final streakData = await StorageService.loadStreak();
    final achievements = await StorageService.loadCounterAchievements(widget.counterId);
    final awake = await StorageService.loadKeepScreenAwake();
    await WakelockPlus.toggle(enable: awake);

    if (!mounted) return;
    
    // Find latest note for this counter
    String? note;
    try {
      note = loadedHistory.firstWhere((e) => e.counterId == widget.counterId && e.note != null).note;
    } catch (_) {}

    setState(() {
      increased = stats["increaseCount"] ?? 0;
      decreased = stats["decreaseCount"] ?? 0;
      resetCount = stats["resetCount"] ?? 0;
      historyEntries = loadedHistory;
      currentStreak = streakData["currentStreak"] ?? 0;
      bestStreak = streakData["bestStreak"] ?? 0;
      unlockedAchievements = achievements;
      currentSessionNote = note;
      keepScreenOn = awake;
    });
  }

  Future<void> _checkAchievement() async {
    final achievement = AchievementService.checkAchievement(count);
    if (achievement == null) return;

    if (unlockedAchievements.contains(achievement.milestone)) return;

    setState(() {
      unlockedAchievements.add(achievement.milestone);
    });

    await StorageService.saveCounterAchievements(
      counterId: widget.counterId,
      achievements: unlockedAchievements,
    );

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

  List<int> _getWeeklyActivityData() {
    final now = DateTime.now();
    final data = List.filled(7, 0);
    final filtered = historyEntries.where((e) => e.counterId == widget.counterId).toList();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = filtered.where((e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day);
      
      // Activity count = sum of increments and decrements
      int activity = 0;
      for (var entry in dayEntries) {
        if (entry.action == HistoryAction.increase || entry.action == HistoryAction.decrease) {
          activity++;
        }
      }
      data[6 - i] = activity;
    }
    return data;
  }

  List<String> _getWeeklyDayLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date); // Mon, Tue, etc.
    });
  }

  ThemeDataModel get themeData {
    return ThemeDetectionService.detect(widget.category);
  }

  Color get primary => themeData.primaryColor;
  Color get secondary => themeData.secondaryColor;

  String? _getBackgroundImage() {
    switch (widget.themeStyle) {
      case CounterThemeStyle.islamic:
        return 'assets/backgrounds/islamic_mosque_bg.png';
      case CounterThemeStyle.fitness:
      case CounterThemeStyle.health:
        return 'assets/backgrounds/fitness_bg.png';
      case CounterThemeStyle.education:
        return 'assets/backgrounds/education_bg.png';
      case CounterThemeStyle.programming:
      case CounterThemeStyle.creative:
        return 'assets/backgrounds/programming_bg.png';
      case CounterThemeStyle.nature:
        return 'assets/backgrounds/nature_bg.png';
      case CounterThemeStyle.productivity:
      case CounterThemeStyle.finance:
        return 'assets/backgrounds/productivity_bg.png';
      case CounterThemeStyle.sports:
        return 'assets/backgrounds/sports_bg.png';
      case CounterThemeStyle.defaultTheme:
        return 'assets/backgrounds/default_bg.png';
    }
  }

  Widget _buildDynamicBackground(ThemeDataModel theme) {
    final bgImg = _getBackgroundImage();
    
    return Stack(
      children: [
        // Base Layer: Deep Theme Background
        Positioned.fill(
          child: Container(
            color: theme.backgroundColor.withOpacity(0.1),
          ),
        ),
        
        // Aurora Engine: Procedural Luxury Orbs
        Positioned(
          top: -120,
          left: -60,
          child: _buildAuroraOrb(theme.primaryColor, 350),
        ),
        Positioned(
          bottom: -180,
          right: -80,
          child: _buildAuroraOrb(theme.accentColor, 450),
        ),
        Positioned(
          top: 300,
          right: -40,
          child: _buildAuroraOrb(theme.secondaryColor, 280),
        ),

        // Glassmorphism Blur Layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Optional Image Asset Layer with Blend (Restored)
        if (bgImg != null)
          Positioned.fill(
            child: Opacity(
              opacity: 1.0,
              child: Image.asset(
                bgImg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        
        // Dynamic Vignette for Depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuroraOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = themeData;
    final currentTheme = Theme.of(context);
    
    final categoryTheme = currentTheme.copyWith(
      extensions: [
        AppThemeColors(
          gradientStart: themeModel.backgroundColor,
          gradientMiddle: themeModel.surfaceColor,
          gradientEnd: themeModel.backgroundColor,
          card: themeModel.surfaceColor.withOpacity(0.05),
          primaryText: Colors.white,
          secondaryText: Colors.white70,
        ),
      ],
    );

    return Theme(
      data: categoryTheme,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildDynamicBackground(themeModel),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.1),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildTabContent(themeModel),
                  ),
                  _buildBottomNav(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
              ),
            ),
            if (isLocked) _buildLockOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeDataModel themeModel) {
    switch (_currentTab) {
      case 0:
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildHeroSection(themeModel),
              const SizedBox(height: 24),
              if (currentSessionNote != null) ...[
                _buildSessionNoteCard(),
                const SizedBox(height: 40),
              ],
              _buildCounterRingAndButtons(themeModel),
              const SizedBox(height: 50),
              _buildStatsCard(themeModel),
              const SizedBox(height: 20),
              _buildTodayStatsGrid(),
              const SizedBox(height: 30),
            ],
          ),
        );
      case 1:
        return _buildHistoryTab();
      case 2:
        return _buildAnalyticsTab(themeModel);
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHistoryTab() {
    final filtered = historyEntries.where((e) => e.counterId == widget.counterId).toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No activity history for this counter",
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        Color color;
        IconData icon;
        String title;

        switch (entry.action) {
          case HistoryAction.increase:
            color = Colors.greenAccent;
            icon = Icons.add_rounded;
            title = "Count Increased";
            break;
          case HistoryAction.decrease:
            color = Colors.redAccent;
            icon = Icons.remove_rounded;
            title = "Count Decreased";
            break;
          case HistoryAction.reset:
            color = Colors.orangeAccent;
            icon = Icons.restart_alt_rounded;
            title = "Counter Reset";
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: color.withOpacity(0.3), width: 0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  entry.counterName,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat("hh:mm a").format(entry.timestamp),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Count : ${entry.count}",
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (entry.note != null && entry.note!.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.sticky_note_2_rounded, size: 14, color: Colors.blueGrey),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        entry.note!,
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab(ThemeDataModel themeModel) {
    final double progress = dailyGoal > 0 ? (today / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final int percentage = (progress * 100).toInt();

    final weeklyData = _getWeeklyActivityData();
    final weeklyLabels = _getWeeklyDayLabels();
    final int maxActivity = weeklyData.reduce((a, b) => a > b ? a : b);
    final double chartMaxHeight = 60.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(primary),
                          ),
                        ),
                        Text(
                          "$percentage%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PROGRESS TO GOAL",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$today / $dailyGoal Counts",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            today >= dailyGoal ? "Daily Goal Completed!" : "Keep going to reach your goal.",
                            style: TextStyle(
                              color: today >= dailyGoal ? Colors.greenAccent : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildStatsCard(themeModel),
          const SizedBox(height: 24),
          _buildTodayStatsGrid(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              "WEEKLY ACTIVITY",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final day = weeklyLabels[index];
                        final activity = weeklyData[index];
                        final bool isToday = index == 6;
                        
                        double barHeight = 0;
                        if (maxActivity > 0) {
                          barHeight = (activity / maxActivity) * chartMaxHeight;
                        }
                        // Minimum height for visibility if there is activity
                        if (activity > 0 && barHeight < 5) barHeight = 5;

                        return Column(
                          children: [
                            Container(
                              height: chartMaxHeight,
                              width: 14,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutQuart,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          isToday ? primary : primary.withOpacity(0.6),
                                          isToday ? primary.withOpacity(0.7) : primary.withOpacity(0.3),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: activity > 0 ? [
                                        BoxShadow(
                                          color: primary.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 0),
                                        )
                                      ] : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              day,
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.white.withOpacity(0.4),
                                fontSize: 10,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _selectDailyGoal() async {
    final goal = await showGoalDialog(
      context: context,
      dailyGoal: dailyGoal,
    );

    if (goal == null) return;

    setState(() {
      dailyGoal = goal;
    });

    _saveAll();

    if (!mounted) return;

    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: const Text("Goal Updated"),
      description: Text("Daily goal set to $goal counts."),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      primaryColor: primary,
      backgroundColor: const Color(0xFF0D1016),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      children: [
        _buildGlassSettingTile(
          icon: Icons.flag_rounded,
          color: Colors.deepOrangeAccent,
          title: "Daily Goal",
          subtitle: "$dailyGoal Counts",
          onTap: _selectDailyGoal,
        ),
        const SizedBox(height: 12),
        _buildGlassSettingSwitchTile(
          icon: Icons.volume_up_rounded,
          color: Colors.greenAccent,
          title: "Sound Effects",
          subtitle: "Enable sound on count actions",
          value: soundEnabled,
          onChanged: (val) {
            setState(() {
              soundEnabled = val;
            });
            _saveAll();
          },
        ),
        const SizedBox(height: 12),
        _buildGlassSettingSwitchTile(
          icon: Icons.vibration_rounded,
          color: Colors.orangeAccent,
          title: "Vibration",
          subtitle: "Haptic feedback on actions",
          value: vibrationEnabled,
          onChanged: (val) {
            setState(() {
              vibrationEnabled = val;
            });
            _saveAll();
          },
        ),
        const SizedBox(height: 12),
        _buildGlassSettingSwitchTile(
          icon: Icons.record_voice_over_rounded,
          color: Colors.purpleAccent,
          title: "Voice Feedback",
          subtitle: "Announce counts using speech",
          value: isVoiceEnabled,
          onChanged: (val) {
            setState(() {
              isVoiceEnabled = val;
            });
            _saveAll();
          },
        ),
        const SizedBox(height: 12),
        _buildGlassSettingTile(
          icon: Icons.notifications_active_rounded,
          color: Colors.blueAccent,
          title: "Target Reach Alert",
          subtitle: targetAlertCount > 0 ? "Every $targetAlertCount counts" : "Off",
          onTap: _showTargetReachDialog,
        ),
        const SizedBox(height: 12),
        _buildGlassSettingTile(
          icon: Icons.ads_click_rounded,
          color: Colors.tealAccent,
          title: "Step Size",
          subtitle: "Current step increment: $stepSize",
          onTap: _showStepSizeSheet,
        ),
        const SizedBox(height: 12),
        _buildGlassSettingTile(
          icon: Icons.refresh_rounded,
          color: Colors.orange,
          title: "Reset Counter",
          subtitle: "Reset current counts to 0",
          onTap: _reset,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildGlassSettingTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSettingSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            trailing: Switch(
              value: value,
              activeThumbColor: primary,
              activeTrackColor: primary.withOpacity(0.3),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCounterAchievements() async {
    final achievements =
        await StorageService.loadCounterAchievements(widget.counterId);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementScreen(
          unlockedAchievements: achievements,
          currentCount: count,
        ),
      ),
    );
    _loadStats();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          Flexible(
            child: Text(
              widget.counterName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.amber,
                      size: 26,
                    ),
                    if (unlockedAchievements.isNotEmpty)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${unlockedAchievements.length}",
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
                tooltip: "Counter Achievements",
                onPressed: _openCounterAchievements,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 26),
                onPressed: () => _showOptionsSheet(),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildHeroSection(ThemeDataModel themeModel) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: primary.withOpacity(0.2), width: 1.5),
          ),
          child: Icon(
            themeModel.icon,
            size: 44,
            color: primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.counterName.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          themeModel.themeName.toUpperCase(),
          style: TextStyle(
            color: primary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            themeModel.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterRingAndButtons(ThemeDataModel themeModel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ringSize = screenWidth * 0.54;
    final buttonSize = 56.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Minus Button
        _buildCircularButton(
          icon: Icons.remove,
          size: buttonSize,
          onPressed: isLocked ? () {} : _decrease,
        ),
        
        // The Ring
        ScaleTransition(
          scale: _breathingAnimation,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: countColor.withOpacity(_pulseAnimation.value * 0.3),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              transform: Matrix4.diagonal3Values(counterScale.toDouble(), counterScale.toDouble(), 1.0),
              transformAlignment: Alignment.center,
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: countColor.withOpacity(0.45),
                  width: 1.2,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: countColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, countColor],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                          child: Text(
                            "$count",
                            key: ValueKey(count),
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "TOTAL COUNT",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.4),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Plus Button
        _buildCircularButton(
          icon: Icons.add,
          size: buttonSize,
          onPressed: isLocked ? () {} : _increase,
          glow: true,
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    bool glow = false,
  }) {
    return ScaleButton(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeDataModel themeModel) {
    return ShimmerGlassCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn("CURRENT", "$count", Colors.white),
            _buildStatColumn("HIGHEST", "$highest", Colors.white),
            _buildStatColumn("TODAY", "$today", primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 20),
          child: Text(
            "TODAY'S STATISTICS",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildSmallStatCard("INCREASED", "$increased", Colors.greenAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallStatCard("DECREASED", "$decreased", Colors.redAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallStatCard("RESETS", "$resetCount", Colors.orangeAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(String label, String value, Color color) {
    return ShimmerGlassCard(
      borderRadius: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            // LED Indicator Bar
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Session Note", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Text(
            currentSessionNote ?? "",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionNoteCard() {
    return GestureDetector(
      onTap: _showFullNoteDialog,
      child: ShimmerGlassCard(
        borderRadius: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_mosaic_rounded, color: primary, size: 18),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentSessionNote!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap to see full note",
                      style: TextStyle(
                        color: primary.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalAchievedDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeInOutBack.transform(anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13161A).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: primary.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Trophy Icon with Glow
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    primary.withOpacity(0.3),
                                    primary.withOpacity(0.0),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: primary.withOpacity(0.6), width: 2),
                                  ),
                                  child: Icon(Icons.emoji_events_rounded, color: primary, size: 36),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "GOAL ACHIEVED",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Exceptional progress! You've reached your daily target of $dailyGoal counts. Consistency is the key to mastery.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Luxury Action Button
                            ScaleButton(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primary, primary.withOpacity(0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "CONTINUE JOURNEY",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _decrease() {
    if (count <= 0) return;
    HapticFeedback.lightImpact();
    setState(() {
      final actualStep = (count - stepSize < 0) ? count : stepSize;
      count -= actualStep;
      today -= actualStep;
      decreased += actualStep;
      
      countColor = Colors.redAccent;
      counterScale = 1.15;
      
      _addHistoryEntry(HistoryAction.decrease);
      
      if (isVoiceEnabled) flutterTts.speak(count.toString());
      if (soundEnabled) SoundService.playThemeSound(widget.themeStyle);
      if (vibrationEnabled) VibrationService.vibrate();
    });

    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        counterScale = 1.0;
      });
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        countColor = primary;
      });
    });

    _saveAll();
  }

  void _increase() {
    HapticFeedback.lightImpact();
    setState(() {
      count += stepSize;
      today += stepSize;
      increased += stepSize;
      if (count > highest) highest = count;
      
      countColor = Colors.greenAccent;
      counterScale = 1.15;
      
      _addHistoryEntry(HistoryAction.increase);
      _checkAchievement();
      
      if (isVoiceEnabled) flutterTts.speak(count.toString());
      if (soundEnabled) SoundService.playThemeSound(widget.themeStyle);
      
      final bool isTargetReached = targetAlertCount > 0 && count % targetAlertCount == 0;

      if (isTargetReached) {
        debugPrint('Target reached! count: $count, target: $targetAlertCount. Triggering strong vibration.');
        VibrationService.vibrateStrong(ignoreSetting: true);
        _showTargetReachedToast();
      } else if (vibrationEnabled) {
        VibrationService.vibrate();
      }

      if (dailyGoal > 0 && (today == dailyGoal || count == dailyGoal)) {
        _confettiController.play();
        HapticFeedback.mediumImpact();
        _showGoalAchievedDialog();
      }
    });

    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {
        counterScale = 1.0;
      });
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        countColor = primary;
      });
    });

    _saveAll();
  }

  void _showTargetReachedToast() {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: const Text("Target Reached!"),
      description: Text("You have reached $count counts."),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      primaryColor: primary,
      backgroundColor: const Color(0xFF0D1016),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, "Overview", _currentTab == 0, () {
            setState(() {
              _currentTab = 0;
            });
          }),
          _buildNavItem(Icons.history_rounded, "History", _currentTab == 1, () {
            setState(() {
              _currentTab = 1;
            });
          }),
          _buildNavItem(Icons.analytics_rounded, "Analytics", _currentTab == 2, () {
            setState(() {
              _currentTab = 2;
            });
          }),
          _buildNavItem(Icons.settings_rounded, "Settings", _currentTab == 3, () {
            setState(() {
              _currentTab = 3;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primary : Colors.white.withOpacity(0.4),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onLongPress: () => setState(() => isLocked = false),
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, color: primary, size: 80),
              const SizedBox(height: 20),
              const Text("INTERFACE LOCKED", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Long press to unlock", style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _addHistoryEntry(HistoryAction action) async {
    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      counterId: widget.counterId,
      counterName: widget.counterName,
      action: action,
      count: count,
      timestamp: DateTime.now(),
    );
    historyEntries.insert(0, entry);
    await StorageService.saveHistoryEntries(historyEntries);
    if (!mounted) return;
  }

  Future<void> _saveAll() async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    await StorageService.updateCounterData(
      counterId: widget.counterId,
      count: count,
      highestCount: highest,
      todayCount: today,
      targetAlertCount: targetAlertCount,
      isVoiceEnabled: isVoiceEnabled,
      stepSize: stepSize,
    );
    if (!mounted) return;

    final counters = await StorageService.loadCounters();
    if (!mounted) return;
    final index = counters.indexWhere((c) => c.id == widget.counterId);
    if (index != -1) {
      counters[index] = counters[index].copyWith(
        soundEnabled: soundEnabled,
        vibrationEnabled: vibrationEnabled,
        lastUpdatedDate: todayStr,
        dailyGoal: dailyGoal,
        targetAlertCount: targetAlertCount,
        isVoiceEnabled: isVoiceEnabled,
        stepSize: stepSize,
      );
      await StorageService.saveCounters(counters);
      if (!mounted) return;
    }

    await StorageService.saveCounterStatistics(
      counterId: widget.counterId,
      increaseCount: increased,
      decreaseCount: decreased,
      resetCount: resetCount,
    );
    if (!mounted) return;

    final streakData = await StorageService.loadStreak();
    int currentStr = streakData["currentStreak"] ?? 0;
    int bestStr = streakData["bestStreak"] ?? 0;
    final newStreak = currentStr > 0 ? currentStr : 1;
    await StorageService.saveStreak(
      currentStreak: newStreak,
      bestStreak: bestStr > 0 ? bestStr : 1,
      lastActiveDate: now.toIso8601String(),
    );

    final milestone = StreakMilestone.getMilestoneForDays(newStreak);
    if (milestone != null) {
      final celebrated = await StorageService.isStreakMilestoneCelebrated(newStreak);
      if (!celebrated) {
        await StorageService.markStreakMilestoneCelebrated(newStreak);
        if (mounted) {
          StreakMilestoneDialog.show(context, milestone);
        }
      }
    }
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1016),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text("COUNTER OPTIONS", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildOptionTile(
                          icon: Icons.emoji_events_rounded,
                          color: Colors.amber,
                          title: "Counter Achievements",
                          subtitle: "${unlockedAchievements.length} Badges Unlocked",
                          onTap: () {
                            Navigator.pop(context);
                            _openCounterAchievements();
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.notifications_active_rounded,
                          color: Colors.blueAccent,
                          title: "Target Reach Alert",
                          subtitle: targetAlertCount > 0 ? "Every $targetAlertCount counts" : "Off",
                          onTap: () {
                            Navigator.pop(context);
                            _showTargetReachDialog();
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.record_voice_over_rounded,
                          color: Colors.purpleAccent,
                          title: "Voice Feedback",
                          trailing: Switch(
                            value: isVoiceEnabled,
                            activeThumbColor: primary,
                            onChanged: (val) {
                              setModalState(() => isVoiceEnabled = val);
                              setState(() => isVoiceEnabled = val);
                              _saveAll();
                            },
                          ),
                        ),
                        _buildOptionTile(
                          icon: Icons.ads_click_rounded,
                          color: Colors.tealAccent,
                          title: "Step Size",
                          subtitle: "Current: $stepSize",
                          onTap: () {
                            Navigator.pop(context);
                            _showStepSizeSheet();
                          },
                        ),
                        _buildOptionTile(
                          icon: isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                          color: Colors.redAccent,
                          title: "Lock Interface",
                          onTap: () {
                            Navigator.pop(context);
                            setState(() => isLocked = true);
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.stay_current_portrait_rounded,
                          color: Colors.orangeAccent,
                          title: "Keep Screen On",
                          trailing: Switch(
                            value: keepScreenOn,
                            activeThumbColor: primary,
                            onChanged: (val) async {
                              setModalState(() => keepScreenOn = val);
                              setState(() => keepScreenOn = val);
                              await StorageService.saveKeepScreenAwake(val);
                              await WakelockPlus.toggle(enable: val);
                            },
                          ),
                        ),
                        _buildOptionTile(
                          icon: Icons.edit_note_rounded,
                          color: Colors.indigoAccent,
                          title: "Manual Adjustment",
                          onTap: () {
                            Navigator.pop(context);
                            _showManualAdjustmentDialog();
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.note_add_rounded,
                          color: Colors.amberAccent,
                          title: "Add Note to Session",
                          onTap: () {
                            Navigator.pop(context);
                            _showNoteDialog();
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.history_rounded,
                          color: Colors.deepOrangeAccent,
                          title: "Reset Highest Count",
                          onTap: () {
                            Navigator.pop(context);
                            _showResetHighestDialog();
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.file_download_rounded,
                          color: Colors.greenAccent,
                          title: "Export Session",
                          onTap: () {
                            Navigator.pop(context);
                            _exportSession();
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.share_rounded,
                          color: Colors.cyanAccent,
                          title: "Share Session",
                          onTap: () {
                            Navigator.pop(context);
                            ShareService.shareStatistics(
                              currentCount: count,
                              highestCount: highest,
                              currentStreak: currentStreak,
                              bestStreak: bestStreak,
                              increaseCount: increased,
                              decreaseCount: decreased,
                              resetCount: resetCount,
                            );
                          },
                        ),
                        _buildOptionTile(
                          icon: Icons.refresh_rounded,
                          color: Colors.orange,
                          title: "Reset Counter",
                          onTap: () {
                            Navigator.pop(context);
                            _reset();
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: onTap,
    );
  }

  void _showTargetReachDialog() {
    final controller = TextEditingController(text: targetAlertCount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Target Reach Alert", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Set an interval to receive notifications (e.g., every 33 counts). Set to 0 to disable.",
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter interval",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                targetAlertCount = int.tryParse(controller.text) ?? 0;
              });
              _saveAll();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showStepSizeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1016),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Select Step Size", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...[1, 5, 10, 33, 100].map((size) => ListTile(
            title: Text("$size", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() => stepSize = size);
              _saveAll();
              Navigator.pop(context);
            },
            selected: stepSize == size,
            selectedTileColor: primary.withOpacity(0.1),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showManualAdjustmentDialog() {
    final controller = TextEditingController(text: count.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Manual Adjustment", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter current count",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newCount = int.tryParse(controller.text) ?? count;
              setState(() {
                count = newCount;
                if (count > highest) highest = count;
              });
              _saveAll();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog() {
    final controller = TextEditingController(text: currentSessionNote);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Add Note to Session", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 120,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "What are you counting?",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final note = controller.text.trim();
              if (note.isNotEmpty) {
                setState(() => currentSessionNote = note);
                if (historyEntries.isNotEmpty) {
                  final latest = historyEntries.first;
                  final updated = HistoryEntry(
                    id: latest.id,
                    counterId: latest.counterId,
                    counterName: latest.counterName,
                    action: latest.action,
                    count: latest.count,
                    timestamp: latest.timestamp,
                    note: note,
                  );
                  historyEntries[0] = updated;
                  await StorageService.saveHistoryEntries(historyEntries);
                  if (!mounted) return;
                }
              }
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Add Note"),
          ),
        ],
      ),
    );
  }

  void _showResetHighestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Reset Highest Count?", style: TextStyle(color: Colors.white)),
        content: const Text("This will clear your personal record for this counter.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              setState(() => highest = 0);
              await StorageService.resetCounterHighestCount(widget.counterId);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSession() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln("=== COUNTIFY SESSION EXPORT ===");
      buffer.writeln("Counter: ${widget.counterName}");
      buffer.writeln("Date: ${DateTime.now()}");
      buffer.writeln("Current Count: $count");
      buffer.writeln("Highest Count: $highest");
      buffer.writeln("Session Statistics:");
      buffer.writeln(" - Increased: $increased");
      buffer.writeln(" - Decreased: $decreased");
      buffer.writeln(" - Resets: $resetCount");
      if (currentSessionNote != null) {
        buffer.writeln("Note: $currentSessionNote");
      }
      
      final directory = await getTemporaryDirectory();
      if (!mounted) return;
      final file = File('${directory.path}/${widget.counterName}_session.txt');
      await file.writeAsString(buffer.toString());
      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Countify Session Export: ${widget.counterName}',
        ),
      );
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Export failed: $e")));
    }
  }

  void _reset() {
    setState(() {
      count = 0;
      today = 0;
      resetCount++;
      countColor = Colors.orangeAccent;
      counterScale = 1.1;
      _addHistoryEntry(HistoryAction.reset);
    });
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          counterScale = 1.0;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          countColor = primary;
        });
      }
    });
    
    _saveAll();
  }
}

class ShimmerGlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  const ShimmerGlassCard({super.key, required this.child, this.borderRadius = 32});

  @override
  State<ShimmerGlassCard> createState() => _ShimmerGlassCardState();
}

class _ShimmerGlassCardState extends State<ShimmerGlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.8,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _shimmerController.value - 0.2,
                _shimmerController.value,
                _shimmerController.value + 0.2,
              ],
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                color: Colors.white.withOpacity(0.04),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.92 : 1.0,
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}