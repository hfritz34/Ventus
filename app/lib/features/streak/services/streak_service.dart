import 'package:app/features/streak/models/streak_entry.dart';
import 'package:hive/hive.dart';

class StreakService {
  static const String _streakBoxName = 'streak_entries';

  /// Get the Hive box for streak entries
  Box<StreakEntry> _getStreakBox() {
    return Hive.box<StreakEntry>(_streakBoxName);
  }

  /// Save a streak entry to local storage
  Future<void> saveStreakEntry(StreakEntry entry) async {
    final box = _getStreakBox();
    await box.put(entry.id, entry);
  }

  /// Get all streak entries
  List<StreakEntry> getAllStreakEntries() {
    final box = _getStreakBox();
    return box.values.toList();
  }

  /// Get streak entry by ID
  StreakEntry? getStreakEntry(String id) {
    final box = _getStreakBox();
    return box.get(id);
  }

  /// Delete a streak entry
  Future<void> deleteStreakEntry(String id) async {
    final box = _getStreakBox();
    await box.delete(id);
  }

  /// Get streak entries for a specific user
  List<StreakEntry> getStreakEntriesForUser(String userId) {
    final box = _getStreakBox();
    return box.values.where((entry) => entry.userId == userId).toList();
  }

  /// Get streak entries for a specific date range
  List<StreakEntry> getStreakEntriesForDateRange(DateTime start, DateTime end) {
    final box = _getStreakBox();
    return box.values.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Clear all streak entries
  Future<void> clearAllStreakEntries() async {
    final box = _getStreakBox();
    await box.clear();
  }
}
