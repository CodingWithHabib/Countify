import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/theme_detection_service.dart';
import '../services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'workspace_screen.dart';

class CategoryHubScreen extends StatefulWidget {
  const CategoryHubScreen({super.key});

  @override
  State<CategoryHubScreen> createState() => _CategoryHubScreenState();
}

class _CategoryHubScreenState extends State<CategoryHubScreen> {
  List<String> _categories = [];
  Map<String, int> _categoryCounts = {};
  bool _isLoading = true;

  final List<String> _defaultCategories = [
    "Islamic",
    "Fitness",
    "Sports",
    "Education",
    "Programming",
    "Nature",
    "Productivity",
  ];

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadCategoryCounts();
    _initBannerAd();
  }

  void _initBannerAd() {
    _bannerAd = AdService.createBannerAd(
      onAdLoaded: () {
        if (mounted) setState(() => _isBannerAdLoaded = true);
      },
      onAdFailed: (err) {
        if (mounted) setState(() => _isBannerAdLoaded = false);
      },
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool initialized = prefs.getBool("categories_initialized") ?? false;
      List<String> savedCategories = await StorageService.loadUserCategories();

      bool needsSave = false;
      for (final def in _defaultCategories) {
        if (!savedCategories.contains(def)) {
          savedCategories.add(def);
          needsSave = true;
        }
      }

      if (needsSave || !initialized) {
        await StorageService.saveUserCategories(savedCategories);
        await prefs.setBool("categories_initialized", true);
      }

      final counts = await StorageService.getCategoryCounts();
      final Map<String, int> normalizedCounts = {};
      counts.forEach((key, value) {
        normalizedCounts[key.toLowerCase().trim()] = value;
      });

      if (!mounted) return;
      setState(() {
        _categories = savedCategories;
        _categoryCounts = normalizedCounts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCategoryBg(String name) {
    switch (name.toLowerCase().trim()) {
      case 'islamic':
        return 'assets/backgrounds/islamic_mosque_bg.png';
      case 'fitness':
        return 'assets/backgrounds/fitness_bg.png';
      case 'education':
        return 'assets/backgrounds/education_bg.png';
      case 'programming':
        return 'assets/backgrounds/programming_bg.png';
      case 'nature':
        return 'assets/backgrounds/nature_bg.png';
      case 'productivity':
        return 'assets/backgrounds/productivity_bg.png';
      default:
        return 'assets/backgrounds/default_bg.png';
    }
  }

  void _showCategoryOptions(String categoryName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Manage Category: $categoryName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Color(0xFF00A896)),
                  title: const Text("Edit Name", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCategoryDialog(categoryName);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  title: const Text("Delete", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteCategory(categoryName);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditCategoryDialog(String oldName) {
    final TextEditingController controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1117),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Category Name", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter new name",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00A896)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  await _renameCategory(oldName, newName);
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Color(0xFF00A896))),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameCategory(String oldName, String newName) async {
    setState(() {
      final index = _categories.indexOf(oldName);
      if (index != -1) {
        _categories[index] = newName;
      }
    });
    await StorageService.saveUserCategories(_categories);

    try {
      final counters = await StorageService.loadCounters();
      bool updatedAny = false;
      for (int i = 0; i < counters.length; i++) {
        if (counters[i].category.toLowerCase().trim() == oldName.toLowerCase().trim()) {
          counters[i] = counters[i].copyWith(category: newName);
          updatedAny = true;
        }
      }
      if (updatedAny) {
        await StorageService.saveCounters(counters);
      }
    } catch (_) {}

    await _loadCategoryCounts();
  }

  Future<void> _deleteCategory(String name) async {
    setState(() {
      _categories.remove(name);
    });
    await StorageService.saveUserCategories(_categories);
    await _loadCategoryCounts();
  }

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1117),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Category", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter category name",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00A896)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty && !_categories.contains(name)) {
                  setState(() {
                    _categories.add(name);
                  });
                  await StorageService.saveUserCategories(_categories);
                  await _loadCategoryCounts();
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Add", style: TextStyle(color: Color(0xFF00A896))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: Stack(
        children: [
          // Background - Window Frame style using high-fidelity asset
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/hub_bg.png',
              fit: BoxFit.fill,
            ),
          ),
          // Premium dimming gradient overlay - reduced alpha to make hub_bg.png the hero
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Glassmorphic Header Card with reduced blur and higher transparency
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Branding Section with Back Button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                    onPressed: () => Navigator.pop(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Countify",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Small Steps • Big Changes",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.5),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Stay Focused Achieve More",
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: Color(0xFFD4AF37), // Luxury gold color
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Hero Text Section / Welcome Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Welcome Back, ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.normal,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Choose a Category",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Each category has its own dedicated workspace...",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Google AdMob Sponsor Banner Card
                if (_isBannerAdLoaded && _bannerAd != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF00A896).withOpacity(0.35),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Premium Grid Cards
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A896)))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 18,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final categoryName = _categories[index];
                            final themeData = ThemeDetectionService.detect(categoryName);
                            final primaryColor = themeData.primaryColor;
                            final count = _categoryCounts[categoryName.toLowerCase().trim()] ?? 0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkspaceScreen(category: categoryName),
                                  ),
                                ).then((_) => _loadCategoryCounts());
                              },
                              onLongPress: () => _showCategoryOptions(categoryName),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2.5, // Thick neon glowing border
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.35),
                                      blurRadius: 14,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(21),
                                  child: Stack(
                                    children: [
                                      // Individual Background Image
                                      Positioned.fill(
                                        child: Image.asset(
                                          _getCategoryBg(categoryName),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // Dark elegant overlay for legibility
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.black.withOpacity(0.25),
                                                Colors.black.withOpacity(0.75),
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Inner Layout Content
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Icon in a small glowing circle
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: primaryColor.withOpacity(0.25),
                                                border: Border.all(
                                                  color: primaryColor.withOpacity(0.6),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: primaryColor.withOpacity(0.4),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                themeData.icon,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              categoryName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "$count counters",
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.65),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Arrow icon at the bottom right
                                      Positioned(
                                        bottom: 16,
                                        right: 16,
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white.withOpacity(0.6),
                                          size: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Functional "+ Manage Categories" button at the bottom center to add new category
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00A896).withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _showAddCategoryDialog,
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        label: const Text(
                          "Manage Categories",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.07),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.18),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}