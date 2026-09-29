import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/history_entry.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import '../services/toast_service.dart';
import '../theme/app_theme_colors.dart';

class HistoryScreen extends StatefulWidget {
  final List<HistoryEntry> history;

  const HistoryScreen({super.key, required this.history});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late List<HistoryEntry> _history;
  bool _isLoading = true;
  bool _isDeletingAll = false;
  bool _isSearchMode = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = "";
  HistoryAction? _selectedActionFilter;
  String _selectedTimeFilter = "All Time"; // "All Time", "Today", "Yesterday", "7 Days", "30 Days"
  String? _selectedCounter;

  late AnimationController _pulseController;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _history = List.from(widget.history);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _loadFreshHistory();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFreshHistory() async {
    try {
      final loaded = await StorageService.loadHistoryEntries();
      if (mounted) {
        setState(() {
          _history = loaded.isNotEmpty ? loaded : List.from(widget.history);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int get totalEvents => _history.length;

  int get todayEvents {
    final now = DateTime.now();
    return _history.where((e) {
      return e.timestamp.year == now.year &&
          e.timestamp.month == now.month &&
          e.timestamp.day == now.day;
    }).length;
  }

  int get weekEvents {
    final now = DateTime.now();
    return _history.where((e) {
      return now.difference(e.timestamp).inDays < 7;
    }).length;
  }

  List<String> get counters {
    return _history
        .map((e) => e.counterName)
        .toSet()
        .toList()
      ..sort();
  }

  List<HistoryEntry> get _filteredHistory {
    final now = DateTime.now();
    return _history.where((entry) {
      // Filter by Action
      if (_selectedActionFilter != null && entry.action != _selectedActionFilter) {
        return false;
      }
      // Filter by Counter
      if (_selectedCounter != null && entry.counterName != _selectedCounter) {
        return false;
      }
      // Filter by Time Period
      if (_selectedTimeFilter == "Today") {
        final isToday = entry.timestamp.year == now.year &&
            entry.timestamp.month == now.month &&
            entry.timestamp.day == now.day;
        if (!isToday) return false;
      } else if (_selectedTimeFilter == "Yesterday") {
        final yesterday = now.subtract(const Duration(days: 1));
        final isYesterday = entry.timestamp.year == yesterday.year &&
            entry.timestamp.month == yesterday.month &&
            entry.timestamp.day == yesterday.day;
        if (!isYesterday) return false;
      } else if (_selectedTimeFilter == "7 Days") {
        if (now.difference(entry.timestamp).inDays >= 7) return false;
      } else if (_selectedTimeFilter == "30 Days") {
        if (now.difference(entry.timestamp).inDays >= 30) return false;
      }

      // Filter by Search Query
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final actionName = entry.action.name.toLowerCase();
      final actionText = switch (entry.action) {
        HistoryAction.increase => "increase increment add plus count",
        HistoryAction.decrease => "decrease decrement minus remove",
        HistoryAction.reset => "reset restart clear",
      };
      final counter = entry.counterName.toLowerCase();
      final count = entry.count.toString();
      final note = (entry.note ?? "").toLowerCase();
      final dateStr = DateFormat("MMM dd, yyyy hh:mm a").format(entry.timestamp).toLowerCase();

      return actionName.contains(query) ||
          actionText.contains(query) ||
          counter.contains(query) ||
          count.contains(query) ||
          note.contains(query) ||
          dateStr.contains(query);
    }).toList();
  }

  Map<String, List<HistoryEntry>> _groupEntriesByDate(List<HistoryEntry> entries) {
    final Map<String, List<HistoryEntry>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var entry in entries) {
      final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      String key;
      if (entryDate.isAtSameMomentAs(today)) {
        key = "Today";
      } else if (entryDate.isAtSameMomentAs(yesterday)) {
        key = "Yesterday";
      } else if (today.difference(entryDate).inDays < 7) {
        key = DateFormat("EEEE, MMM dd").format(entry.timestamp);
      } else {
        key = DateFormat("MMMM dd, yyyy").format(entry.timestamp);
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(entry);
    }
    return grouped;
  }

  Color _getActionColor(HistoryAction action) {
    switch (action) {
      case HistoryAction.increase:
        return const Color(0xFF10B981); // Emerald Green
      case HistoryAction.decrease:
        return const Color(0xFFEF4444); // Ruby Red
      case HistoryAction.reset:
        return const Color(0xFFF59E0B); // Amber Gold
    }
  }

  IconData _getActionIcon(HistoryAction action) {
    switch (action) {
      case HistoryAction.increase:
        return Icons.add_rounded;
      case HistoryAction.decrease:
        return Icons.remove_rounded;
      case HistoryAction.reset:
        return Icons.restart_alt_rounded;
    }
  }

  String _getActionTitle(HistoryAction action) {
    switch (action) {
      case HistoryAction.increase:
        return "Count Increased";
      case HistoryAction.decrease:
        return "Count Decreased";
      case HistoryAction.reset:
        return "Counter Reset";
    }
  }

  Future<void> _deleteEntry(HistoryEntry entry) async {
    final deletedEntry = entry;
    final deletedIndex = _history.indexWhere((e) => e.id == entry.id);

    setState(() {
      _history.removeWhere((e) => e.id == entry.id);
    });
    await StorageService.saveHistoryEntries(_history);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Deleted record for ${entry.counterName}",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "UNDO",
          textColor: const Color(0xFF60A5FA),
          onPressed: () async {
            setState(() {
              if (deletedIndex >= 0 && deletedIndex <= _history.length) {
                _history.insert(deletedIndex, deletedEntry);
              } else {
                _history.add(deletedEntry);
              }
            });
            await StorageService.saveHistoryEntries(_history);
            if (mounted) {
              ToastService.success(context, "Restored", "History entry restored.");
            }
          },
        ),
      ),
    );
  }

  Future<void> _editNote(HistoryEntry entry) async {
    final controller = TextEditingController(text: entry.note ?? "");
    final updatedNote = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).extension<AppThemeColors>()!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.secondaryText.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sticky_note_2_rounded, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.note == null || entry.note!.isEmpty ? "Add Entry Note" : "Edit Note",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                          ),
                        ),
                        Text(
                          "${entry.counterName} • ${_getActionTitle(entry.action)}",
                          style: TextStyle(fontSize: 12, color: colors.secondaryText),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  autofocus: true,
                  style: TextStyle(color: colors.primaryText),
                  decoration: InputDecoration(
                    hintText: "Write your note here...",
                    hintStyle: TextStyle(color: colors.secondaryText.withOpacity(0.6)),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (entry.note != null && entry.note!.isNotEmpty)
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text("Delete Note"),
                        onPressed: () {
                          Navigator.pop(context, "");
                        },
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context, controller.text.trim());
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (updatedNote != null) {
      final index = _history.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        final newEntry = HistoryEntry(
          id: entry.id,
          counterId: entry.counterId,
          counterName: entry.counterName,
          action: entry.action,
          count: entry.count,
          timestamp: entry.timestamp,
          note: updatedNote.isEmpty ? null : updatedNote,
        );
        setState(() {
          _history[index] = newEntry;
        });
        await StorageService.saveHistoryEntries(_history);
        if (mounted) {
          ToastService.success(
            context,
            "Note Saved",
            updatedNote.isEmpty ? "Note removed." : "Note updated successfully.",
          );
        }
      }
    }
  }

  void _showEntryOptions(HistoryEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).extension<AppThemeColors>()!;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final timeStr = DateFormat("MMM dd, yyyy • hh:mm a").format(entry.timestamp);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.secondaryText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActionColor(entry.action).withOpacity(0.15),
                  child: Icon(_getActionIcon(entry.action), color: _getActionColor(entry.action)),
                ),
                title: Text(
                  "${entry.counterName} (${_getActionTitle(entry.action)})",
                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.primaryText),
                ),
                subtitle: Text("Count: ${entry.count} • $timeStr", style: TextStyle(color: colors.secondaryText, fontSize: 12)),
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.sticky_note_2_rounded, color: Colors.blue),
                title: Text(entry.note == null || entry.note!.isEmpty ? "Add Note" : "Edit Note"),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  Navigator.pop(context);
                  _editNote(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Color(0xFF10B981)),
                title: const Text("Copy Details"),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  Navigator.pop(context);
                  final text = "${entry.counterName}: ${_getActionTitle(entry.action)} to ${entry.count} at $timeStr${entry.note != null ? '\nNote: ${entry.note}' : ''}";
                  Clipboard.setData(ClipboardData(text: text));
                  ToastService.success(context, "Copied", "Entry details copied to clipboard.");
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: Colors.purpleAccent),
                title: const Text("Share This Event"),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  Navigator.pop(context);
                  ShareService.shareHistory([entry]);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text("Delete Record", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.red),
                onTap: () {
                  Navigator.pop(context);
                  _deleteEntry(entry);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearAllHistory() async {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text("Clear History", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withOpacity(.25),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "This action will permanently delete all history records. This action cannot be undone.",
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Records", style: TextStyle(color: colors.secondaryText)),
                    Text(
                      "${_history.length}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setModalState) {
                      return FilledButton.icon(
                        onPressed: _isDeletingAll
                            ? null
                            : () async {
                                setModalState(() {
                                  _isDeletingAll = true;
                                });
                                await Future.delayed(
                                  const Duration(milliseconds: 600),
                                );
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                                setModalState(() {
                                  _isDeletingAll = false;
                                });
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isDeletingAll
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.delete_forever_rounded),
                        label: Text(_isDeletingAll ? "Clearing..." : "Clear All"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (_history.isEmpty) {
        if (mounted) {
          ToastService.info(context, "History Empty", "There is no history to delete.");
        }
        return;
      }
      try {
        await StorageService.resetHistory();
        if (mounted) {
          setState(() {
            _history.clear();
          });
          ToastService.success(context, "History Cleared", "All history has been deleted successfully.");
        }
      } catch (e) {
        if (mounted) {
          ToastService.error(context, "Delete Failed", "Unable to clear history.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredHistory;
    final grouped = _groupEntriesByDate(filtered);

    return PopScope(
      canPop: !_isSearchMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSearchMode) {
          setState(() {
            _isSearchMode = false;
            _searchQuery = "";
            _searchController.clear();
          });
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: isDark
              ? const Color(0xFF0F172A).withOpacity(0.85)
              : Colors.white.withOpacity(0.85),
          elevation: 0,
          centerTitle: true,
          title: Text(
            _isSearchMode ? "Search History" : "Activity History",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            if (_history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: "Export & Share History",
                onPressed: () {
                  ShareService.shareHistory(filtered);
                },
              ),
            if (!_isSearchMode && _history.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
                tooltip: "Clear All History",
                onPressed: _clearAllHistory,
              ),
            if (_isSearchMode)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: "Clear Search",
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = "";
                  });
                },
              ),
            const SizedBox(width: 4),
          ],
        ),
        body: Stack(
          children: [
            // Ambient Moving Glowing Aura Background Effect
            AnimatedBuilder(
              animation: _bgAnimationController,
              builder: (context, child) {
                final double progress = _bgAnimationController.value;
                return Stack(
                  children: [
                    Positioned(
                      top: -100 + (progress * 40),
                      right: -80 + (progress * 30),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDark ? const Color(0xFF3B82F6) : const Color(0xFF60A5FA))
                                .withOpacity(isDark ? 0.12 : 0.15),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 100 - (progress * 50),
                      left: -60 + (progress * 20),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA78BFA))
                                .withOpacity(isDark ? 0.10 : 0.12),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SafeArea(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (!_isSearchMode) ...[
                            const SizedBox(height: 8),
                            buildLuxurySummarySection(colors, isDark),
                            const SizedBox(height: 14),
                            buildCounterSelector(colors, isDark),
                            const SizedBox(height: 14),
                          ] else
                            const SizedBox(height: 8),

                          buildSearchBar(colors, isDark),
                          const SizedBox(height: 12),

                          buildFilterChips(colors, isDark),
                          const SizedBox(height: 12),

                          if (_isSearchMode)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8, left: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  filtered.length == 1
                                      ? "1 match found"
                                      : "${filtered.length} matches found",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colors.secondaryText,
                                  ),
                                ),
                              ),
                            ),

                          Expanded(
                            child: _history.isEmpty
                                ? buildEmptyHistory(colors, isDark)
                                : filtered.isEmpty
                                    ? buildNoSearchResult(colors, isDark)
                                    : ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: grouped.keys.length,
                                        itemBuilder: (context, dateIndex) {
                                          final dateKey = grouped.keys.elementAt(dateIndex);
                                          final dayEntries = grouped[dateKey]!;

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              buildDateHeader(dateKey, dayEntries.length, colors, isDark),
                                              ...dayEntries.map((entry) {
                                                return buildDismissibleHistoryCard(
                                                  entry: entry,
                                                  colors: colors,
                                                  isDark: isDark,
                                                );
                                              }),
                                              const SizedBox(height: 8),
                                            ],
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLuxurySummarySection(AppThemeColors colors, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: buildAnimatedStatCard(
            title: "Total Events",
            value: totalEvents,
            icon: Icons.auto_graph_rounded,
            color: const Color(0xFF3B82F6),
            colors: colors,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildAnimatedStatCard(
            title: "Today",
            value: todayEvents,
            icon: Icons.today_rounded,
            color: const Color(0xFF10B981),
            colors: colors,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildAnimatedStatCard(
            title: "7 Days",
            value: weekEvents,
            icon: Icons.calendar_view_week_rounded,
            color: const Color(0xFFF59E0B),
            colors: colors,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget buildAnimatedStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark
            ? color.withOpacity(0.08)
            : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                val.toInt().toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCounterSelector(AppThemeColors colors, bool isDark) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final selected = await showModalBottomSheet<String?>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.secondaryText.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        "Select Counter Filter",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          leading: const Icon(Icons.folder_copy_rounded, color: Colors.blue),
                          title: const Text("All Counters", style: TextStyle(fontWeight: FontWeight.w600)),
                          selected: _selectedCounter == null,
                          trailing: _selectedCounter == null
                              ? const Icon(Icons.check_circle_rounded, color: Colors.blue)
                              : null,
                          onTap: () => Navigator.pop(context, null),
                        ),
                        const Divider(height: 16),
                        ...counters.map(
                          (counter) => ListTile(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            leading: const Icon(Icons.numbers_rounded, color: Colors.grey),
                            title: Text(counter, style: const TextStyle(fontWeight: FontWeight.w500)),
                            selected: _selectedCounter == counter,
                            trailing: _selectedCounter == counter
                                ? const Icon(Icons.check_circle_rounded, color: Colors.blue)
                                : null,
                            onTap: () => Navigator.pop(context, counter),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );

        if (selected != _selectedCounter) {
          setState(() {
            _selectedCounter = selected;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedCounter != null
                ? Colors.blue.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.countertops_rounded, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCounter ?? "All Counters",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: colors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedCounter == null
                        ? "Showing activity across all counters"
                        : "Filtering activity for this counter",
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedCounter != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCounter = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 16),
                ),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.secondaryText,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar(AppThemeColors colors, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _searchFocusNode.hasFocus || _searchQuery.isNotEmpty
              ? Colors.blue
              : Colors.grey.withOpacity(0.2),
          width: _searchFocusNode.hasFocus ? 1.8 : 1.0,
        ),
        boxShadow: [
          if (_searchFocusNode.hasFocus)
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onTap: () {
          setState(() {
            _isSearchMode = true;
          });
        },
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
            _isSearchMode = true;
          });
        },
        textInputAction: TextInputAction.search,
        onSubmitted: (_) {
          FocusScope.of(context).unfocus();
        },
        style: TextStyle(
          color: colors.primaryText,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search by counter, count, note, or time...",
          hintStyle: TextStyle(
            color: colors.secondaryText.withOpacity(0.7),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.blue,
            size: 22,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                ),
        ),
      ),
    );
  }

  Widget buildFilterChips(AppThemeColors colors, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Action Filter Chips
          buildChoiceChip(
            label: "All Actions",
            isSelected: _selectedActionFilter == null,
            activeColor: Colors.blue,
            colors: colors,
            isDark: isDark,
            onSelected: () {
              setState(() {
                _selectedActionFilter = null;
              });
            },
          ),
          const SizedBox(width: 8),
          buildChoiceChip(
            label: "Increase",
            icon: Icons.add_rounded,
            isSelected: _selectedActionFilter == HistoryAction.increase,
            activeColor: const Color(0xFF10B981),
            colors: colors,
            isDark: isDark,
            onSelected: () {
              setState(() {
                _selectedActionFilter = HistoryAction.increase;
              });
            },
          ),
          const SizedBox(width: 8),
          buildChoiceChip(
            label: "Decrease",
            icon: Icons.remove_rounded,
            isSelected: _selectedActionFilter == HistoryAction.decrease,
            activeColor: const Color(0xFFEF4444),
            colors: colors,
            isDark: isDark,
            onSelected: () {
              setState(() {
                _selectedActionFilter = HistoryAction.decrease;
              });
            },
          ),
          const SizedBox(width: 8),
          buildChoiceChip(
            label: "Reset",
            icon: Icons.restart_alt_rounded,
            isSelected: _selectedActionFilter == HistoryAction.reset,
            activeColor: const Color(0xFFF59E0B),
            colors: colors,
            isDark: isDark,
            onSelected: () {
              setState(() {
                _selectedActionFilter = HistoryAction.reset;
              });
            },
          ),
          const SizedBox(width: 14),
          Container(
            height: 20,
            width: 1,
            color: colors.secondaryText.withOpacity(0.3),
          ),
          const SizedBox(width: 14),
          // Time Period Filter Chips
          ...["All Time", "Today", "Yesterday", "7 Days", "30 Days"].map((timeFilter) {
            final isSelected = _selectedTimeFilter == timeFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: buildChoiceChip(
                label: timeFilter,
                isSelected: isSelected,
                activeColor: Colors.purpleAccent,
                colors: colors,
                isDark: isDark,
                onSelected: () {
                  setState(() {
                    _selectedTimeFilter = timeFilter;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildChoiceChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Color activeColor,
    required AppThemeColors colors,
    required bool isDark,
    required VoidCallback onSelected,
  }) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.2)
              : isDark
                  ? const Color(0xFF1E293B)
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? activeColor : colors.secondaryText,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : colors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateHeader(String dateLabel, int count, AppThemeColors colors, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: colors.primaryText,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$count event${count == 1 ? '' : 's'}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDismissibleHistoryCard({
    required HistoryEntry entry,
    required AppThemeColors colors,
    required bool isDark,
  }) {
    final color = _getActionColor(entry.action);
    final icon = _getActionIcon(entry.action);
    final title = _getActionTitle(entry.action);
    final timeStr = DateFormat("hh:mm a").format(entry.timestamp);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Delete",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (_) => _deleteEntry(entry),
      child: GestureDetector(
        onTap: () => _showEntryOptions(entry),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Glowing Left Indicator Bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Live Pulsing Action Icon
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 42 + (_pulseController.value * 4),
                                      height: 42 + (_pulseController.value * 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color.withOpacity(0.15 * _pulseController.value),
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: color.withOpacity(0.18),
                                      child: Icon(icon, color: color, size: 22),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: colors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.counterName,
                                    style: TextStyle(
                                      color: colors.secondaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: colors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _showEntryOptions(entry),
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: colors.secondaryText,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: color.withOpacity(0.25)),
                              ),
                              child: Text(
                                "Count : ${entry.count}",
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: GestureDetector(
                                onTap: () => _editNote(entry),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: entry.note != null && entry.note!.isNotEmpty
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: entry.note != null && entry.note!.isNotEmpty
                                          ? Colors.blue.withOpacity(0.3)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        entry.note != null && entry.note!.isNotEmpty
                                            ? Icons.sticky_note_2_rounded
                                            : Icons.add_comment_rounded,
                                        size: 14,
                                        color: entry.note != null && entry.note!.isNotEmpty
                                            ? Colors.blue
                                            : colors.secondaryText,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          entry.note != null && entry.note!.isNotEmpty
                                              ? entry.note!
                                              : "Add Note...",
                                          style: TextStyle(
                                            fontStyle: entry.note != null && entry.note!.isNotEmpty
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                            fontSize: 11,
                                            color: entry.note != null && entry.note!.isNotEmpty
                                                ? colors.primaryText
                                                : colors.secondaryText,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyHistory(AppThemeColors colors, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 140 + (_pulseController.value * 10),
                    height: 140 + (_pulseController.value * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.08 * _pulseController.value),
                    ),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.12),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 64,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                "No Activity History",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your counting activities, increments, resets, and custom notes will automatically record here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.touch_app_rounded),
                label: const Text("Start Counting", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNoSearchResult(AppThemeColors colors, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 56,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "No Matching Events",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No activity records match your current filters or query "$_searchQuery".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.secondaryText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = "";
                    _selectedActionFilter = null;
                    _selectedTimeFilter = "All Time";
                    _selectedCounter = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Reset All Filters"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}