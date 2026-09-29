import 'package:flutter/material.dart';
import '../theme/app_theme_colors.dart';
import 'live_animated_icon.dart';

class StatisticsCard extends StatelessWidget {
  final int increaseCount;
  final int decreaseCount;
  final int resetCount;

  const StatisticsCard({
    super.key,
    required this.increaseCount,
    required this.decreaseCount,
    required this.resetCount,
  });

  int get total => increaseCount + decreaseCount + resetCount;

  Widget buildStatTile({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    final double pct = total > 0 ? (value / total) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? color.withOpacity(0.08)
            : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              LiveAnimatedIcon(
                icon: icon,
                color: color,
                size: 40,
                iconSize: 18,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      total > 0
                          ? "${(pct * 100).toStringAsFixed(1)}% of total actions"
                          : "No actions recorded",
                      style: TextStyle(
                        color: colors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "$value",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Percentage Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.blue.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(isDark ? 0.12 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const LiveAnimatedIcon(
                  icon: Icons.pie_chart_rounded,
                  color: Colors.purple,
                  size: 38,
                  iconSize: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  "Detailed Action Metrics",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            buildStatTile(
              title: "Increments (+)",
              value: increaseCount,
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xFF10B981),
              colors: colors,
              isDark: isDark,
            ),
            buildStatTile(
              title: "Decrements (-)",
              value: decreaseCount,
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xFFEF4444),
              colors: colors,
              isDark: isDark,
            ),
            buildStatTile(
              title: "Resets (↺)",
              value: resetCount,
              icon: Icons.refresh_rounded,
              color: const Color(0xFFF59E0B),
              colors: colors,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}
