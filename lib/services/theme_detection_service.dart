import 'package:flutter/material.dart';

enum CounterThemeStyle {
  islamic,
  fitness,
  education,
  programming,
  nature,
  productivity,
  sports,
  health,
  finance,
  creative,
  defaultTheme,
}

class ThemeDataModel {
  final String themeName;
  final String description;

  final IconData icon;

  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color accentColor;

  final CounterThemeStyle style;

  final String buttonLabel;

  const ThemeDataModel({
    required this.themeName,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.style,
    required this.buttonLabel,
  });

  /// Backward compatibility with the previous version.
  Color get color => primaryColor;
}

class ThemeDetectionService {
  static ThemeDataModel detect(String text) {
    final name = text.toLowerCase().trim();

    // ============================================================
    // ISLAMIC
    // ============================================================

    if (_containsAny(name, [
      "tasbeeh",
      "tasbih",
      "tasbeh",
      "zikr",
      "dhikr",
      "dua",
      "quran",
      "namaz",
      "salah",
      "prayer",
      "salat",
      "wazifa",
      "islamic",
      "islam",
    ])) {
      return const ThemeDataModel(
        themeName: "Islamic",
        description: "Calm • Spiritual • Reflective",
        icon: Icons.mosque_rounded,
        primaryColor: Color(0xFF3FAE55),
        secondaryColor: Color(0xFF1E6B3A),
        backgroundColor: Color(0xFF071B13),
        surfaceColor: Color(0xFF102B20),
        accentColor: Color(0xFFD4AF37),
        style: CounterThemeStyle.islamic,
        buttonLabel: "Tap to Count",
      );
    }

    // ============================================================
    // FITNESS
    // ============================================================

    if (_containsAny(name, [
      "gym",
      "push",
      "pushup",
      "pushups",
      "run",
      "running",
      "walk",
      "walking",
      "exercise",
      "workout",
      "squat",
      "squats",
      "pullup",
      "pullups",
      "fitness",
      "cycling",
      "cycle",
      "plank",
    ])) {
      return const ThemeDataModel(
        themeName: "Fitness",
        description: "Energy • Strength • Performance",
        icon: Icons.fitness_center_rounded,
        primaryColor: Color(0xFFFF9800),
        secondaryColor: Color(0xFFE65100),
        backgroundColor: Color(0xFF17110A),
        surfaceColor: Color(0xFF292015),
        accentColor: Color(0xFFFFC107),
        style: CounterThemeStyle.fitness,
        buttonLabel: "Start Set",
      );
    }

    // ============================================================
    // EDUCATION
    // ============================================================

    if (_containsAny(name, [
      "study",
      "studying",
      "book",
      "books",
      "reading",
      "read",
      "research",
      "exam",
      "study time",
      "learning",
      "learn",
      "homework",
      "assignment",
      "education",
      "school",
      "college",
      "university",
    ])) {
      return const ThemeDataModel(
        themeName: "Education",
        description: "Focus • Learning • Progress",
        icon: Icons.menu_book_rounded,
        primaryColor: Color(0xFF2196F3),
        secondaryColor: Color(0xFF1565C0),
        backgroundColor: Color(0xFF071522),
        surfaceColor: Color(0xFF102536),
        accentColor: Color(0xFF64B5F6),
        style: CounterThemeStyle.education,
        buttonLabel: "Mark Progress",
      );
    }

    // ============================================================
    // PROGRAMMING
    // ============================================================

    if (_containsAny(name, [
      "code",
      "coding",
      "programming",
      "developer",
      "development",
      "flutter",
      "dart",
      "java",
      "kotlin",
      "python",
      "javascript",
      "project",
      "debug",
      "github",
      "leetcode",
    ])) {
      return const ThemeDataModel(
        themeName: "Programming",
        description: "Build • Debug • Create",
        icon: Icons.code_rounded,
        primaryColor: Color(0xFF8B5CF6),
        secondaryColor: Color(0xFF5B21B6),
        backgroundColor: Color(0xFF0D0A14),
        surfaceColor: Color(0xFF191225),
        accentColor: Color(0xFFC084FC),
        style: CounterThemeStyle.programming,
        buttonLabel: "Run",
      );
    }

    // ============================================================
    // NATURE
    // ============================================================

    if (_containsAny(name, [
      "nature",
      "garden",
      "plant",
      "plants",
      "tree",
      "trees",
      "bird",
      "birds",
      "fishing",
      "hiking",
      "outdoor",
      "wildlife",
      "water",
      "travel",
      "camping",
    ])) {
      return const ThemeDataModel(
        themeName: "Nature",
        description: "Calm • Fresh • Natural",
        icon: Icons.eco_rounded,
        primaryColor: Color(0xFF26A269),
        secondaryColor: Color(0xFF087F5B),
        backgroundColor: Color(0xFF071712),
        surfaceColor: Color(0xFF10271E),
        accentColor: Color(0xFF8BC34A),
        style: CounterThemeStyle.nature,
        buttonLabel: "Add Count",
      );
    }

    // ============================================================
    // PRODUCTIVITY
    // ============================================================

    if (_containsAny(name, [
      "task",
      "tasks",
      "habit",
      "habits",
      "goal",
      "goals",
      "productivity",
      "routine",
      "daily",
      "work",
      "focus",
      "pomodoro",
      "checklist",
    ])) {
      return const ThemeDataModel(
        themeName: "Productivity",
        description: "Focus • Discipline • Progress",
        icon: Icons.track_changes_rounded,
        primaryColor: Color(0xFF00A8A8),
        secondaryColor: Color(0xFF006D77),
        backgroundColor: Color(0xFF071617),
        surfaceColor: Color(0xFF102628),
        accentColor: Color(0xFF4DD0E1),
        style: CounterThemeStyle.productivity,
        buttonLabel: "Complete",
      );
    }

    // ============================================================
    // SPORTS
    // ============================================================

    if (_containsAny(name, [
      "sport",
      "sports",
      "cricket",
      "football",
      "soccer",
      "basketball",
      "tennis",
      "badminton",
      "match",
      "game",
      "score",
      "player",
      "team",
      "goal",
      "lap",
    ])) {
      return const ThemeDataModel(
        themeName: "Sports",
        description: "Action • Victory • Competition",
        icon: Icons.sports_score_rounded,
        primaryColor: Color(0xFFE91E63),
        secondaryColor: Color(0xFF880E4F),
        backgroundColor: Color(0xFF1A0A10),
        surfaceColor: Color(0xFF2B1218),
        accentColor: Color(0xFFFF80AB),
        style: CounterThemeStyle.sports,
        buttonLabel: "Score",
      );
    }

    // ============================================================
    // HEALTH
    // ============================================================

    if (_containsAny(name, [
      "health",
      "medicine",
      "pill",
      "water",
      "doctor",
      "sleep",
      "blood",
      "medical",
      "vitamin",
      "dentist",
      "pharmacy",
    ])) {
      return const ThemeDataModel(
        themeName: "Health",
        description: "Vitality • Wellness • Care",
        icon: Icons.medical_services_rounded,
        primaryColor: Color(0xFF00CED1),
        secondaryColor: Color(0xFF008B8B),
        backgroundColor: Color(0xFF051919),
        surfaceColor: Color(0xFF0C2B2B),
        accentColor: Color(0xFF40E0D0),
        style: CounterThemeStyle.health,
        buttonLabel: "Take Action",
      );
    }

    // ============================================================
    // FINANCE
    // ============================================================

    if (_containsAny(name, [
      "money",
      "save",
      "budget",
      "finance",
      "expense",
      "salary",
      "coin",
      "bank",
      "crypto",
      "invest",
      "wealth",
      "billing",
    ])) {
      return const ThemeDataModel(
        themeName: "Finance",
        description: "Growth • Wealth • Stability",
        icon: Icons.account_balance_wallet_rounded,
        primaryColor: Color(0xFFFFD700),
        secondaryColor: Color(0xFF006400),
        backgroundColor: Color(0xFF0A140A),
        surfaceColor: Color(0xFF122512),
        accentColor: Color(0xFFFFDF00),
        style: CounterThemeStyle.finance,
        buttonLabel: "Log Transaction",
      );
    }

    // ============================================================
    // CREATIVE
    // ============================================================

    if (_containsAny(name, [
      "art",
      "paint",
      "write",
      "music",
      "guitar",
      "draw",
      "creative",
      "design",
      "sketch",
      "craft",
      "photo",
      "video",
      "dance",
    ])) {
      return const ThemeDataModel(
        themeName: "Creative",
        description: "Art • Imagination • Expression",
        icon: Icons.palette_rounded,
        primaryColor: Color(0xFFFFBF00),
        secondaryColor: Color(0xFF4B0082),
        backgroundColor: Color(0xFF140A1A),
        surfaceColor: Color(0xFF22122B),
        accentColor: Color(0xFFFFD700),
        style: CounterThemeStyle.creative,
        buttonLabel: "Create",
      );
    }

    // ============================================================
    // DEFAULT (UNIVERSAL PREMIUM)
    // ============================================================

    return const ThemeDataModel(
      themeName: "Universal Premium",
      description: "Luxury • Minimal • Elegant",
      icon: Icons.auto_awesome_rounded,
      primaryColor: Color(0xFF00A896),
      secondaryColor: Color(0xFF007F73),
      backgroundColor: Color(0xFF071817),
      surfaceColor: Color(0xFF102624),
      accentColor: Color(0xFF5EEAD4),
      style: CounterThemeStyle.defaultTheme,
      buttonLabel: "Tap to Count",
    );
  }

  static bool _containsAny(
      String text,
      List<String> keywords,
      ) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }

    return false;
  }
}