import 'package:flutter/material.dart';
import '../theme/app_theme_colors.dart';
class HighestCountCard extends StatelessWidget {
  final int highestCount;

  const HighestCountCard({
    super.key,
    required this.highestCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
    Theme.of(context).extension<AppThemeColors>()!;
    return Card(
      elevation: 12,
      color: colors.card,
      shadowColor: Colors.amber.withOpacity(.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),

        side: BorderSide(
          color: Colors.amber.withOpacity(.35),
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
                    color: Colors.amber.withOpacity(.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "Highest Count",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              "$highestCount",

              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.amber,
                shadows: [
                  Shadow(
                    color: Colors.amber.withOpacity(.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),            ),
            const SizedBox(height: 6),

             Text(
              "Personal Best",
              style: TextStyle(
                color: colors.secondaryText,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}