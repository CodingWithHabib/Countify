import '../models/counter_model.dart';
import 'storage_service.dart';

class CounterManager {

  /// Creates the first counter if none exists.
  static Future<List<CounterModel>> createDefaultCounter({
    required int count,
    required int highestCount,
  }) async {

    final counters =
    await StorageService.loadCounters();

    if (counters.isNotEmpty) {
      return counters;
    }

    final defaultCounter = CounterModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      name: "My Counter",

      count: count,

      highestCount: highestCount,
    );

    final updatedCounters = [
      defaultCounter,
    ];

    await StorageService.saveCounters(
      updatedCounters,
    );

    await StorageService.saveSelectedCounterId(
      defaultCounter.id,
    );

    return updatedCounters;
  }
}