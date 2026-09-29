import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../services/toast_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/live_animated_icon.dart';
import 'settings_screen.dart';
import 'achievement_screen.dart';
import 'statistics_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int currentCount;
  final int highestCount;
  final int currentStreak;
  final int bestStreak;
  final Set<int> unlockedAchievements;

  const ProfileScreen({
    super.key,
    required this.currentCount,
    required this.highestCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.unlockedAchievements,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  String userName = "Habib";
  String userEmail = "habib@countify.app";
  String userBio = "Progress over perfection ✨";
  String userAvatar = "crown"; // crown, star, champion, diamond, flame

  bool isGuest = false;
  bool isLoggedIn = false;

  int totalActions = 0;
  bool isLoading = true;

  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _loadProfileData();
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final session = await AuthService.init();
    final stats = await StorageService.loadStatistics();

    final inc = stats["increaseCount"] ?? 0;
    final dec = stats["decreaseCount"] ?? 0;
    final res = stats["resetCount"] ?? 0;

    if (mounted) {
      setState(() {
        userName = session.name;
        userEmail = session.email;
        userBio = session.bio;
        userAvatar = session.avatarIcon;
        isGuest = session.isGuest;
        isLoggedIn = session.isLoggedIn;
        totalActions = inc + dec + res;
        isLoading = false;
      });
    }
  }

  String get userRankTitle {
    final unlocked = widget.unlockedAchievements.length;
    if (unlocked >= 12) return "Countify Immortal 👑";
    if (unlocked >= 8) return "Grandmaster Rank 🏆";
    if (unlocked >= 5) return "Pro Achiever ⚡";
    if (unlocked >= 2) return "Rising Star 📈";
    return "Pioneer Novice 🌱";
  }

  IconData get avatarIconData {
    return switch (userAvatar) {
      "star" => Icons.star_rounded,
      "champion" => Icons.emoji_events_rounded,
      "diamond" => Icons.diamond_rounded,
      "flame" => Icons.local_fire_department_rounded,
      _ => Icons.workspace_premium_rounded,
    };
  }

  void _showEditProfileDialog() {
    bool isRegisterMode = false;

    final nameController = TextEditingController(
        text: (userName == "Guest User" || isGuest) ? "" : userName);
    final emailController = TextEditingController(
        text: (userEmail == "guest@countify.app" || isGuest) ? "" : userEmail);
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final bioController = TextEditingController(text: userBio);
    String selectedAvatar = userAvatar;
    bool obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final colors = Theme.of(ctx).extension<AppThemeColors>()!;
        final primaryColor = ThemeService.primaryColor;

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.25),
                      blurRadius: 30,
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
                          LiveAnimatedIcon(
                            icon: Icons.lock_outline_rounded,
                            color: primaryColor,
                            size: 44,
                            iconSize: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRegisterMode ? "Create Account" : "Sign In Account",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primaryText,
                                  ),
                                ),
                                Text(
                                  "Enter password & valid email to sync data",
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
                      const SizedBox(height: 18),

                      // Sign In / Register Tab Selector
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setDialogState(() => isRegisterMode = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isRegisterMode ? primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "SIGN IN",
                                      style: TextStyle(
                                        color: !isRegisterMode ? Colors.white : colors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setDialogState(() => isRegisterMode = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isRegisterMode ? primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "REGISTER",
                                      style: TextStyle(
                                        color: isRegisterMode ? Colors.white : colors.secondaryText,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (isRegisterMode) ...[
                        // Avatar Row
                        Text(
                          "Choose Avatar Emblem",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAvatarOption("crown", Icons.workspace_premium_rounded, Colors.amber, selectedAvatar, (val) {
                              setDialogState(() => selectedAvatar = val);
                            }),
                            _buildAvatarOption("star", Icons.star_rounded, Colors.blue, selectedAvatar, (val) {
                              setDialogState(() => selectedAvatar = val);
                            }),
                            _buildAvatarOption("champion", Icons.emoji_events_rounded, Colors.purple, selectedAvatar, (val) {
                              setDialogState(() => selectedAvatar = val);
                            }),
                            _buildAvatarOption("diamond", Icons.diamond_rounded, Colors.cyan, selectedAvatar, (val) {
                              setDialogState(() => selectedAvatar = val);
                            }),
                            _buildAvatarOption("flame", Icons.local_fire_department_rounded, Colors.orange, selectedAvatar, (val) {
                              setDialogState(() => selectedAvatar = val);
                            }),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Name Field
                        TextField(
                          controller: nameController,
                          style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: "Full Name *",
                            hintText: "e.g. Habib",
                            prefixIcon: Icon(Icons.person_rounded, color: primaryColor),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Email Field
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: "Valid Email Address *",
                          hintText: "e.g. user@domain.com",
                          prefixIcon: Icon(Icons.alternate_email_rounded, color: primaryColor),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: "Password (Min 6 chars) *",
                          hintText: "••••••••",
                          prefixIcon: Icon(Icons.lock_rounded, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: colors.secondaryText,
                            ),
                            onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),

                      if (isRegisterMode) ...[
                        const SizedBox(height: 12),
                        // Confirm Password Field
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscurePassword,
                          style: TextStyle(color: colors.primaryText, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: "Confirm Password *",
                            hintText: "••••••••",
                            prefixIcon: Icon(Icons.lock_reset_rounded, color: primaryColor),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.pop(dialogCtx),
                              child: Text("Cancel", style: TextStyle(color: colors.primaryText)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () async {
                                final emailVal = emailController.text.trim();
                                final passVal = passwordController.text;

                                if (isRegisterMode) {
                                  final nameVal = nameController.text.trim();
                                  final confirmPass = confirmPasswordController.text;

                                  if (passVal != confirmPass) {
                                    ToastService.error(ctx, "Password Error ⚠️", "Passwords do not match.");
                                    return;
                                  }

                                  final errorStr = await AuthService.registerUser(
                                    name: nameVal,
                                    email: emailVal,
                                    password: passVal,
                                    bio: bioController.text,
                                    avatarIcon: selectedAvatar,
                                  );

                                  if (errorStr != null) {
                                    if (ctx.mounted) {
                                      ToastService.error(ctx, "Registration Error ⚠️", errorStr);
                                    }
                                    return;
                                  }

                                  if (mounted) {
                                    setState(() {
                                      userName = nameVal;
                                      userEmail = emailVal;
                                      userBio = bioController.text.isEmpty ? "Progress over perfection ✨" : bioController.text;
                                      userAvatar = selectedAvatar;
                                      isGuest = false;
                                      isLoggedIn = true;
                                    });
                                  }
                                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                                  if (mounted) {
                                    ToastService.success(context, "Registered Successfully! ✨", "Welcome to Countify Pro, $nameVal.");
                                  }
                                } else {
                                  final errorStr = await AuthService.loginWithPassword(
                                    email: emailVal,
                                    password: passVal,
                                  );

                                  if (errorStr != null) {
                                    if (ctx.mounted) {
                                      ToastService.error(ctx, "Sign In Error ⚠️", errorStr);
                                    }
                                    return;
                                  }

                                  await _loadProfileData();
                                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                                  if (mounted) {
                                    ToastService.success(context, "Signed In Successfully! ✨", "Welcome back!");
                                  }
                                }
                              },
                              child: Text(
                                isRegisterMode ? "Register" : "Sign In",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildAvatarOption(String key, IconData icon, Color color, String current, Function(String) onSelect) {
    final isSelected = key == current;
    return GestureDetector(
      onTap: () => onSelect(key),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
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
              icon: Icons.person_rounded,
              color: primaryColor,
              size: 32,
              iconSize: 17,
            ),
            const SizedBox(width: 8),
            Text(
              "User Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colors.primaryText,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: "Edit Profile",
            onPressed: _showEditProfileDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Moving Blur Mesh
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
                          color: primaryColor.withOpacity(isDark ? 0.12 : 0.15),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      children: [
                        // Guest Mode Warning Banner if in Guest Mode
                        if (isGuest) _buildGuestModeBanner(colors, isDark, primaryColor),

                        if (isGuest) const SizedBox(height: 16),

                        // User Profile Header Card
                        _buildUserProfileCard(colors, isDark, primaryColor),

                        const SizedBox(height: 20),

                        // Rank & Achievement Status Banner
                        _buildUserRankBanner(colors, isDark, primaryColor),

                        const SizedBox(height: 22),

                        // Lifetime Activity Grid
                        _buildActivityMetricsGrid(colors, isDark),

                        const SizedBox(height: 22),

                        // Account Quick Actions Card
                        _buildAccountActionsCard(colors, isDark, primaryColor),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestModeBanner(
      AppThemeColors colors, bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFFF59E0B), size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "GUEST MODE SESSION ⏱",
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Your counting data is temporary and will NOT be saved after app restart. Sign In with a valid email to keep your data permanently!",
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.login_rounded, color: Colors.black, size: 18),
              label: const Text(
                "SIGN IN TO SAVE DATA PERMANENTLY",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              onPressed: _showEditProfileDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(
      AppThemeColors colors, bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: primaryColor.withOpacity(0.35), width: 1.2),
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
          Row(
            children: [
              LiveAnimatedIcon(
                icon: avatarIconData,
                color: primaryColor,
                size: 68,
                iconSize: 34,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text("👑", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userBio,
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
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: primaryColor.withOpacity(0.5)),
                  ),
                  icon: Icon(Icons.edit_note_rounded, size: 18, color: primaryColor),
                  label: Text(
                    isGuest ? "Sign In / Register" : "Edit Profile",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _showEditProfileDialog,
                ),
              ),
              if (isLoggedIn) ...[
                const SizedBox(width: 10),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                  tooltip: "Log Out / Switch to Guest Mode",
                  onPressed: () async {
                    await AuthService.logout();
                    _loadProfileData();
                    if (mounted) {
                      ToastService.info(context, "Logged Out", "Switched to Guest Session.");
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankBanner(
      AppThemeColors colors, bool isDark, Color primaryColor) {
    final unlocked = widget.unlockedAchievements.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const LiveAnimatedIcon(
            icon: Icons.military_tech_rounded,
            color: Colors.amber,
            size: 46,
            iconSize: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CURRENT USER RANK",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: colors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userRankTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$unlocked Badges Unlocked",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMetricsGrid(AppThemeColors colors, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "Total Actions",
                value: "$totalActions",
                icon: Icons.touch_app_rounded,
                color: const Color(0xFF3B82F6),
                colors: colors,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: "Highest Record",
                value: "${widget.highestCount}",
                icon: Icons.emoji_events_rounded,
                color: const Color(0xFFF59E0B),
                colors: colors,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: "Active Streak",
                value: "${widget.currentStreak} Days",
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFF97316),
                colors: colors,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: "Best Streak",
                value: "${widget.bestStreak} Days",
                icon: Icons.stars_rounded,
                color: const Color(0xFF10B981),
                colors: colors,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    return Container(
      height: 82, // Uniform equal size for all 4 metric cards!
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          LiveAnimatedIcon(
            icon: icon,
            color: color,
            size: 38,
            iconSize: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
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

  Widget _buildAccountActionsCard(
      AppThemeColors colors, bool isDark, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            leading: LiveAnimatedIcon(
              icon: Icons.settings_rounded,
              color: primaryColor,
              size: 38,
              iconSize: 18,
            ),
            title: Text(
              "Settings & Preferences",
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "Theme, Audio & Goal Controls",
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const LiveAnimatedIcon(
              icon: Icons.emoji_events_rounded,
              color: Colors.amber,
              size: 38,
              iconSize: 18,
            ),
            title: Text(
              "All Achievements",
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "View unlocked badges & ranks",
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AchievementScreen(
                    unlockedAchievements: widget.unlockedAchievements,
                    currentCount: widget.currentCount,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const LiveAnimatedIcon(
              icon: Icons.bar_chart_rounded,
              color: Color(0xFF10B981),
              size: 38,
              iconSize: 18,
            ),
            title: Text(
              "Action Analytics",
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              "Peak time & category distribution",
              style: TextStyle(color: colors.secondaryText, fontSize: 11),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatisticsScreen(
                    currentCount: widget.currentCount,
                    highestCount: widget.highestCount,
                    increaseCount: 0,
                    decreaseCount: 0,
                    resetCount: 0,
                    currentStreak: widget.currentStreak,
                    bestStreak: widget.bestStreak,
                    dailyGoal: 100,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
