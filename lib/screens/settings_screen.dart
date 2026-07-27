import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/theme_service.dart';
import '../main.dart';
import '../theme/app_theme_colors.dart';
import '../services/toast_service.dart';
import '../dialogs/goal_dialog.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  bool soundEnabled = true;
  bool darkModeEnabled = true;
  bool vibrationEnabled = true;
  int dailyGoal = 100;
  @override
  void initState() {
    super.initState();
    loadSettings();
  }
  Future<void> selectDailyGoal() async {
    final goal = await showGoalDialog(
      context: context,
      dailyGoal: dailyGoal,
    );

    if (goal == null) return;

    setState(() {
      dailyGoal = goal;
    });

    await StorageService.saveDailyGoal(goal);

    ToastService.success(
      context,
      "Goal Updated",
      "Daily goal set to $goal counts.",
    );
  }
  Future<void> loadSettings() async {
    soundEnabled = await StorageService.loadSound();
    vibrationEnabled = await StorageService.loadVibration();
    darkModeEnabled = await StorageService.loadDarkMode();
    dailyGoal = await StorageService.loadDailyGoal();
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final colors =
    Theme.of(context).extension<AppThemeColors>()!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          Card(
            color: colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            child: SwitchListTile(
              value: soundEnabled,
              onChanged: (value) async {
                setState(() {
                  soundEnabled = value;
                });
                SoundService.soundEnabled = value;
                await StorageService.saveSound(value);
              },
              secondary: const Icon(
                Icons.volume_up_rounded,
                color: Colors.green,
              ),

              title:  Text(
                "Sound",
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: Text(
                "Enable button sound",
                style: TextStyle(
                  color: colors.secondaryText,
                ),
              ),

              activeColor: Colors.green,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            child: SwitchListTile(
              value: vibrationEnabled,

              onChanged: (value) async {
                setState(() {
                  vibrationEnabled = value;
                });

                VibrationService.vibrationEnabled = value;

                await StorageService.saveVibration(value);
              },

              secondary: const Icon(
                Icons.vibration,
                color: Colors.orange,
              ),

              title:  Text(
                "Vibration",
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle:  Text(
                "Enable button vibration",
                style: TextStyle(
                  color: colors.secondaryText,
                ),
              ),

              activeColor: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SwitchListTile(
              value: darkModeEnabled,

              onChanged: (value) async {
                setState(() {
                  darkModeEnabled = value;
                });

                await ThemeService.changeTheme(value);

                MyApp.of(context)?.refreshTheme();
              },

              secondary: const Icon(
                Icons.dark_mode,
                color: Colors.blue,
              ),

              title:  Text(
                "Dark Mode",
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle:  Text(
                "Enable dark theme",
                style: TextStyle(
                  color: colors.secondaryText,
                ),
              ),

              activeColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.flag_rounded,
                color: Colors.deepOrange,
              ),
              title: const Text("Daily Goal"),
              subtitle: Text("$dailyGoal Counts"),
              trailing: const Icon(Icons.chevron_right),
              onTap: selectDailyGoal,
            ),
          ),
        ],
      ),
    );
  }
}