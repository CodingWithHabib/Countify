import 'package:flutter/material.dart';
import '../services/toast_service.dart';
import '../widgets/live_animated_icon.dart';
import '../theme/app_theme_colors.dart';

Future<int?> showGoalDialog({
  required BuildContext context,
  required int dailyGoal,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = Theme.of(context).extension<AppThemeColors>()!;
  final presetGoals = [50, 100, 250, 500, 1000, 3300];

  final controller = TextEditingController(text: dailyGoal > 0 ? "$dailyGoal" : "100");

  return await showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      int tempGoal = dailyGoal > 0 ? dailyGoal : 100;

      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFF97316).withOpacity(0.4),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.2),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const LiveAnimatedIcon(
                          icon: Icons.flag_rounded,
                          color: Color(0xFFF97316),
                          size: 46,
                          iconSize: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "DAILY TARGET 🎯",
                                  style: TextStyle(
                                    color: Color(0xFFF97316),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Set Daily Goal",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Quick Target Presets",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presetGoals.map((goal) {
                        final isSelected = tempGoal == goal;
                        return ChoiceChip(
                          label: Text(
                            "$goal Counts",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : colors.primaryText,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF97316),
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFF97316)
                                  : (isDark ? Colors.white12 : Colors.black12),
                            ),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                tempGoal = goal;
                                controller.text = "$goal";
                                controller.selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.text.length),
                                );
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      "Custom Target Input",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade100,
                        hintText: "Enter daily count goal...",
                        hintStyle: TextStyle(
                          color: colors.secondaryText.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFF97316),
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.edit_rounded,
                          color: Color(0xFFF97316),
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val.trim());
                        if (parsed != null && parsed > 0) {
                          setDialogState(() {
                            tempGoal = parsed;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogCtx, null),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: colors.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFFF97316).withOpacity(0.4),
                            ),
                            onPressed: () {
                              final val = int.tryParse(controller.text.trim());
                              if (val != null && val > 0 && val <= 999999) {
                                Navigator.pop(dialogCtx, val);
                              } else {
                                ToastService.error(
                                  context,
                                  "Invalid Goal",
                                  "Please enter a valid target between 1 and 999999.",
                                );
                              }
                            },
                            child: const Text(
                              "Save Target",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
