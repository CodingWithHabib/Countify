import '../services/theme_detection_service.dart';

class CounterModel {
  final String id;
  final String name;
  final int count;
  final int highestCount;
  final String category;
  final int todayCount;
  final bool isActive;
  final int dailyGoal;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String lastUpdatedDate; // ISO format date (YYYY-MM-DD)

  final int targetAlertCount;
  final bool isVoiceEnabled;
  final int stepSize;

  // Last time the counter was interacted with.
  final DateTime? lastUsed;

  // Adaptive theme associated with this counter.
  final CounterThemeStyle themeStyle;

  const CounterModel({
    required this.id,
    required this.name,
    required this.count,
    required this.highestCount,
    this.category = "Custom",
    this.todayCount = 0,
    this.isActive = false,
    this.dailyGoal = 100,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.lastUpdatedDate = "",
    this.targetAlertCount = 33,
    this.isVoiceEnabled = false,
    this.stepSize = 1,
    this.lastUsed,
    this.themeStyle = CounterThemeStyle.defaultTheme,
  });

  CounterModel copyWith({
    String? id,
    String? name,
    int? count,
    int? highestCount,
    String? category,
    int? todayCount,
    bool? isActive,
    int? dailyGoal,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? lastUpdatedDate,
    int? targetAlertCount,
    bool? isVoiceEnabled,
    int? stepSize,
    DateTime? lastUsed,
    CounterThemeStyle? themeStyle,
  }) {
    return CounterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      highestCount: highestCount ?? this.highestCount,
      category: category ?? this.category,
      todayCount: todayCount ?? this.todayCount,
      isActive: isActive ?? this.isActive,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      targetAlertCount: targetAlertCount ?? this.targetAlertCount,
      isVoiceEnabled: isVoiceEnabled ?? this.isVoiceEnabled,
      stepSize: stepSize ?? this.stepSize,
      lastUsed: lastUsed ?? this.lastUsed,
      themeStyle: themeStyle ?? this.themeStyle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "count": count,
      "highestCount": highestCount,
      "category": category,
      "todayCount": todayCount,
      "isActive": isActive,
      "dailyGoal": dailyGoal,
      "soundEnabled": soundEnabled,
      "vibrationEnabled": vibrationEnabled,
      "lastUpdatedDate": lastUpdatedDate,
      "targetAlertCount": targetAlertCount,
      "isVoiceEnabled": isVoiceEnabled,
      "stepSize": stepSize,
      "lastUsed": lastUsed?.toIso8601String(),

      // Save only the theme identifier.
      "themeStyle": themeStyle.name,
    };
  }

  factory CounterModel.fromJson(Map<String, dynamic> json) {
    return CounterModel(
      id: json["id"],
      name: json["name"],
      count: json["count"],
      highestCount: json["highestCount"],
      category: json["category"] ?? "Custom",
      todayCount: json["todayCount"] ?? 0,
      isActive: json["isActive"] ?? false,
      dailyGoal: json["dailyGoal"] ?? 100,
      soundEnabled: json["soundEnabled"] ?? true,
      vibrationEnabled: json["vibrationEnabled"] ?? true,
      lastUpdatedDate: json["lastUpdatedDate"] ?? "",
      targetAlertCount: json["targetAlertCount"] ?? 33,
      isVoiceEnabled: json["isVoiceEnabled"] ?? false,
      stepSize: json["stepSize"] ?? 1,
      lastUsed: json["lastUsed"] != null ? DateTime.parse(json["lastUsed"]) : null,

      // Backward compatible:
      // old counters without themeStyle use defaultTheme.
      themeStyle: _themeStyleFromJson(
        json["themeStyle"],
      ),
    );
  }

  static CounterThemeStyle _themeStyleFromJson(
      dynamic value,
      ) {
    if (value == null) {
      return CounterThemeStyle.defaultTheme;
    }

    for (final style in CounterThemeStyle.values) {
      if (style.name == value.toString()) {
        return style;
      }
    }

    return CounterThemeStyle.defaultTheme;
  }
}