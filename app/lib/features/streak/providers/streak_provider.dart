import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/streak/models/streak_entry.dart';
import 'package:app/features/streak/services/streak_service.dart';

class StreakNotifier extends StateNotifier<List<StreakEntry>> {
  final StreakService _streakService;

  StreakNotifier(this._streakService) : super([]);

  /// Load all streak entries from storage
  void loadStreaks(List<StreakEntry> streaks) {
    state = streaks;
  }

  /// Add a new streak entry
  Future<void> addStreakEntry(StreakEntry entry) async {
    await _streakService.saveStreakEntry(entry);
    state = [...state, entry];
  }

  /// Get streak entries for a specific month
  List<StreakEntry> getEntriesForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return state.where((entry) {
      return entry.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get current streak (consecutive successful days)
  int getCurrentStreak() {
    final sortedEntries = [...state]..sort((a, b) => b.date.compareTo(a.date));

    if (sortedEntries.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (var entry in sortedEntries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

      // Check if entry is from yesterday or today
      final difference = checkDate.difference(entryDate).inDays;

      if (difference > 1) {
        break; // Gap in streak
      }

      if (entry.success) {
        streak++;
        currentDate = entry.date;
      } else {
        break; // Failed day breaks streak
      }
    }

    return streak;
  }

  /// Get longest streak
  int getLongestStreak() {
    final sortedEntries = [...state]..sort((a, b) => a.date.compareTo(b.date));

    if (sortedEntries.isEmpty) return 0;

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (var entry in sortedEntries) {
      if (!entry.success) {
        currentStreak = 0;
        lastDate = entry.date;
        continue;
      }

      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final daysDifference = entry.date.difference(lastDate).inDays;
        if (daysDifference == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }

      longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      lastDate = entry.date;
    }

    return longestStreak;
  }

  /// Get success rate (percentage)
  double getSuccessRate() {
    if (state.isEmpty) return 0.0;

    final successCount = state.where((entry) => entry.success).length;
    return (successCount / state.length) * 100;
  }

  /// Get total successful alarms
  int getTotalSuccessful() {
    return state.where((entry) => entry.success).length;
  }

  /// Get entry for specific date
  StreakEntry? getEntryForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    for (var entry in state) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (entryDate == normalizedDate) {
        return entry;
      }
    }

    return null;
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, List<StreakEntry>>((ref) {
  return StreakNotifier(StreakService());
});
