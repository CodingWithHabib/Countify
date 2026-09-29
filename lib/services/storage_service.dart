import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/history_entry.dart';
import '../models/counter_model.dart';
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
  // ===============================
  // Categories
  // ===============================

  static Future<List<String>> loadUserCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("user_categories") ?? [];
  }

  static Future<void> saveUserCategory(String categoryName) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await loadUserCategories();
    if (!categories.contains(categoryName)) {
      categories.add(categoryName);
      await prefs.setStringList("user_categories", categories);
    }
  }

  static Future<void> deleteUserCategory(String categoryName) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await loadUserCategories();
    categories.remove(categoryName);
    await prefs.setStringList("user_categories", categories);
  }

  static Future<void> saveUserCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("user_categories", categories);
  }

  // ===============================
  // Selected Counter
  // ===============================

  static Future<void> saveSelectedCounterId(
      String counterId,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "selectedCounterId",
      counterId,
    );
  }

  static Future<String?> loadSelectedCounterId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("selectedCounterId");
  }

  static Future<void> resetSelectedCounterId() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("selectedCounterId");
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
  // Reset Highest Count
  static Future<void> resetHighestCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("highestCount", 0);
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
  // Save History Entries
  static Future<void> saveHistoryEntries(
      List<HistoryEntry> history,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = history
        .map((entry) => entry.toJson())
        .toList();

    await prefs.setStringList(
      "history_entries",
      jsonList,
    );
  }

// Load History Entries
  static Future<List<HistoryEntry>> loadHistoryEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList("history_entries") ?? [];
      final List<HistoryEntry> entries = [];
      for (var e in jsonList) {
        try {
          entries.add(HistoryEntry.fromJson(e));
        } catch (_) {}
      }
      return entries;
    } catch (_) {
      return [];
    }
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

  // Save Counter Specific Statistics
  static Future<void> saveCounterStatistics({
    required String counterId,
    required int increaseCount,
    required int decreaseCount,
    required int resetCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("${counterId}_increaseCount", increaseCount);
    await prefs.setInt("${counterId}_decreaseCount", decreaseCount);
    await prefs.setInt("${counterId}_resetCount", resetCount);
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

  // Load Counter Specific Statistics
  static Future<Map<String, int>> loadCounterStatistics(String counterId) async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "increaseCount": prefs.getInt("${counterId}_increaseCount") ?? 0,
      "decreaseCount": prefs.getInt("${counterId}_decreaseCount") ?? 0,
      "resetCount": prefs.getInt("${counterId}_resetCount") ?? 0,
    };
  }

  static Future<void> resetCounterStatistics(String counterId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("${counterId}_increaseCount", 0);
    await prefs.setInt("${counterId}_decreaseCount", 0);
    await prefs.setInt("${counterId}_resetCount", 0);
  }

  static Future<void> resetCounterHighestCount(String counterId) async {
    final counters = await loadCounters();
    final index = counters.indexWhere((c) => c.id == counterId);
    if (index != -1) {
      counters[index] = counters[index].copyWith(highestCount: 0);
      await saveCounters(counters);
    }
  }
  static Future<void> resetStatistics() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("increaseCount", 0);
    await prefs.setInt("decreaseCount", 0);
    await prefs.setInt("resetCount", 0);
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

  // Expanded Achievement Categories (Persistent Section State)
  static Future<void> saveExpandedAchievementCategories(Set<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("expanded_achievement_categories", categories.toList());
  }

  static Future<Set<String>> loadExpandedAchievementCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList("expanded_achievement_categories");
      if (list != null) {
        return list.toSet();
      }
    } catch (_) {}
    return {"Beginner", "Intermediate", "Advanced", "Legendary"};
  }

  static Future<void> resetAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("unlockedAchievements");
  }

  static Future<void> resetCounterAchievements(String counterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("${counterId}_unlockedAchievements");
  }

  // Save Counter Specific Achievements
  static Future<void> saveCounterAchievements({
    required String counterId,
    required Set<int> achievements,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "${counterId}_unlockedAchievements",
      achievements.map((e) => e.toString()).toList(),
    );
  }

  // Load Counter Specific Achievements
  static Future<Set<int>> loadCounterAchievements(String counterId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("${counterId}_unlockedAchievements") ?? [];
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

  // Save Keep Screen Awake Setting
  static Future<void> saveKeepScreenAwake(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("keep_screen_awake", enabled);
  }

  // Load Keep Screen Awake Setting
  static Future<bool> loadKeepScreenAwake() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("keep_screen_awake") ?? false;
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
  // Save Streak Data
  static Future<void> saveStreak({
    required int currentStreak,
    required int bestStreak,
    required String lastActiveDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("currentStreak", currentStreak);
    await prefs.setInt("bestStreak", bestStreak);
    await prefs.setString("lastActiveDate", lastActiveDate);
  }


  // Load Streak Data
  static Future<Map<String, dynamic>> loadStreak() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "currentStreak": prefs.getInt("currentStreak") ?? 0,
      "bestStreak": prefs.getInt("bestStreak") ?? 0,
      "lastActiveDate": prefs.getString("lastActiveDate") ?? "",
    };
  }


  // Reset Streak
  static Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("currentStreak");
    await prefs.remove("bestStreak");
    await prefs.remove("lastActiveDate");
    await prefs.remove("celebrated_streak_milestones");
  }

  // Celebrated Streak Milestones
  static Future<Set<int>> loadCelebratedStreakMilestones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList("celebrated_streak_milestones") ?? [];
      return list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<bool> isStreakMilestoneCelebrated(int days) async {
    final set = await loadCelebratedStreakMilestones();
    return set.contains(days);
  }

  static Future<void> markStreakMilestoneCelebrated(int days) async {
    final set = await loadCelebratedStreakMilestones();
    set.add(days);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "celebrated_streak_milestones",
      set.map((e) => e.toString()).toList(),
    );
  }
  // Save Daily Goal
  static Future<void> saveDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("dailyGoal", goal);
  }
// ===============================
// Multiple Counters
// ===============================

  static Future<void> saveCounters(
      List<CounterModel> counters,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = counters
        .map((counter) => jsonEncode(counter.toJson()))
        .toList();

    await prefs.setStringList(
      "counters",
      data,
    );
  }

  static Future<void> markCounterAsActive(String counterId) async {
    final counters = await loadCounters();
    final updatedCounters = counters.map((counter) {
      if (counter.id == counterId) {
        return counter.copyWith(
          isActive: true,
          lastUsed: DateTime.now(),
        );
      } else {
        return counter.copyWith(isActive: false);
      }
    }).toList();
    await saveCounters(updatedCounters);
  }

  static Future<void> updateCounterData({
    required String counterId,
    required int count,
    required int highestCount,
    required int todayCount,
    int? targetAlertCount,
    bool? isVoiceEnabled,
    int? stepSize,
  }) async {
    final counters = await loadCounters();

    final index = counters.indexWhere(
          (counter) => counter.id == counterId,
    );

    if (index == -1) return;

    counters[index] = counters[index].copyWith(
      count: count,
      highestCount: highestCount,
      todayCount: todayCount,
      targetAlertCount: targetAlertCount,
      isVoiceEnabled: isVoiceEnabled,
      stepSize: stepSize,
    );

    await saveCounters(counters);
  }
  static Future<List<CounterModel>> loadCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList("counters") ?? [];

      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month}-${now.day}";
      bool needsSave = false;

      final List<CounterModel> counters = [];
      for (var e in data) {
        try {
          counters.add(CounterModel.fromJson(jsonDecode(e)));
        } catch (_) {}
      }

      // Check for daily reset
      for (int i = 0; i < counters.length; i++) {
        if (counters[i].lastUpdatedDate != todayStr) {
          counters[i] = counters[i].copyWith(
            todayCount: 0,
            lastUpdatedDate: todayStr,
          );
          needsSave = true;
        }
      }

      if (needsSave) {
        await saveCounters(counters);
      }

      return counters;
    } catch (_) {
      return [];
    }
  }

// Load Daily Goal
  static Future<int> loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("dailyGoal") ?? 100;
  }
  // Reset Current Count
  static Future<void> resetCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("count", 0);
  }


// Reset Daily Goal
  static Future<void> resetDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("dailyGoal", 0);
  }

// Reset History
  static Future<void> resetHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("history");
    await prefs.remove("history_entries");
  }

// Reset Everything (Data & Progress Reset without deleting Created Counters)
  static Future<void> resetEverything() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Preserve existing counters but reset their count values to 0
    final existingCounters = await loadCounters();
    final resetCounters = existingCounters.map((c) => c.copyWith(
      count: 0,
      highestCount: 0,
      todayCount: 0,
    )).toList();

    // 2. Preserve user profile and auth session
    final profileName = prefs.getString("user_profile_name");
    final profileEmail = prefs.getString("user_profile_email");
    final profileBio = prefs.getString("user_profile_bio");
    final profileAvatar = prefs.getString("user_profile_avatar");
    final isLoggedIn = prefs.getBool("auth_is_logged_in");
    final isGuest = prefs.getBool("auth_is_guest");
    final userCategories = prefs.getStringList("user_categories");

    // 3. Clear all stored preferences
    await prefs.clear();

    // 4. Restore preserved counters (reset to 0) & profile
    await saveCounters(resetCounters);

    if (userCategories != null) {
      await prefs.setStringList("user_categories", userCategories);
    }
    if (profileName != null) await prefs.setString("user_profile_name", profileName);
    if (profileEmail != null) await prefs.setString("user_profile_email", profileEmail);
    if (profileBio != null) await prefs.setString("user_profile_bio", profileBio);
    if (profileAvatar != null) await prefs.setString("user_profile_avatar", profileAvatar);
    if (isLoggedIn != null) await prefs.setBool("auth_is_logged_in", isLoggedIn);
    if (isGuest != null) await prefs.setBool("auth_is_guest", isGuest);

    // Default resetting progress keys
    await prefs.setInt("count", 0);
    await prefs.setInt("highestCount", 0);
    await prefs.setInt("dailyGoal", 100);
  }

  // ===============================
  // Global & Administrative
  // ===============================

  static Future<void> saveGlobalNote(String note) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("global_note_today", note);
  }

  static Future<String> loadGlobalNote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("global_note_today") ?? "";
  }

  // ===============================
  // User Profile Persistence
  // ===============================

  static Future<void> saveUserProfile({
    required String name,
    required String email,
    required String bio,
    required String avatarIcon,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_profile_name", name);
    await prefs.setString("user_profile_email", email);
    await prefs.setString("user_profile_bio", bio);
    await prefs.setString("user_profile_avatar", avatarIcon);
  }

  static Future<Map<String, String>> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        "name": prefs.getString("user_profile_name") ?? "Habib",
        "email": prefs.getString("user_profile_email") ?? "habib@countify.app",
        "bio": prefs.getString("user_profile_bio") ?? "Progress over perfection ✨",
        "avatarIcon": prefs.getString("user_profile_avatar") ?? "crown",
      };
    } catch (_) {
      return {
        "name": "Habib",
        "email": "habib@countify.app",
        "bio": "Progress over perfection ✨",
        "avatarIcon": "crown",
      };
    }
  }

  static Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("history_entries");
  }

  static Future<void> resetAllCounters() async {
    final counters = await loadCounters();
    final resetCounters = counters.map((c) => c.copyWith(
      count: 0,
      todayCount: 0,
      highestCount: 0,
    )).toList();
    await saveCounters(resetCounters);
  }

  static Future<void> resetCountersByCategory(String category) async {
    final counters = await loadCounters();
    final updatedCounters = counters.map((c) {
      if (c.category.toLowerCase() == category.toLowerCase()) {
        return c.copyWith(
          count: 0,
          todayCount: 0,
          highestCount: 0,
        );
      }
      return c;
    }).toList();
    await saveCounters(updatedCounters);
  }

  static Future<void> clearHistoryByCategory(List<String> counterIds) async {
    final history = await loadHistoryEntries();
    history.removeWhere((e) => counterIds.contains(e.counterId));
    await saveHistoryEntries(history);
  }

  static Future<void> resetIndividualCounter(String counterId) async {
    // 1. Reset Counter Model Data inside the list
    final counters = await loadCounters();
    final index = counters.indexWhere((c) => c.id == counterId);
    if (index != -1) {
      counters[index] = counters[index].copyWith(
        count: 0,
        todayCount: 0,
        highestCount: 0,
        lastUpdatedDate: DateTime.now().toIso8601String().split('T')[0],
      );
      await saveCounters(counters);
    }

    // 2. Reset Counter Specific Statistics (Increase/Decrease/Reset counts)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("${counterId}_increaseCount", 0);
    await prefs.setInt("${counterId}_decreaseCount", 0);
    await prefs.setInt("${counterId}_resetCount", 0);

    // 3. Reset Counter Specific Achievements
    await prefs.remove("${counterId}_unlockedAchievements");

    // 4. Remove History Entries ONLY for this specific counter
    final history = await loadHistoryEntries();
    history.removeWhere((e) => e.counterId == counterId);
    await saveHistoryEntries(history);
    
    // Note: We DO NOT touch global keys like "count", "highestCount", 
    // "currentStreak" etc. to avoid affecting the Main Screen.
  }

  static Future<void> deleteCounter(String counterId) async {
    final counters = await loadCounters();
    counters.removeWhere((c) => c.id == counterId);
    await saveCounters(counters);
    
    // Cleanup related data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("${counterId}_increaseCount");
    await prefs.remove("${counterId}_decreaseCount");
    await prefs.remove("${counterId}_resetCount");
    await prefs.remove("${counterId}_unlockedAchievements");
    
    final history = await loadHistoryEntries();
    history.removeWhere((e) => e.counterId == counterId);
    await saveHistoryEntries(history);
  }

  static Future<Map<String, int>> getCategoryCounts() async {
    final counters = await loadCounters();
    final Map<String, int> counts = {};
    
    for (var counter in counters) {
      final cat = counter.category;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    return counts;
  }

  static Future<List<CounterModel>> getCountersByCategory(String category) async {
    final counters = await loadCounters();
    return counters.where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
  }

  static Future<String> exportAllData() async {
    final counters = await loadCounters();
    final history = await loadHistoryEntries();
    final buffer = StringBuffer();
    
    buffer.writeln("=== COUNTIFY DATA EXPORT ===");
    buffer.writeln("Export Date: ${DateTime.now()}");
    buffer.writeln("\n--- Counters ---");
    
    for (var counter in counters) {
      buffer.writeln("Name: ${counter.name}");
      buffer.writeln("Count: ${counter.count}");
      buffer.writeln("Today: ${counter.todayCount}");
      buffer.writeln("Highest: ${counter.highestCount}");
      buffer.writeln("Category: ${counter.category}");
      buffer.writeln("------------------------");
    }
    
    buffer.writeln("\n--- Recent History (Last 50) ---");
    final recentHistory = history.take(50);
    for (var entry in recentHistory) {
      buffer.writeln("${entry.timestamp} | ${entry.counterName} | ${entry.action.name} | Count: ${entry.count}${entry.note != null ? ' | Note: ${entry.note}' : ''}");
    }
    
    return buffer.toString();
  }
}