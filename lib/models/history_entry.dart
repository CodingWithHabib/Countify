import 'dart:convert';

enum HistoryAction {
  increase,
  decrease,
  reset,
}

class HistoryEntry {
  final String id;
  final String counterId;
  final String counterName;
  final HistoryAction action;
  final int count;
  final DateTime timestamp;
  final String? note;

  const HistoryEntry({
    required this.id,
    required this.counterId,
    required this.counterName,
    required this.action,
    required this.count,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'counterId': counterId,
      'counterName': counterName,
      'action': action.name,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id']?.toString() ?? '',
      counterId: map['counterId']?.toString() ?? '',
      counterName: map['counterName']?.toString() ?? 'Counter',
      action: HistoryAction.values.firstWhere(
        (e) => e.name == map['action']?.toString(),
        orElse: () => HistoryAction.increase,
      ),
      count: (map['count'] as num?)?.toInt() ?? 0,
      timestamp: map['timestamp'] != null
          ? (DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
      note: map['note']?.toString(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory HistoryEntry.fromJson(String source) {
    try {
      final map = jsonDecode(source);
      if (map is Map<String, dynamic>) {
        return HistoryEntry.fromMap(map);
      }
    } catch (_) {}
    return HistoryEntry(
      id: '',
      counterId: '',
      counterName: 'Counter',
      action: HistoryAction.increase,
      count: 0,
      timestamp: DateTime.now(),
    );
  }
}
