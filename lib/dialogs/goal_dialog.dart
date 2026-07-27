import 'package:flutter/material.dart';
import '../services/toast_service.dart';

Future<int?> showGoalDialog({
  required BuildContext context,
  required int dailyGoal,
}) async {
  final goals = [50, 100, 250, 500, 1000, -1];

  final selected = await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Daily Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: goals.map((goal) {
            return ListTile(
              title: Text(
                goal == -1 ? "Custom..." : "$goal Counts",
              ),
              trailing: dailyGoal == goal
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context, goal);
              },
            );
          }).toList(),
        ),
      );
    },
  );

  if (selected == null) return null;

  if (selected != -1) {
    return selected;
  }

  final controller = TextEditingController();

  return await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Custom Daily Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: "Daily Goal",
            hintText: "e.g. 750",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);

              if (value != null &&
                  value > 0 &&
                  value <= 999999) {
                Navigator.pop(context, value);
              } else {
                ToastService.error(
                  context,
                  "Invalid Goal",
                  "Please enter a valid goal between 1 and 999999.",
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}