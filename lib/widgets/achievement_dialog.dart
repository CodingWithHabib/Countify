import 'package:flutter/material.dart';

class AchievementDialog extends StatelessWidget {
  final String title;
  final String description;

  const AchievementDialog({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,

      child: Container(
        padding: const EdgeInsets.all(25),

        decoration: BoxDecoration(
          color: const Color(0xFF1C2533),

          borderRadius: BorderRadius.circular(30),

          border: Border.all(
            color: Colors.amber.withOpacity(.5),
            width: 2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(.35),
              blurRadius: 30,
              spreadRadius: 3,
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.amber,
              size: 80,
            ),

            const SizedBox(height: 20),

            const Text(
              "Achievement Unlocked!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,

                  foregroundColor: Colors.black,

                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}