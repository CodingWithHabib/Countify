import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/counter_model.dart';
import '../services/theme_detection_service.dart';

class WorkspaceCounterCard extends StatelessWidget {
  final CounterModel counter;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const WorkspaceCounterCard({
    super.key,
    required this.counter,
    required this.onIncrement,
    required this.onDecrement,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeDetectionService.detect(counter.category.isNotEmpty ? counter.category : counter.name);
    final primaryColor = themeData.primaryColor;

    return GestureDetector(
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          counter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          counter.name, // Using name as a placeholder for "SubhanAllah" style subtitle if available
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Center Count
              Center(
                child: Text(
                  '${counter.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              // Bottom Row Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      icon: Icons.remove_rounded,
                      onTap: onDecrement,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildButton(
                      icon: Icons.add_rounded,
                      onTap: onIncrement,
                      color: primaryColor.withOpacity(0.15),
                      borderColor: primaryColor.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),);
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    Color? borderColor,
  }) {
    return ScaleButton(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor ?? Colors.white.withOpacity(0.1),
            width: 0.8,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isPressed ? 0.92 : 1.0,
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}