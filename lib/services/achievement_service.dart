import '../models/achievement.dart';

class AchievementService {
  static Achievement? checkAchievement(int count) {
    for (final achievement in achievements) {
      if (achievement.milestone == count) {
        return achievement;
      }
    }
    return null;
  }
}