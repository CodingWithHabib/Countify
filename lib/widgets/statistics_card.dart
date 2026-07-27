import 'package:flutter/material.dart';
import '../theme/app_theme_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors =
    Theme.of(context).extension<AppThemeColors>()!;
    return Card(
      elevation: 12,
        shadowColor: Colors.blue.withOpacity(.20),
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),

        side: BorderSide(
          color: Colors.blue.withOpacity(.30),
          width: 1.5,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "Statistics",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "⬆ Increase",
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "$increaseCount",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "⬇ Decrease",
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "$decreaseCount",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "🔄 Reset",
                    style: TextStyle(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "$resetCount",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}