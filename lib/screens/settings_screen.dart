import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../models/counter_model.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/theme_service.dart';
import '../services/toast_service.dart';
import '../services/ad_service.dart';
import '../dialogs/goal_dialog.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/live_animated_icon.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  final String? counterId;
  final int? initialGoal;
  final bool? initialSound;
  final bool? initialVibration;
  final int? initialHighest;
  final int? initialIncreased;
  final int? initialDecreased;
  final int? initialReset;

  const SettingsScreen({
    super.key,
    this.counterId,
    this.initialGoal,
    this.initialSound,
    this.initialVibration,
    this.initialHighest,
    this.initialIncreased,
    this.initialDecreased,
    this.initialReset,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool soundEnabled = true;
  bool darkModeEnabled = true;
  bool vibrationEnabled = true;
  bool keepScreenAwake = false;
  int defaultStepSize = 1;
  late int dailyGoal;
  late int highestCount;
  late int increaseCountValue;
  late int decreaseCountValue;
  late int resetCountValue;
  Set<int> unlockedAchievements = {};
  int activeAccentIndex = 0;

  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    dailyGoal = widget.initialGoal ?? 100;
    soundEnabled = widget.initialSound ?? true;
    vibrationEnabled = widget.initialVibration ?? true;
    highestCount = widget.initialHighest ?? 0;
    increaseCountValue = widget.initialIncreased ?? 0;
    decreaseCountValue = widget.initialDecreased ?? 0;
    resetCountValue = widget.initialReset ?? 0;

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    loadSettings();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> loadSettings() async {
    if (widget.counterId != null) {
      final counters = await StorageService.loadCounters();
      final current = counters.firstWhere(
        (c) => c.id == widget.counterId,
        orElse: () => counters.isNotEmpty
            ? counters.first
            : CounterModel(
                id: widget.counterId!,
                name: "Counter",
                count: 0,
                highestCount: 0,
              ),
      );
      final stats =
          await StorageService.loadCounterStatistics(widget.counterId!);

      if (mounted) {
        setState(() {
          soundEnabled = current.soundEnabled;
          vibrationEnabled = current.vibrationEnabled;
          dailyGoal = current.dailyGoal;
          highestCount = current.highestCount;
          increaseCountValue = stats["increaseCount"] ?? 0;
          decreaseCountValue = stats["decreaseCount"] ?? 0;
          resetCountValue = stats["resetCount"] ?? 0;
          defaultStepSize = current.stepSize;
        });
      }
    } else {
      soundEnabled = await StorageService.loadSound();
      vibrationEnabled = await StorageService.loadVibration();
      darkModeEnabled = await StorageService.loadDarkMode();
      dailyGoal = await StorageService.loadDailyGoal();
      highestCount = await StorageService.loadHighestCount();
      keepScreenAwake = await StorageService.loadKeepScreenAwake();
      final statistics = await StorageService.loadStatistics();

      if (mounted) {
        setState(() {
          increaseCountValue = statistics["increaseCount"] ?? 0;
          decreaseCountValue = statistics["decreaseCount"] ?? 0;
          resetCountValue = statistics["resetCount"] ?? 0;
          activeAccentIndex = ThemeService.currentAccentIndex;
        });
      }
    }

    if (widget.counterId != null) {
      unlockedAchievements =
          await StorageService.loadCounterAchievements(widget.counterId!);
    } else {
      unlockedAchievements = await StorageService.loadAchievements();
    }
  }

  Future<void> selectDailyGoal() async {
    final localContext = context;
    final goal = await showGoalDialog(
      context: localContext,
      dailyGoal: dailyGoal,
    );

    if (goal == null) return;

    setState(() {
      dailyGoal = goal;
    });

    if (widget.counterId != null) {
      // Per-counter goal
      final counters = await StorageService.loadCounters();
      final index = counters.indexWhere((c) => c.id == widget.counterId);
      if (index != -1) {
        counters[index] = counters[index].copyWith(dailyGoal: goal);
        await StorageService.saveCounters(counters);
      }
    } else {
      // Global goal
      await StorageService.saveDailyGoal(goal);
    }

    if (!localContext.mounted) return;

    ToastService.success(
      localContext,
      "Goal Updated",
      "Daily goal updated to $goal counts.",
    );
  }

  Future<void> showResetEverythingDialog() async {
    final isIndividual = widget.counterId != null;
    final title = isIndividual ? "Reset Counter Data" : "Reset Everything";
    final content = isIndividual
        ? "This will permanently delete all data for THIS counter (History, Stats, Record).\n\nThis action cannot be undone."
        : "This will permanently wipe ALL app data across all counters, histories, stats, streaks & goals.\n\nThis action cannot be undone.";

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
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
                color: Colors.red.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.25),
                  blurRadius: 32,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Warning Icon Header
                Row(
                  children: [
                    const LiveAnimatedIcon(
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 48,
                      iconSize: 24,
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
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "DANGER ZONE 🚨",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 20),

                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 26),

                // Action Buttons
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
                          elevation: 4,
                          shadowColor: Colors.red.withOpacity(0.4),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          "Reset Everything",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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

    if (confirm != true) return;

    if (isIndividual) {
      await StorageService.resetIndividualCounter(widget.counterId!);
      if (!mounted) return;
      ToastService.success(
          context, "Counter Reset", "All data for this counter has been cleared.");
      Navigator.pop(context, true);
    } else {
      await StorageService.resetEverything();
      if (!mounted) return;
      setState(() {
        dailyGoal = 0;
        highestCount = 0;
        increaseCountValue = 0;
        decreaseCountValue = 0;
        resetCountValue = 0;
        unlockedAchievements.clear();
      });
      ToastService.success(
          context, "Reset Complete", "All app data reset successfully.");
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ThemeService.primaryColor;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Signals parent to refresh
      },
      child: Scaffold(
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
              LiveAnimatedIcon(
                icon: Icons.settings_rounded,
                color: primaryColor,
                size: 32,
                iconSize: 17,
              ),
              const SizedBox(width: 8),
              Text(
                "Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Ambient Blur Mesh
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
                            color: primaryColor
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Theme & Appearance Section
                  _buildSectionHeader(
                    title: "Theme & Customization",
                    icon: Icons.palette_rounded,
                    color: primaryColor,
                    colors: colors,
                  ),
                  const SizedBox(height: 10),

                  // Dark Mode Switch Card
                  _buildLuxuryCard(
                    isDark: isDark,
                    child: SwitchListTile(
                      value: darkModeEnabled,
                      onChanged: (value) async {
                        final localContext = context;
                        setState(() {
                          darkModeEnabled = value;
                        });
                        await ThemeService.changeTheme(value);
                        if (!localContext.mounted) return;
                        MyApp.of(localContext)?.refreshTheme();
                      },
                      secondary: LiveAnimatedIcon(
                        icon: Icons.dark_mode_rounded,
                        color: primaryColor,
                        size: 38,
                        iconSize: 18,
                      ),
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Toggle dark / light appearance",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      activeColor: primaryColor,
                    ),
                  ),

                  // Custom Accent Theme Selector
                  if (widget.counterId == null) ...[
                    const SizedBox(height: 12),
                    _buildLuxuryCard(
                      isDark: isDark,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                LiveAnimatedIcon(
                                  icon: Icons.color_lens_rounded,
                                  color: primaryColor,
                                  size: 36,
                                  iconSize: 18,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Custom Accent Theme",
                                      style: TextStyle(
                                        color: colors.primaryText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "Applies accent color globally across app",
                                      style: TextStyle(
                                        color: colors.secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: List.generate(
                                  ThemeService.accentColors.length,
                                  (index) {
                                    final color =
                                        ThemeService.accentColors[index];
                                    final isSelected =
                                        activeAccentIndex == index;
                                    return GestureDetector(
                                      onTap: () async {
                                        final appState = MyApp.of(context);
                                        setState(() {
                                          activeAccentIndex = index;
                                        });
                                        await ThemeService.changeAccentIndex(index);
                                        appState?.refreshTheme();
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 10),
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? color
                                                : Colors.transparent,
                                            width: 2.5,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: color,
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Rewarded Sponsor Video Ad Section
                  _buildRewardedAdCard(colors, isDark),

                  const SizedBox(height: 22),

                  // Audio & Haptic Feedback Section
                  _buildSectionHeader(
                    title: "Audio & Haptic Feedback",
                    icon: Icons.volume_up_rounded,
                    color: const Color(0xFF10B981),
                    colors: colors,
                  ),
                  const SizedBox(height: 10),

                  // Sound Switch + Test
                  _buildLuxuryCard(
                    isDark: isDark,
                    child: SwitchListTile(
                      value: soundEnabled,
                      onChanged: (value) async {
                        setState(() {
                          soundEnabled = value;
                        });
                        if (widget.counterId != null) {
                          final counters = await StorageService.loadCounters();
                          final index = counters
                              .indexWhere((c) => c.id == widget.counterId);
                          if (index != -1) {
                            counters[index] = counters[index]
                                .copyWith(soundEnabled: value);
                            await StorageService.saveCounters(counters);
                          }
                        } else {
                          SoundService.soundEnabled = value;
                          await StorageService.saveSound(value);
                        }
                        if (value) {
                          SoundService.playClick();
                        }
                      },
                      secondary: const LiveAnimatedIcon(
                        icon: Icons.music_note_rounded,
                        color: Color(0xFF10B981),
                        size: 38,
                        iconSize: 18,
                      ),
                      title: Text(
                        "Click Sound Effect",
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Play sound feedback on tap",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      activeColor: const Color(0xFF10B981),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Vibration Switch + Test
                  _buildLuxuryCard(
                    isDark: isDark,
                    child: SwitchListTile(
                      value: vibrationEnabled,
                      onChanged: (value) async {
                        setState(() {
                          vibrationEnabled = value;
                        });
                        if (widget.counterId != null) {
                          final counters = await StorageService.loadCounters();
                          final index = counters
                              .indexWhere((c) => c.id == widget.counterId);
                          if (index != -1) {
                            counters[index] = counters[index]
                                .copyWith(vibrationEnabled: value);
                            await StorageService.saveCounters(counters);
                          }
                        } else {
                          VibrationService.vibrationEnabled = value;
                          await StorageService.saveVibration(value);
                        }
                        if (value) {
                          VibrationService.vibrate();
                        }
                      },
                      secondary: const LiveAnimatedIcon(
                        icon: Icons.vibration_rounded,
                        color: Color(0xFFF59E0B),
                        size: 38,
                        iconSize: 18,
                      ),
                      title: Text(
                        "Tactile Vibration",
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Vibrate device on tap",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      activeColor: const Color(0xFFF59E0B),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Display & Target Preferences
                  _buildSectionHeader(
                    title: "Display & Goals",
                    icon: Icons.flag_rounded,
                    color: const Color(0xFFF97316),
                    colors: colors,
                  ),
                  const SizedBox(height: 10),

                  // Daily Goal Tile
                  _buildLuxuryCard(
                    isDark: isDark,
                    child: ListTile(
                      onTap: selectDailyGoal,
                      leading: const LiveAnimatedIcon(
                        icon: Icons.flag_rounded,
                        color: Color(0xFFF97316),
                        size: 38,
                        iconSize: 18,
                      ),
                      title: Text(
                        "Daily Goal Target",
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Target: $dailyGoal counts",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "$dailyGoal",
                          style: const TextStyle(
                            color: Color(0xFFF97316),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Keep Screen Awake (Wakelock) Toggle
                  _buildLuxuryCard(
                    isDark: isDark,
                    child: SwitchListTile(
                      value: keepScreenAwake,
                      onChanged: (val) async {
                        setState(() {
                          keepScreenAwake = val;
                        });
                        await StorageService.saveKeepScreenAwake(val);
                        await WakelockPlus.toggle(enable: val);
                        if (!context.mounted) return;
                        ToastService.info(
                          context,
                          val ? "Screen Awake ON ☀️" : "Screen Awake OFF 🌙",
                          val
                              ? "Screen will remain awake while using Countify."
                              : "Standard screen sleep enabled.",
                        );
                      },
                      secondary: const LiveAnimatedIcon(
                        icon: Icons.wb_sunny_rounded,
                        color: Color(0xFF06B6D4),
                        size: 38,
                        iconSize: 18,
                      ),
                      title: Text(
                        "Keep Screen Awake",
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Prevent screen timeout while counting",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      activeColor: const Color(0xFF06B6D4),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Backup & Export Data Section
                  if (widget.counterId == null) ...[
                    _buildSectionHeader(
                      title: "Data Backup & Export",
                      icon: Icons.backup_rounded,
                      color: const Color(0xFF8B5CF6),
                      colors: colors,
                    ),
                    const SizedBox(height: 10),

                    _buildLuxuryCard(
                      isDark: isDark,
                      child: ListTile(
                        onTap: () async {
                          final dataReport = await StorageService.exportAllData();
                          await SharePlus.instance.share(ShareParams(text: dataReport));
                          if (!context.mounted) return;
                          ToastService.success(
                            context,
                            "Export Ready",
                            "App backup data formatted and shared.",
                          );
                        },
                        leading: const LiveAnimatedIcon(
                          icon: Icons.share_rounded,
                          color: Color(0xFF8B5CF6),
                          size: 38,
                          iconSize: 18,
                        ),
                        title: Text(
                          "Export Full Backup",
                          style: TextStyle(
                            color: colors.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          "Share or copy text backup of all data",
                          style: TextStyle(
                            color: colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),

                    const SizedBox(height: 22),
                  ],

                  // Reset Data Section
                  _buildSectionHeader(
                    title: "Reset & Danger Zone",
                    icon: Icons.delete_forever_rounded,
                    color: Colors.red,
                    colors: colors,
                  ),
                  const SizedBox(height: 10),

                  // Reset Everything Card
                  _buildLuxuryCard(
                    isDark: isDark,
                    borderColor: Colors.red.withOpacity(0.4),
                    child: ListTile(
                      onTap: showResetEverythingDialog,
                      leading: const LiveAnimatedIcon(
                        icon: Icons.delete_forever_rounded,
                        color: Colors.red,
                        size: 38,
                        iconSize: 20,
                      ),
                      title: const Text(
                        "Reset Everything",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        widget.counterId == null
                            ? "Wipe ALL app data across all screens"
                            : "Wipe all data for this counter",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.red),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Reset Highest Record
                  _buildLuxuryCard(
                    isDark: isDark,
                    child: ListTile(
                      onTap: () async {
                        final localContext = context;
                        if (highestCount == 0) {
                          ToastService.info(
                            localContext,
                            "Already Zero",
                            "Highest count is already zero.",
                          );
                          return;
                        }

                        if (widget.counterId != null) {
                          await StorageService.resetCounterHighestCount(
                              widget.counterId!);
                        } else {
                          await StorageService.resetHighestCount();
                        }

                        if (!localContext.mounted) return;

                        setState(() {
                          highestCount = 0;
                        });

                        ToastService.success(
                          localContext,
                          "Record Cleared",
                          "Highest record has been cleared.",
                        );
                      },
                      leading: const LiveAnimatedIcon(
                        icon: Icons.emoji_events_rounded,
                        color: Colors.amber,
                        size: 38,
                        iconSize: 18,
                      ),
                      title: Text(
                        "Reset Highest Record",
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Clear peak count record",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Reset Action Statistics
                  _buildLuxuryCard(
                    isDark: isDark,
                    child: ListTile(
                      onTap: () async {
                        final localContext = context;
                        if (increaseCountValue == 0 &&
                            decreaseCountValue == 0 &&
                            resetCountValue == 0) {
                          ToastService.info(
                            localContext,
                            "Already Empty",
                            "Statistics are already zero.",
                          );
                          return;
                        }

                        if (widget.counterId != null) {
                          await StorageService.resetCounterStatistics(
                              widget.counterId!);
                        } else {
                          await StorageService.resetStatistics();
                        }

                        if (!localContext.mounted) return;

                        setState(() {
                          increaseCountValue = 0;
                          decreaseCountValue = 0;
                          resetCountValue = 0;
                        });

                        ToastService.success(
                          localContext,
                          "Statistics Reset",
                          "All statistics metrics cleared.",
                        );
                      },
                      leading: const LiveAnimatedIcon(
                        icon: Icons.analytics_rounded,
                        color: Colors.blue,
                        size: 38,
                        iconSize: 18,
                      ),
                      title: Text(
                        "Reset Statistics",
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        "Clear action metrics",
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App Version Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Countify v1.0.0 • Premium Edition ✨",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colors.secondaryText,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required AppThemeColors colors,
  }) {
    return Row(
      children: [
        LiveAnimatedIcon(
          icon: icon,
          color: color,
          size: 28,
          iconSize: 15,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardedAdCard(AppThemeColors colors, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiveAnimatedIcon(
                icon: Icons.card_giftcard_rounded,
                color: Color(0xFF8B5CF6),
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SUPPORT & EARN REWARDS 🎁",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Watch Video for 24H Ad-Free Pass",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Watch a short 15-second sponsor video to support Countify and unlock 24-hour ad-free pass!",
            style: TextStyle(
              fontSize: 12,
              color: colors.secondaryText,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
              label: const Text(
                "WATCH SPONSOR VIDEO (+100 REWARD)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              onPressed: () {
                AdService.showRewardedAd(
                  onUserEarnedReward: (reward) {
                    ToastService.success(
                      context,
                      "Reward Earned! 🎁",
                      "Thank you for supporting Countify! 24-Hour Pass Unlocked.",
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryCard({
    required bool isDark,
    required Widget child,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: child,
      ),
    );
  }
}
