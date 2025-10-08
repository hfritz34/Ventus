import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/streak/providers/streak_provider.dart';
import 'package:app/features/streak/models/streak_entry.dart';

class StreakCalendar extends ConsumerWidget {
  final DateTime focusedMonth;
  final Function(DateTime) onDayTapped;

  const StreakCalendar({
    super.key,
    required this.focusedMonth,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaks = ref.watch(streakProvider);

    // Get start of month (find first Monday before or on the 1st)
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

    // Calculate grid start (previous Monday)
    int daysToSubtract = firstDayOfMonth.weekday - 1; // Monday = 1
    final gridStart = firstDayOfMonth.subtract(Duration(days: daysToSubtract));

    // Calculate grid end (next Sunday)
    int daysToAdd = 7 - lastDayOfMonth.weekday; // Sunday = 7
    final gridEnd = lastDayOfMonth.add(Duration(days: daysToAdd));

    // Generate all days in grid
    final totalDays = gridEnd.difference(gridStart).inDays + 1;
    final days = List.generate(totalDays, (index) {
      return gridStart.add(Duration(days: index));
    });

    // Create a map of dates to streak entries for quick lookup
    final streakMap = <DateTime, StreakEntry>{};
    for (var entry in streaks) {
      final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      streakMap[normalizedDate] = entry;
    }

    return Column(
      children: [
        // Weekday headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final normalizedDay = DateTime(day.year, day.month, day.day);
            final normalizedToday = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

            final entry = streakMap[normalizedDay];
            final isCurrentMonth = day.month == focusedMonth.month;
            final isFuture = normalizedDay.isAfter(normalizedToday);
            final isToday = normalizedDay == normalizedToday;

            Color backgroundColor;
            Color? borderColor;

            if (isFuture) {
              // Future days - white/transparent
              backgroundColor = Colors.grey[100]!;
            } else if (entry != null) {
              if (entry.success) {
                // Success - orange/red/yellow gradient based on consistency
                backgroundColor = Theme.of(context).primaryColor;
              } else {
                // Failed - grey
                backgroundColor = Colors.grey[400]!;
              }
            } else {
              // No alarm set - light grey outline
              backgroundColor = Colors.white;
              borderColor = Colors.grey[300];
            }

            if (isToday) {
              borderColor = Theme.of(context).primaryColor;
            }

            return GestureDetector(
              onTap: isCurrentMonth && !isFuture ? () => onDayTapped(day) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: borderColor != null
                      ? Border.all(color: borderColor, width: isToday ? 2 : 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentMonth
                          ? (entry?.success == true ? Colors.white : Colors.black87)
                          : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
