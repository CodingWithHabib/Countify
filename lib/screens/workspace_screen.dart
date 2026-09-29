import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/counter_model.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';
import '../services/theme_detection_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../widgets/workspace_counter_card.dart';
import '../widgets/new_counter_dialog.dart';
import 'counter_screen.dart';
import 'package:intl/intl.dart';

class WorkspaceScreen extends StatefulWidget {
  final String category;

  const WorkspaceScreen({
    super.key,
    required this.category,
  });

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  List<CounterModel> _counters = [];
  List<HistoryEntry> _history = [];
  bool _isLoading = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final sound = await StorageService.loadSound();
      final vibration = await StorageService.loadVibration();
      final loadedCounters = await StorageService.getCountersByCategory(widget.category);
      final allHistory = await StorageService.loadHistoryEntries();
      
      // Filter history for this workspace
      final counterIds = loadedCounters.map((c) => c.id).toSet();
      final filteredHistory = allHistory.where((e) => counterIds.contains(e.counterId)).toList();
      filteredHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      if (!mounted) return;
      setState(() {
        _soundEnabled = sound;
        _vibrationEnabled = vibration;
        _counters = loadedCounters;
        _history = filteredHistory;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCounters() async {
    final loadedCounters = await StorageService.getCountersByCategory(widget.category);
    final allHistory = await StorageService.loadHistoryEntries();
    final counterIds = loadedCounters.map((c) => c.id).toSet();
    final filteredHistory = allHistory.where((e) => counterIds.contains(e.counterId)).toList();
    filteredHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (!mounted) return;
    setState(() {
      _counters = loadedCounters;
      _history = filteredHistory;
    });
  }

  String? _getBackgroundImage(CounterThemeStyle style) {
    switch (style) {
      case CounterThemeStyle.islamic:
        return 'assets/backgrounds/islamic_mosque_bg.png';
      case CounterThemeStyle.fitness:
      case CounterThemeStyle.health:
        return 'assets/backgrounds/fitness_bg.png';
      case CounterThemeStyle.education:
        return 'assets/backgrounds/education_bg.png';
      case CounterThemeStyle.programming:
      case CounterThemeStyle.creative:
        return 'assets/backgrounds/programming_bg.png';
      case CounterThemeStyle.nature:
        return 'assets/backgrounds/nature_bg.png';
      case CounterThemeStyle.productivity:
      case CounterThemeStyle.finance:
        return 'assets/backgrounds/productivity_bg.png';
      case CounterThemeStyle.sports:
        return 'assets/backgrounds/sports_bg.png';
      case CounterThemeStyle.defaultTheme:
        return 'assets/backgrounds/default_bg.png';
    }
  }

  Widget _buildDynamicBackground(ThemeDataModel theme) {
    final bgImg = _getBackgroundImage(theme.style);
    
    return Stack(
      children: [
        // Base Layer: Deep Theme Background
        Positioned.fill(
          child: Container(
            color: theme.backgroundColor.withOpacity(0.1),
          ),
        ),
        
        // Aurora Engine: Procedural Luxury Orbs
        Positioned(
          top: -100,
          right: -50,
          child: _buildAuroraOrb(theme.primaryColor, 300),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: _buildAuroraOrb(theme.accentColor, 400),
        ),
        Positioned(
          top: 200,
          left: -50,
          child: _buildAuroraOrb(theme.secondaryColor, 250),
        ),

        // Glassmorphism Blur Layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Optional Image Asset Layer with Blend (Restored)
        if (bgImg != null)
          Positioned.fill(
            child: Opacity(
              opacity: 1.0,
              child: Image.asset(
                bgImg,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        
        // Subtle Vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuroraOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Future<void> _incrementCounter(CounterModel counter) async {
    int newCount = counter.count + counter.stepSize;
    int newHighest = counter.highestCount;
    if (newCount > newHighest) newHighest = newCount;
    int newToday = counter.todayCount + counter.stepSize;
    
    await StorageService.updateCounterData(
      counterId: counter.id,
      count: newCount,
      highestCount: newHighest,
      todayCount: newToday,
      targetAlertCount: counter.targetAlertCount,
      isVoiceEnabled: counter.isVoiceEnabled,
      stepSize: counter.stepSize,
    );

    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      counterId: counter.id,
      counterName: counter.name,
      action: HistoryAction.increase,
      count: newCount,
      timestamp: DateTime.now(),
    );
    final history = await StorageService.loadHistoryEntries();
    history.insert(0, entry);
    await StorageService.saveHistoryEntries(history);

    if (_soundEnabled) {
      SoundService.playThemeSound(counter.themeStyle);
    }
    if (_vibrationEnabled) {
      VibrationService.vibrate();
    }
    HapticFeedback.lightImpact();

    await _loadCounters();
  }

  Future<void> _decrementCounter(CounterModel counter) async {
    if (counter.count <= 0) return;
    
    int newCount = (counter.count - counter.stepSize).clamp(0, 999999);
    
    await StorageService.updateCounterData(
      counterId: counter.id,
      count: newCount,
      highestCount: counter.highestCount,
      todayCount: counter.todayCount,
      targetAlertCount: counter.targetAlertCount,
      isVoiceEnabled: counter.isVoiceEnabled,
      stepSize: counter.stepSize,
    );

    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      counterId: counter.id,
      counterName: counter.name,
      action: HistoryAction.decrease,
      count: newCount,
      timestamp: DateTime.now(),
    );
    final history = await StorageService.loadHistoryEntries();
    history.insert(0, entry);
    await StorageService.saveHistoryEntries(history);

    if (_soundEnabled) {
      SoundService.playThemeSound(counter.themeStyle);
    }
    if (_vibrationEnabled) {
      VibrationService.vibrate();
    }
    HapticFeedback.lightImpact();

    await _loadCounters();
  }

  void _navigateToCounter(CounterModel counter) {
    StorageService.markCounterAsActive(counter.id).then((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CounterScreen(
            counterId: counter.id,
            counterName: counter.name,
            category: counter.category,
            currentCount: counter.count,
            highestCount: counter.highestCount,
            todayCount: counter.todayCount,
            dailyGoal: counter.dailyGoal,
            soundEnabled: counter.soundEnabled,
            vibrationEnabled: counter.vibrationEnabled,
            lastUpdatedDate: counter.lastUpdatedDate,
            targetAlertCount: counter.targetAlertCount,
            isVoiceEnabled: counter.isVoiceEnabled,
            stepSize: counter.stepSize,
            themeStyle: counter.themeStyle,
          ),
        ),
      ).then((_) => _loadCounters());
    });
  }

  Future<void> _createNewCounter() async {
    final newCounter = await showDialog<CounterModel>(
      context: context,
      builder: (_) => NewCounterDialog(initialCategory: widget.category),
    );
    
    if (!mounted) return;
    if (newCounter != null) {
      await _loadCounters();
    }
  }

  void _showWorkspaceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D25).withOpacity(0.7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Workspace Options",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionItem(
                icon: Icons.refresh_rounded,
                title: "Reset All Counters",
                subtitle: "Set all counts in this workspace to zero",
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.pop(context);
                  _confirmReset();
                },
              ),
              _buildOptionItem(
                icon: Icons.history_rounded,
                title: "Clear Category History",
                subtitle: "Delete all activity logs for this workspace",
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  _confirmClearHistory();
                },
              ),
              _buildOptionItem(
                icon: Icons.settings_rounded,
                title: "Workspace Settings",
                subtitle: "Customize notifications and preferences",
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentTab = 3;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D25),
        title: const Text("Reset Counters?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This will set all counters in this workspace to 0. This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.resetCountersByCategory(widget.category);
              await _loadCounters();
            },
            child: const Text("Reset All", style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D25),
        title: const Text("Clear History?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This will delete all activity history for this workspace. This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ids = _counters.map((c) => c.id).toList();
              await StorageService.clearHistoryByCategory(ids);
              await _loadCounters();
            },
            child: const Text("Clear All", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildHistoryTab();
      case 2:
        return _buildAnalyticsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildOverviewTab();
    }
  }

  void _showDeleteCounterDialog(CounterModel counter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D25),
        title: const Text("Delete Counter?", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete \"${counter.name}\"? This action cannot be undone.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.deleteCounter(counter.id);
              await _loadCounters();
              HapticFeedback.vibrate();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_counters.isEmpty) {
      return Center(
        child: Text(
          "No counters in this workspace yet.",
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: _counters.length,
      itemBuilder: (context, index) {
        final counter = _counters[index];
        return ScaleButton(
          onTap: () => _navigateToCounter(counter),
          child: WorkspaceCounterCard(
            counter: counter,
            onIncrement: () => _incrementCounter(counter),
            onDecrement: () => _decrementCounter(counter),
            onTap: () => _navigateToCounter(counter),
            onLongPress: () => _showDeleteCounterDialog(counter),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              "No history entries found.",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final entry = _history[index];
        final isIncrease = entry.action == HistoryAction.increase;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildGlassCard(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isIncrease ? Colors.greenAccent : Colors.redAccent).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isIncrease ? Colors.greenAccent : Colors.redAccent,
                  size: 20,
                ),
              ),
              title: Text(
                entry.counterName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM d, h:mm a').format(entry.timestamp),
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncrease ? '+' : ''}${entry.count}",
                    style: TextStyle(
                      color: isIncrease ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    entry.action.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    int totalCount = _counters.fold(0, (sum, item) => sum + item.count);
    CounterModel? topPerformer;
    if (_counters.isNotEmpty) {
      topPerformer = _counters.reduce((a, b) => a.count > b.count ? a : b);
    }

    final weeklyData = _getWeeklyActivityData();
    final weeklyLabels = _getWeeklyDayLabels();
    final int maxActivity = weeklyData.reduce((a, b) => a > b ? a : b);
    final double chartMaxHeight = 80.0;
    final primaryColor = ThemeDetectionService.detect(widget.category).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlassCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "Category Total",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    totalCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Across ${_counters.length} counters",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              "WEEKLY WORKSPACE ACTIVITY",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ),
          _buildGlassCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final day = weeklyLabels[index];
                      final activity = weeklyData[index];
                      final bool isToday = index == 6;

                      double barHeight = 0;
                      if (maxActivity > 0) {
                        barHeight = (activity / maxActivity) * chartMaxHeight;
                      }
                      if (activity > 0 && barHeight < 5) barHeight = 5;

                      return Column(
                        children: [
                          Container(
                            height: chartMaxHeight,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutBack,
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        isToday ? primaryColor : primaryColor.withOpacity(0.6),
                                        isToday ? primaryColor.withOpacity(0.7) : primaryColor.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: activity > 0 ? [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.2),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ] : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            day,
                            style: TextStyle(
                              color: isToday ? Colors.white : Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (topPerformer != null)
            _buildGlassCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Top Performer",
                            style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            topPerformer.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total Count: ${topPerformer.count}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.orangeAccent, size: 32),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          _buildGlassCard(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Activity",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityStat("Last Hour", _getActivityCount(Duration(hours: 1))),
                  const Divider(color: Colors.white10),
                  _buildActivityStat("Today", _getActivityCount(Duration(days: 1))),
                  const Divider(color: Colors.white10),
                  _buildActivityStat("This Week", _getActivityCount(Duration(days: 7))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getWeeklyActivityData() {
    final now = DateTime.now();
    final data = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayEntries = _history.where((e) =>
          e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day);

      int activity = 0;
      for (var entry in dayEntries) {
        if (entry.action == HistoryAction.increase || entry.action == HistoryAction.decrease) {
          activity++;
        }
      }
      data[6 - i] = activity;
    }
    return data;
  }

  List<String> _getWeeklyDayLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DateFormat('E').format(date);
    });
  }

  int _getActivityCount(Duration duration) {
    final now = DateTime.now();
    return _history.where((e) => now.difference(e.timestamp) < duration).length;
  }

  Widget _buildActivityStat(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          Text(
            count.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "WORKSPACE INFO",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildGlassCard(
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.category_outlined,
                  title: "Category",
                  value: widget.category,
                  color: Colors.blueAccent,
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildSettingItem(
                  icon: Icons.numbers_rounded,
                  title: "Total Counters",
                  value: _counters.length.toString(),
                  color: Colors.purpleAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "PREFERENCES",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildGlassCard(
            child: Column(
              children: [
                _buildToggleItem(
                  icon: Icons.volume_up_rounded,
                  title: "Sound Effects",
                  value: _soundEnabled,
                  onChanged: (val) async {
                    await StorageService.saveSound(val);
                    setState(() => _soundEnabled = val);
                  },
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildToggleItem(
                  icon: Icons.vibration_rounded,
                  title: "Haptic Feedback",
                  value: _vibrationEnabled,
                  onChanged: (val) async {
                    await StorageService.saveVibration(val);
                    setState(() => _vibrationEnabled = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: ThemeDetectionService.detect(widget.category).primaryColor,
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ShimmerGlassCard(child: child);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ThemeDetectionService.detect(widget.category);
    final primaryColor = themeData.primaryColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildDynamicBackground(themeData),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: _showWorkspaceOptions,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(themeData.icon, color: Colors.white, size: 36),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${themeData.themeName} Workspace",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              themeData.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _buildTabContent(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: _createNewCounter,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0F14).withOpacity(0.98),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(0, Icons.grid_view_rounded, "Overview", primaryColor),
                _buildBottomNavItem(1, Icons.history_rounded, "History", primaryColor),
                _buildBottomNavItem(2, Icons.analytics_outlined, "Analytics", primaryColor),
                _buildBottomNavItem(3, Icons.settings_suggest_outlined, "Settings", primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label, Color activeColor) {
    final isSelected = _currentTab == index;
    return ScaleButton(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentTab = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : Colors.white.withOpacity(0.4),
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerGlassCard extends StatefulWidget {
  final Widget child;
  const ShimmerGlassCard({super.key, required this.child});

  @override
  State<ShimmerGlassCard> createState() => _ShimmerGlassCardState();
}

class _ShimmerGlassCardState extends State<ShimmerGlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.8,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _shimmerController.value - 0.2,
                _shimmerController.value,
                _shimmerController.value + 0.2,
              ],
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                color: Colors.white.withOpacity(0.04),
                child: widget.child,
              ),
            ),
          ),
        );
      },
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