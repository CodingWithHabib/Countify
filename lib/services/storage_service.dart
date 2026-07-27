import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Save Count
  static Future<void> saveCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("count", count);
  }

  // Load Count
  static Future<int> loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("count") ?? 0;
  }

  // Save Highest Count
  static Future<void> saveHighestCount(int highestCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("highestCount", highestCount);
  }

  // Load Highest Count
  static Future<int> loadHighestCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("highestCount") ?? 0;
  }
  // Save History
  static Future<void> saveHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("history", history);
  }

// Load History
  static Future<List<String>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("history") ?? [];
  }
  // Save Statistics
  static Future<void> saveStatistics({
    required int increaseCount,
    required int decreaseCount,
    required int resetCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("increaseCount", increaseCount);
    await prefs.setInt("decreaseCount", decreaseCount);
    await prefs.setInt("resetCount", resetCount);
  }

// Load Statistics
  static Future<Map<String, int>> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "increaseCount": prefs.getInt("increaseCount") ?? 0,
      "decreaseCount": prefs.getInt("decreaseCount") ?? 0,
      "resetCount": prefs.getInt("resetCount") ?? 0,
    };
  }
  // Save Achievements
  static Future<void> saveAchievements(Set<int> achievements) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      "unlockedAchievements",
      achievements.map((e) => e.toString()).toList(),
    );
  }


  // Load Achievements
  static Future<Set<int>> loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();

    final list =
        prefs.getStringList("unlockedAchievements") ?? [];

    return list.map((e) => int.parse(e)).toSet();
  }
  // Save Sound Setting
  static Future<void> saveSound(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("sound_enabled", enabled);

  }
// Load Sound Setting
  static Future<bool> loadSound() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getBool("sound_enabled") ?? true;

    return value;
  }
  // Save Vibration Setting
  static Future<void> saveVibration(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("vibration_enabled", enabled);
  }

// Load Vibration Setting
  static Future<bool> loadVibration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("vibration_enabled") ?? true;
  }
  // Save Theme
  static Future<void> saveDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark_mode", enabled);
  }

// Load Theme
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("dark_mode") ?? true;
  }
  // Save Daily Goal
  static Future<void> saveDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("dailyGoal", goal);
  }

// Load Daily Goal
  static Future<int> loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("dailyGoal") ?? 100;
  }
}