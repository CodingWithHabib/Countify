import 'package:flutter/material.dart';

class Achievement {
  final int milestone;
  final String title;
  final String description;
  final String category;
  final IconData icon;

  const Achievement({
    required this.milestone,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
  });
}

const List<Achievement> achievements = [
  // ===========================
  // Beginner
  // ===========================

  Achievement(
    milestone: 1,
    title: "First Tap",
    description: "Made your first count",
    category: "Beginner",
    icon: Icons.star_rounded,
  ),

  Achievement(
    milestone: 5,
    title: "Warm Up",
    description: "Reached 5 Counts",
    category: "Beginner",
    icon: Icons.local_fire_department_rounded,
  ),

  Achievement(
    milestone: 10,
    title: "Getting Started",
    description: "Reached 10 Counts",
    category: "Beginner",
    icon: Icons.looks_one_rounded,
  ),

  Achievement(
    milestone: 25,
    title: "Quarter Century",
    description: "Reached 25 Counts",
    category: "Beginner",
    icon: Icons.flag_rounded,
  ),

  // ===========================
  // Intermediate
  // ===========================

  Achievement(
    milestone: 50,
    title: "Half Century",
    description: "Reached 50 Counts",
    category: "Intermediate",
    icon: Icons.workspace_premium_rounded,
  ),

  Achievement(
    milestone: 100,
    title: "Century",
    description: "Reached 100 Counts",
    category: "Intermediate",
    icon: Icons.emoji_events_rounded,
  ),

  Achievement(
    milestone: 200,
    title: "Double Century",
    description: "Reached 200 Counts",
    category: "Intermediate",
    icon: Icons.military_tech_rounded,
  ),

  Achievement(
    milestone: 250,
    title: "Rising Legend",
    description: "Reached 250 Counts",
    category: "Intermediate",
    icon: Icons.rocket_launch_rounded,
  ),

  // ===========================
  // Advanced
  // ===========================

  Achievement(
    milestone: 500,
    title: "Count Master",
    description: "Reached 500 Counts",
    category: "Advanced",
    icon: Icons.workspace_premium,
  ),

  Achievement(
    milestone: 750,
    title: "Elite Counter",
    description: "Reached 750 Counts",
    category: "Advanced",
    icon: Icons.diamond_rounded,
  ),

  Achievement(
    milestone: 1000,
    title: "Count Champion",
    description: "Reached 1000 Counts",
    category: "Advanced",
    icon: Icons.king_bed_rounded,
  ),

  Achievement(
    milestone: 2500,
    title: "Count Veteran",
    description: "Reached 2500 Counts",
    category: "Advanced",
    icon: Icons.auto_awesome_rounded,
  ),

  // ===========================
  // Legendary
  // ===========================

  Achievement(
    milestone: 5000,
    title: "Count Legend",
    description: "Reached 5000 Counts",
    category: "Legendary",
    icon: Icons.whatshot_rounded,
  ),

  Achievement(
    milestone: 10000,
    title: "Grand Master",
    description: "Reached 10000 Counts",
    category: "Legendary",
    icon: Icons.stars_rounded,
  ),

  Achievement(
    milestone: 25000,
    title: "Ultimate Counter",
    description: "Reached 25000 Counts",
    category: "Legendary",
    icon: Icons.bolt_rounded,
  ),

  Achievement(
    milestone: 50000,
    title: "Countify Immortal",
    description: "Reached 50000 Counts",
    category: "Legendary",
    icon: Icons.auto_awesome,
  ),
];