import 'package:flutter/material.dart';
import '../models/achievement.dart';
import 'dart:math';
class AchievementScreen extends StatelessWidget {
  final Set<int> unlockedAchievements;

  const AchievementScreen({
    super.key,
    required this.unlockedAchievements,
  });

  @override
  Widget build(BuildContext context) {
    final achievementList = achievements;
    Achievement? nextAchievement;

    for (final achievement in achievementList) {
      if (!unlockedAchievements.contains(achievement.milestone)) {
        nextAchievement = achievement;
        break;
      }
    }
    final unlockedCount = unlockedAchievements.length;

    final progress =
        unlockedCount / achievementList.length;


    for (final achievement in achievementList) {
      if (!unlockedAchievements.contains(
        achievement.milestone,
      )) {
        nextAchievement = achievement;
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Progress Card

          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFC107),
                  Color(0xFFFF9800),
                ],
              ),
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Center(
                  child: const Column(
                    children: [

                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 60,
                      ),

                      SizedBox(height: 12),

                      Text(
                        "Achievements",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  "${unlockedAchievements.length} / ${achievementList.length} Unlocked",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 18),

                LinearProgressIndicator(
                  value: unlockedAchievements.length / achievementList.length,
                  minHeight: 10,

                  backgroundColor: Colors.white30,

                  valueColor: const AlwaysStoppedAnimation(
                    Colors.white,
                  ),

                  borderRadius: BorderRadius.circular(10),
                ),

                const SizedBox(height: 10),

                Text(
                  "${((unlockedAchievements.length / achievementList.length) * 100).toStringAsFixed(0)}% Completed",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          if (nextAchievement != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF232837),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0x33FFC107),
                    child: Icon(
                      Icons.flag_rounded,
                      color: Colors.amber,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Next Achievement",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          nextAchievement.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          nextAchievement.description,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: achievementList.length,
            itemBuilder: (context, index) {
              final achievement = achievementList[index];

              final unlocked = unlockedAchievements.contains(
                achievement.milestone,
              );

              return Card(
                elevation: unlocked ? 12 : 3,

                color: unlocked
                    ? const Color(0xFF2B2F3A)
                    : const Color(0xFF1D212B),

                margin: const EdgeInsets.only(bottom: 15),
                shadowColor:
                unlocked ? Colors.amber : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),

                  side: BorderSide(
                    color: unlocked
                        ? Colors.amber
                        : Colors.transparent,

                    width: 1.5,
                  ),
                ),

                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),

                  leading: CircleAvatar(
                    radius: 24,

                    backgroundColor: unlocked
                        ? Colors.amber.withOpacity(.15)
                        : Colors.grey.withOpacity(.12),

                    child: Icon(
                      unlocked
                          ? Icons.workspace_premium
                          : Icons.lock,

                      color: unlocked
                          ? Colors.amber
                          : Colors.grey,

                      size: 32,
                    ),
                  ),

                  title: Text(
                    achievement.title,

                    style: TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                      fontSize: 19,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                    const EdgeInsets.only(top: 5),

                    child: Text(
                      achievement.description,

                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  trailing: unlocked
                      ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                  )
                      : Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                      size: 26,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}