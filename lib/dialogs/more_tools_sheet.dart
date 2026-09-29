import 'package:flutter/material.dart';
import '../widgets/live_animated_icon.dart';
import '../screens/category_hub_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';
import '../services/theme_service.dart';

void showMoreToolsSheet({
  required BuildContext context,
  required int count,
  required int highestCount,
  required int increaseCountValue,
  required int decreaseCountValue,
  required int resetCountValue,
  required int currentStreak,
  required int bestStreak,
  required int dailyGoal,
  required VoidCallback onReload,
  required VoidCallback onRefreshTheme,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0D1016),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "MORE TOOLS & SHORTCUTS ⚡",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const LiveAnimatedIcon(
                  icon: Icons.dashboard_customize_rounded,
                  color: Color(0xFF3B82F6),
                  size: 38,
                  iconSize: 18,
                ),
                title: const Text("Manage Counters & Workspaces",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Create, edit & manage custom counters",
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white60),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryHubScreen()));
                },
              ),
              ListTile(
                leading: const LiveAnimatedIcon(
                  icon: Icons.analytics_rounded,
                  color: Color(0xFF10B981),
                  size: 38,
                  iconSize: 18,
                ),
                title: const Text("Analytics & Statistics",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Peak time & category distribution",
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white60),
                onTap: () {
                  Navigator.pop(ctx);
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
              ListTile(
                leading: const LiveAnimatedIcon(
                  icon: Icons.color_lens_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 38,
                  iconSize: 18,
                ),
                title: const Text("Theme & Settings",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Custom themes, audio & preferences",
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white60),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  await ThemeService.init();
                  onRefreshTheme();
                  onReload();
                },
              ),
              ListTile(
                leading: const LiveAnimatedIcon(
                  icon: Icons.info_outline_rounded,
                  color: Color(0xFFEC4899),
                  size: 38,
                  iconSize: 18,
                ),
                title: const Text("About Countify",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text("Version 1.0.0 Pro • Developer info",
                    style: TextStyle(color: Colors.white60, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white60),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}