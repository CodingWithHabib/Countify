import 'package:flutter/material.dart';

class StreakMilestone {
  final int days;
  final String title;
  final String reward;
  final IconData icon;
  final Color color;

  const StreakMilestone({
    required this.days,
    required this.title,
    required this.reward,
    required this.icon,
    required this.color,
  });

  static const List<StreakMilestone> allMilestones = [
    StreakMilestone(
      days: 1,
      title: "First Spark ⚡",
      reward: "Ignited your counting journey",
      icon: Icons.bolt_rounded,
      color: Color(0xFF3B82F6),
    ),
    StreakMilestone(
      days: 3,
      title: "Tri-Strike 🔥",
      reward: "3 Days of consistent momentum",
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFF97316),
    ),
    StreakMilestone(
      days: 7,
      title: "Weekly Warrior 🛡️",
      reward: "1 Full week uninterrupted streak",
      icon: Icons.shield_rounded,
      color: Color(0xFF10B981),
    ),
    StreakMilestone(
      days: 14,
      title: "Fortnight Flame 👑",
      reward: "14 Days of unwavering dedication",
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFF8B5CF6),
    ),
    StreakMilestone(
      days: 30,
      title: "Monthly Legend 🏆",
      reward: "30 Days habit mastery achieved",
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFF59E0B),
    ),
    StreakMilestone(
      days: 50,
      title: "Half Century 🎖️",
      reward: "50 Days of unshakeable focus",
      icon: Icons.military_tech_rounded,
      color: Color(0xFFEC4899),
    ),
    StreakMilestone(
      days: 100,
      title: "Century Elite 💎",
      reward: "100 Days streak hall of fame",
      icon: Icons.diamond_rounded,
      color: Color(0xFF06B6D4),
    ),
    StreakMilestone(
      days: 365,
      title: "Year of Fire ✨",
      reward: "365 Days ultimate champion",
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFFFD700),
    ),
  ];

  static StreakMilestone? getMilestoneForDays(int days) {
    for (var m in allMilestones) {
      if (m.days == days) return m;
    }
    return null;
  }
}
