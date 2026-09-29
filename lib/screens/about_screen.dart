import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme_colors.dart';
import '../services/share_service.dart';
import '../services/toast_service.dart';
import '../services/theme_service.dart';
import '../widgets/live_animated_icon.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  void _showRatingDialog() {
    int selectedStars = 5;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final colors = Theme.of(ctx).extension<AppThemeColors>()!;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.25),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LiveAnimatedIcon(
                      icon: Icons.star_rate_rounded,
                      color: Colors.amber,
                      size: 68,
                      iconSize: 34,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Enjoying Countify?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tap stars to rate your experience!",
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starNum = index + 1;
                        return IconButton(
                          icon: Icon(
                            starNum <= selectedStars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 36,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedStars = starNum;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: Text(
                              "Maybe Later",
                              style: TextStyle(color: colors.primaryText),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogCtx);
                              ToastService.success(
                                context,
                                "Thank You! ⭐",
                                "Thanks for rating Countify $selectedStars stars!",
                              );
                            },
                            child: const Text(
                              "Submit Rating",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final colors = Theme.of(ctx).extension<AppThemeColors>()!;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 520),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const LiveAnimatedIcon(
                      icon: Icons.shield_rounded,
                      color: Color(0xFF10B981),
                      size: 44,
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
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "PRIVACY GUARANTEE 🔒",
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Privacy Policy",
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
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      "🔒 100% Offline & Private:\n"
                      "Countify respects your complete privacy. All counter data, history logs, daily targets, and custom settings are stored 100% locally on your device.\n\n"
                      "🌐 Zero Data Collection:\n"
                      "We do not track, collect, or upload any personal metrics, counts, or user behavior to external servers or cloud services.\n\n"
                      "🛡️ Complete Control:\n"
                      "You retain 100% control over your data. You can export a full text backup or clear all data at any time via Settings.\n\n"
                      "✨ Peaceful Experience:\n"
                      "Designed for peaceful, undisturbed counting and focus.",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: colors.primaryText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Understood",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = ThemeService.primaryColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF0F172A).withOpacity(0.85)
            : Colors.white.withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiveAnimatedIcon(
              icon: Icons.info_outline_rounded,
              color: primaryColor,
              size: 32,
              iconSize: 17,
            ),
            const SizedBox(width: 8),
            Text(
              "About Countify",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colors.primaryText,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Moving Ambient Background Mesh
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              final double progress = _bgAnimationController.value;
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (progress * 30),
                    right: -60 + (progress * 20),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor
                              .withOpacity(isDark ? 0.12 : 0.15),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                children: [
                  // App Brand Banner Header
                  _buildAppHeaderBanner(colors, isDark, primaryColor),

                  const SizedBox(height: 20),

                  // Release Notes / What's New Card
                  _buildChangelogCard(colors, isDark, primaryColor),

                  const SizedBox(height: 22),

                  // App Features Matrix
                  _buildSectionHeader("Key Capabilities", Icons.auto_awesome_rounded, primaryColor, colors),
                  const SizedBox(height: 10),
                  _buildCapabilitiesGrid(colors, isDark),

                  const SizedBox(height: 22),

                  // Technical Specifications Card
                  _buildSectionHeader("Tech Architecture", Icons.memory_rounded, const Color(0xFF10B981), colors),
                  const SizedBox(height: 10),
                  _buildTechSpecsCard(colors, isDark),

                  const SizedBox(height: 22),

                  // Developer Bio Card
                  _buildSectionHeader("Developer", Icons.code_rounded, const Color(0xFF8B5CF6), colors),
                  const SizedBox(height: 10),
                  _buildDeveloperCard(colors, isDark),

                  const SizedBox(height: 22),

                  // Quick Actions & Community Section
                  _buildSectionHeader("Actions & Info", Icons.touch_app_rounded, const Color(0xFFF59E0B), colors),
                  const SizedBox(height: 10),
                  _buildActionsCard(colors, isDark),

                  const SizedBox(height: 28),

                  // Footer Version Tag
                  Center(
                    child: Text(
                      "Crafted with Flutter & ❤️ for Productivity",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.secondaryText,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeaderBanner(
      AppThemeColors colors, bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(isDark ? 0.12 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          LiveAnimatedIcon(
            icon: Icons.calculate_rounded,
            color: primaryColor,
            size: 88,
            iconSize: 44,
          ),
          const SizedBox(height: 16),
          Text(
            "Countify",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colors.primaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "Version 1.0.0 Pro Edition ✨",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Countify helps you track counts, monitor progress, build streaks, and view useful analytics in a clean, luxury interface.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogCard(
      AppThemeColors colors, bool isDark, Color primaryColor) {
    final highlights = [
      "✨ Live Animated Icons with pulse & floating motion",
      "🎨 8 Custom Accent Themes applied globally",
      "📊 Analytics Screen with peak time & category distribution",
      "🔥 Streak Milestone celebrations & confetti explosions",
      "📱 Adaptive Edge-to-Edge & multi-counter support",
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiveAnimatedIcon(
                icon: Icons.new_releases_rounded,
                color: Colors.amber,
                size: 38,
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Text(
                "What's New in v1.0.0",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...highlights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilitiesGrid(AppThemeColors colors, bool isDark) {
    final capabilities = [
      {
        "title": "History Tracking",
        "desc": "Full chronological activity logs",
        "icon": Icons.history_rounded,
        "color": const Color(0xFF3B82F6),
      },
      {
        "title": "Analytics & Stats",
        "desc": "Peak hour & category metrics",
        "icon": Icons.analytics_rounded,
        "color": const Color(0xFF10B981),
      },
      {
        "title": "Daily Targets",
        "desc": "Custom goal tracker & alerts",
        "icon": Icons.flag_rounded,
        "color": const Color(0xFFF97316),
      },
      {
        "title": "Streak Engine",
        "desc": "Milestone rewards & confetti",
        "icon": Icons.local_fire_department_rounded,
        "color": const Color(0xFFEF4444),
      },
    ];

    return Column(
      children: capabilities.map((cap) {
        final color = cap["color"] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              LiveAnimatedIcon(
                icon: cap["icon"] as IconData,
                color: color,
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cap["title"] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cap["desc"] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTechSpecsCard(AppThemeColors colors, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        children: [
          _buildSpecRow("Framework", "Flutter 3.x • Dart 3", colors),
          const Divider(height: 20),
          _buildSpecRow("Storage", "100% Offline Local Engine", colors),
          const Divider(height: 20),
          _buildSpecRow("Performance", "Smooth 60/120 FPS Rendering", colors),
          const Divider(height: 20),
          _buildSpecRow("Privacy", "Zero Cloud Tracking & Ads Free", colors),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, AppThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.secondaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(AppThemeColors colors, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        children: [
          const LiveAnimatedIcon(
            icon: Icons.code_rounded,
            color: Color(0xFF8B5CF6),
            size: 48,
            iconSize: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Coding With Habib",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Senior Flutter & Mobile Architect",
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(AppThemeColors colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06)),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const LiveAnimatedIcon(
              icon: Icons.star_rate_rounded,
              color: Colors.amber,
              size: 38,
              iconSize: 18,
            ),
            title: Text(
              "Rate Countify App",
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "Show your love & feedback",
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _showRatingDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const LiveAnimatedIcon(
              icon: Icons.share_rounded,
              color: Color(0xFF3B82F6),
              size: 38,
              iconSize: 18,
            ),
            title: Text(
              "Share App with Friends",
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "Spread the word about Countify",
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              await ShareService.shareApp();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const LiveAnimatedIcon(
              icon: Icons.privacy_tip_rounded,
              color: Color(0xFF10B981),
              size: 38,
              iconSize: 18,
            ),
            title: Text(
              "Privacy Policy & Local Storage",
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "100% offline data guarantee",
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _showPrivacyPolicyDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const LiveAnimatedIcon(
              icon: Icons.description_rounded,
              color: Colors.deepPurple,
              size: 38,
              iconSize: 18,
            ),
            title: Text(
              "Open Source Licenses",
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "View third-party software attribution",
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: "Countify",
                applicationVersion: "1.0.0",
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    AppThemeColors colors,
  ) {
    return Row(
      children: [
        LiveAnimatedIcon(
          icon: icon,
          color: color,
          size: 28,
          iconSize: 15,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
