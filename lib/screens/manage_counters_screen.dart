import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../widgets/counter_card.dart';
import '../models/counter_model.dart';
import '../widgets/new_counter_dialog.dart';
import '../services/storage_service.dart';
import '../services/toast_service.dart';
import '../screens/counter_screen.dart';
import '../screens/workspace_screen.dart';
import '../theme/app_theme_colors.dart';
import '../widgets/live_animated_icon.dart';
class ManageCountersScreen extends StatefulWidget {
  const ManageCountersScreen({super.key});

  @override
  State<ManageCountersScreen> createState() =>
      _ManageCountersScreenState();
}

enum ViewDensity { detailed, compact }
enum GoalStatusFilter { all, completed, pending }

class _ManageCountersScreenState
    extends State<ManageCountersScreen> {
  final TextEditingController searchController =
  TextEditingController();

  List<CounterModel> counters = [];

  bool isLoading = true;
  String globalNote = "";
  String _searchQuery = "";

  // Advanced Management Features
  bool isSelectionMode = false;
  Set<String> selectedIds = {};
  ViewDensity viewDensity = ViewDensity.detailed;
  GoalStatusFilter goalStatusFilter = GoalStatusFilter.all;
  String themeFilter = "All";

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ================================================================
  // LOAD DATA
  // ================================================================

  Future<void> _loadData() async {
    try {
      final loadedCounters = await StorageService.loadCounters();
      final note = await StorageService.loadGlobalNote();

      if (!mounted) return;

      setState(() {
        counters = List<CounterModel>.from(loadedCounters);
        globalNote = note;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to load data: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }
  // ================================================================
  // CREATE NEW COUNTER
  // ================================================================

  Future<void> _createCounter() async {
    final newCounter = await showDialog<CounterModel>(
      context: context,
      builder: (_) => const NewCounterDialog(),
    );

    if (!mounted || newCounter == null) return;

    setState(() {
      counters.add(newCounter);
    });

    ToastService.success(
      context,
      "Counter Created! 🎯",
      "Opening '${newCounter.name}' in '${newCounter.category}' workspace...",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkspaceScreen(category: newCounter.category),
      ),
    );
  }

  Future<void> _renameCounter(CounterModel counter) async {
    final controller = TextEditingController(
      text: counter.name,
    );

    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final colors = Theme.of(dialogContext).extension<AppThemeColors>()!;

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
                color: const Color(0xFF3B82F6).withOpacity(0.4),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LiveAnimatedIcon(
                      icon: Icons.edit_rounded,
                      color: Color(0xFF3B82F6),
                      size: 44,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Rename Counter",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.grey.shade100,
                    labelText: "Counter Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    final name = value.trim();
                    if (name.isNotEmpty) {
                      Navigator.of(dialogContext).pop(name);
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
                        onPressed: () => Navigator.of(dialogContext).pop(),
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
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          final name = controller.text.trim();
                          if (name.isNotEmpty) {
                            Navigator.of(dialogContext).pop(name);
                          }
                        },
                        child: const Text(
                          "Rename",
                          style: TextStyle(
                            color: Colors.white,
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

    // Dialog route ko completely remove hone do.
    await Future.delayed(
      const Duration(milliseconds: 100),
    );

    controller.dispose();

    if (!mounted) return;

    if (newName == null || newName.isEmpty) {
      return;
    }

    final index = counters.indexWhere(
          (item) => item.id == counter.id,
    );

    if (index == -1) return;

    final updatedCounter = counter.copyWith(
      name: newName,
    );

    setState(() {
      counters[index] = updatedCounter;
    });

    await StorageService.saveCounters(counters);
  }

  Future<void> _duplicateCounter(CounterModel counter) async {
    final duplicate = counter.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "${counter.name} Copy",
      isActive: false,
    );

    setState(() {
      counters.add(duplicate);
    });

    await StorageService.saveCounters(counters);
  }
  Future<void> _deleteCounter(CounterModel counter) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final colors = Theme.of(dialogContext).extension<AppThemeColors>()!;

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
                color: Colors.red.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LiveAnimatedIcon(
                      icon: Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 44,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Delete Counter",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Are you sure you want to delete "${counter.name}"? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.5,
                  ),
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
                        onPressed: () => Navigator.pop(dialogContext, false),
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
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.white,
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

    if (!mounted || shouldDelete != true) {
      return;
    }

    setState(() {
      counters.removeWhere(
            (item) => item.id == counter.id,
      );
    });

    await StorageService.saveCounters(counters);
  }

  // ================================================================
  // GLOBAL OPTIONS & ADMINISTRATIVE
  // ================================================================

  void _showGlobalOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D1016),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 45, height: 4.5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGlobalOptionTile(
                        icon: Icons.sort_rounded,
                        color: Colors.blue,
                        title: "Sort Counters",
                        onTap: () {
                          Navigator.pop(context);
                          _showSortDialog();
                        },
                      ),
                      _buildGlobalOptionTile(
                        icon: Icons.restart_alt_rounded,
                        color: Colors.orange,
                        title: "Reset All Counters",
                        onTap: () {
                          Navigator.pop(context);
                          _showResetAllConfirmation();
                        },
                      ),
                      _buildGlobalOptionTile(
                        icon: Icons.file_download_outlined,
                        color: Colors.green,
                        title: "Export All Data",
                        onTap: () {
                          Navigator.pop(context);
                          _exportAllData();
                        },
                      ),
                      _buildGlobalOptionTile(
                        icon: Icons.cloud_sync_rounded,
                        color: Colors.cyan,
                        title: "Backup & Restore",
                        onTap: () {
                          Navigator.pop(context);
                          _showBackupRestoreDialog();
                        },
                      ),
                      _buildGlobalOptionTile(
                        icon: Icons.history_rounded,
                        color: Colors.amber,
                        title: "Clear All History",
                        onTap: () {
                          Navigator.pop(context);
                          _showClearHistoryConfirmation();
                        },
                      ),
                      _buildGlobalOptionTile(
                        icon: Icons.delete_forever_rounded,
                        color: Colors.redAccent,
                        title: "Delete All Counters",
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteAllConfirmation();
                        },
                      ),
                      _buildGlobalOptionTile(
                        icon: Icons.note_add_rounded,
                        color: Colors.teal,
                        title: "Add Note to Today",
                        onTap: () {
                          Navigator.pop(context);
                          _showGlobalNoteDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalOptionTile({required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Sort Counters", style: TextStyle(color: Colors.white)),
        children: [
          _buildSortOption("Recently Used", () {
            setState(() => counters.sort((a, b) {
              if (a.lastUsed == null && b.lastUsed == null) return 0;
              if (a.lastUsed == null) return 1;
              if (b.lastUsed == null) return -1;
              return b.lastUsed!.compareTo(a.lastUsed!);
            }));
          }),
          _buildSortOption("Name (A-Z)", () {
            setState(() => counters.sort((a, b) => a.name.compareTo(b.name)));
          }),
          _buildSortOption("Category", () {
            setState(() => counters.sort((a, b) => a.category.compareTo(b.category)));
          }),
          _buildSortOption("Count (Highest First)", () {
            setState(() => counters.sort((a, b) => b.count.compareTo(a.count)));
          }),
          _buildSortOption("Date Created", () {
            setState(() => counters.sort((a, b) => a.id.compareTo(b.id)));
          }),
        ],
      ),
    );
  }

  Widget _buildSortOption(String title, VoidCallback onSort) {
    return SimpleDialogOption(
      onPressed: () {
        onSort();
        StorageService.saveCounters(counters);
        Navigator.pop(context);
      },
      child: Text(title, style: const TextStyle(color: Colors.white70)),
    );
  }

  void _showResetAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Reset All Counters?", style: TextStyle(color: Colors.white)),
        content: const Text("This will set counts to 0 for all counters. This cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await StorageService.resetAllCounters();
              await _loadData();
              if (!mounted) return;
              navigator.pop();
            },
            child: const Text("Reset All", style: TextStyle(color: Colors.orangeAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAllData() async {
    final data = await StorageService.exportAllData();
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/countify_all_data_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(data);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All data exported to ${file.path}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to export data")),
      );
    }
  }


  void _showBackupRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Backup & Restore", style: TextStyle(color: Colors.white)),
        content: const Text("Cloud backup and JSON import/export features coming soon.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _showClearHistoryConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("Clear All History?", style: TextStyle(color: Colors.white)),
        content: const Text("This will delete all activity logs for all counters. Statistics will remain.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await StorageService.clearAllHistory();
              if (!mounted) return;
              navigator.pop();
            },
            child: const Text("Clear", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("DANGER: Delete Everything?", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text("This will permanently remove ALL counters and their data. This action is irreversible.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              setState(() => counters = []);
              await StorageService.saveCounters([]);
              if (!mounted) return;
              navigator.pop();
            },
            child: const Text("DELETE ALL", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showGlobalNoteDialog() async {
    final currentNote = await StorageService.loadGlobalNote();
    final controller = TextEditingController(text: currentNote);
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F26),
        title: const Text("General Note for Today", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter a general note...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await StorageService.saveGlobalNote(controller.text);
              await _loadData(); // Reload to show the note
              if (!mounted) return;
              navigator.pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  List<CounterModel> get filteredCounters {
    return counters.where((counter) {
      // 1. Search Query
      final nameMatch = counter.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryMatch = counter.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final searchMatch = _searchQuery.isEmpty || nameMatch || categoryMatch;

      // 2. Goal Status
      bool goalMatch = true;
      if (goalStatusFilter == GoalStatusFilter.completed) {
        goalMatch = counter.count >= counter.dailyGoal;
      } else if (goalStatusFilter == GoalStatusFilter.pending) {
        goalMatch = counter.count < counter.dailyGoal;
      }

      // 3. Theme Filter
      bool themeMatch = true;
      if (themeFilter != "All") {
        themeMatch = counter.themeStyle.name.toLowerCase() == themeFilter.toLowerCase() ||
            counter.category.toLowerCase() == themeFilter.toLowerCase();
      }

      return searchMatch && goalMatch && themeMatch;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1016),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Advanced Filters", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              const Text("View Density", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("Detailed"),
                    selected: viewDensity == ViewDensity.detailed,
                    onSelected: (val) {
                      setSheetState(() => viewDensity = ViewDensity.detailed);
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Compact"),
                    selected: viewDensity == ViewDensity.compact,
                    onSelected: (val) {
                      setSheetState(() => viewDensity = ViewDensity.compact);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),

              const Text("Goal Status", style: TextStyle(color: Colors.white70, fontSize: 14)),
              DropdownButton<GoalStatusFilter>(
                value: goalStatusFilter,
                dropdownColor: const Color(0xFF1A1F26),
                isExpanded: true,
                items: GoalStatusFilter.values.map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setSheetState(() => goalStatusFilter = val);
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 15),

              const Text("Theme / Category", style: TextStyle(color: Colors.white70, fontSize: 14)),
              DropdownButton<String>(
                value: themeFilter,
                dropdownColor: const Color(0xFF1A1F26),
                isExpanded: true,
                items: ["All", "Islamic", "Fitness", "Nature", "Productivity"].map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t, style: const TextStyle(color: Colors.white)),
                )).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setSheetState(() => themeFilter = val);
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
        if (selectedIds.isEmpty) isSelectionMode = false;
      } else {
        selectedIds.add(id);
      }
    });
  }

  Future<void> _bulkDelete() async {
    final count = selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete $count Counters?"),
        content: const Text("This will permanently remove selected counters."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        counters.removeWhere((c) => selectedIds.contains(c.id));
        isSelectionMode = false;
        selectedIds.clear();
      });
      await StorageService.saveCounters(counters);
    }
  }

  Future<void> _bulkReset() async {
    final count = selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Reset $count Counters?"),
        content: const Text("This will set counts to 0 for selected counters."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Reset")),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        for (var i = 0; i < counters.length; i++) {
          if (selectedIds.contains(counters[i].id)) {
            counters[i] = counters[i].copyWith(count: 0, todayCount: 0);
          }
        }
        isSelectionMode = false;
        selectedIds.clear();
      });
      await StorageService.saveCounters(counters);
    }
  }

  Widget _buildCompactCard(CounterModel counter) {
    final isSelected = selectedIds.contains(counter.id);
    return ListTile(
      onLongPress: () {
        setState(() {
          isSelectionMode = true;
          selectedIds.add(counter.id);
        });
      },
      onTap: isSelectionMode ? () => _toggleSelection(counter.id) : null,
      leading: isSelectionMode 
          ? Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: Colors.blue)
          : CircleAvatar(child: Text(counter.name[0])),
      title: Text(counter.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(counter.category, style: TextStyle(color: Colors.white.withOpacity(0.5))),
      trailing: Text("${counter.count}", style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.w900)),
      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode ? "${selectedIds.length} Selected" : "Manage Counters"),
        centerTitle: true,
        leading: isSelectionMode 
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  isSelectionMode = false;
                  selectedIds.clear();
                }),
              )
            : null,
        actions: [
          if (!isSelectionMode)
            IconButton(
              onPressed: _showGlobalOptions,
              icon: const Icon(Icons.more_vert_rounded),
            ),
        ],
      ),

      bottomNavigationBar: isSelectionMode ? SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F26),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _bulkReset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text("Bulk Reset"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.orangeAccent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _bulkDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Bulk Delete"),
                  style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ) : null,

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (globalNote.isNotEmpty) _buildGlobalNoteBanner(),
            const SizedBox(height: 8),

            // ======================================================
            // SEARCH
            // ======================================================

            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: "Search counters...",
                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                  : IconButton(
                      onPressed: _showFilterSheet,
                      icon: const Icon(
                        Icons.tune_rounded,
                      ),
                    ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // NEW COUNTER BUTTON
            // ======================================================

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _createCounter,
                icon: const Icon(
                  Icons.add_rounded,
                ),
                label: const Text(
                  "New Counter",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ======================================================
            // TITLE
            // ======================================================

            const Text(
              "Pinned Counters",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // ======================================================
            // COUNTERS
            // ======================================================

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (counters.isEmpty)
              _buildEmptyState()
            else if (filteredCounters.isEmpty)
              _buildNoResultsState()
            else
              ...filteredCounters.map(
                    (counter) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                      child: viewDensity == ViewDensity.compact 
                        ? _buildCompactCard(counter)
                        : CounterCard(
                        counterName: counter.name,
                        category: counter.category,
                        currentCount: counter.count,
                        highestCount: counter.highestCount,
                        todayCount: counter.todayCount,
                        isActive: counter.isActive,
                        themeStyle: counter.themeStyle,
                        isSelectionMode: isSelectionMode,
                        isSelected: selectedIds.contains(counter.id),
                        onLongPress: () {
                          if (!isSelectionMode) {
                            setState(() {
                              isSelectionMode = true;
                              selectedIds.add(counter.id);
                            });
                          } else {
                            _toggleSelection(counter.id);
                          }
                        },
                        onOpen: () async {
                          if (isSelectionMode) {
                            _toggleSelection(counter.id);
                            return;
                          }
                          debugPrint("OPEN COUNTER: ${counter.name} | THEME: ${counter.themeStyle}");

                          // Set Active logic
                          await StorageService.markCounterAsActive(counter.id);

                          if (!context.mounted) return;
                          final navigator = Navigator.of(context);

                          await navigator.push(
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
                          );
                          
                          // Hamesha data reload karein taake UI sync rahe
                          if (!mounted) return;
                          _loadData();
                        },
                        onWorkspace: () async {
                          if (isSelectionMode) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkspaceScreen(category: counter.category),
                            ),
                          );
                          if (!mounted) return;
                          _loadData();
                        },

                        // Rename
                        onRename: () {
                          _renameCounter(counter);
                        },
                        // Duplicate
                        onDuplicate: () {
                          _duplicateCounter(counter);
                        },

                        // Delete
                        onDelete: () {
                          _deleteCounter(counter);
                        },
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 50,
            color: Colors.white.withOpacity(.45),
          ),

          const SizedBox(height: 14),

          const Text(
            "No counters yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Create your first personalized counter.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.55),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 50, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 14),
          Text(
            "No matching counters",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Try a different search term",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalNoteBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.withOpacity(0.2), Colors.teal.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_rounded, color: Colors.tealAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S NOTE",
                  style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  globalNote,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white38, size: 18),
            onPressed: () async {
              await StorageService.saveGlobalNote("");
              setState(() => globalNote = "");
            },
          ),
        ],
      ),
    );
  }
}