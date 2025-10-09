import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app/features/streak/providers/streak_provider.dart';
import 'package:app/features/streak/models/streak_entry.dart';

class StreakCalendar extends ConsumerStatefulWidget {
  final Function(DateTime) onDayTapped;

  const StreakCalendar({
    super.key,
    required this.onDayTapped,
  });

  @override
  ConsumerState<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends ConsumerState<StreakCalendar> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final streaks = ref.watch(streakProvider);
    final totalContributions = streaks.where((s) => s.success).length;

    // Create a map of dates to streak entries for quick lookup
    final streakMap = <DateTime, StreakEntry>{};
    for (var entry in streaks) {
      final normalizedDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      streakMap[normalizedDate] = entry;
    }

    // Get available years from streak data
    final availableYears = <int>{};
    for (var entry in streaks) {
      availableYears.add(entry.date.year);
    }

    // If no data, show current year
    if (availableYears.isEmpty) {
      availableYears.add(DateTime.now().year);
    }

    final sortedYears = availableYears.toList()..sort((a, b) => b.compareTo(a)); // Descending order

    // Ensure selected year is valid
    if (!availableYears.contains(_selectedYear)) {
      _selectedYear = sortedYears.first;
    }

    // Calculate the start date (first day of the year, but start on Sunday/Monday)
    final yearStart = DateTime(_selectedYear, 1, 1);
    final yearEnd = DateTime(_selectedYear, 12, 31);

    // Find the first Sunday before or on yearStart
    int daysToSubtract = yearStart.weekday % 7; // Sunday = 0, Monday = 1, etc.
    final gridStart = yearStart.subtract(Duration(days: daysToSubtract));

    // Find the last Saturday after or on yearEnd
    int daysToAdd = (6 - yearEnd.weekday % 7) % 7;
    final gridEnd = yearEnd.add(Duration(days: daysToAdd));

    // Calculate total weeks
    final totalDays = gridEnd.difference(gridStart).inDays + 1;
    final totalWeeks = (totalDays / 7).ceil();

    // Build weeks data structure
    final weeks = <List<DateTime>>[];
    for (int week = 0; week < totalWeeks; week++) {
      final weekDays = <DateTime>[];
      for (int day = 0; day < 7; day++) {
        final date = gridStart.add(Duration(days: week * 7 + day));
        weekDays.add(date);
      }
      weeks.add(weekDays);
    }

    // Get month labels and their positions
    final monthLabels = <MapEntry<int, String>>[];
    for (int month = 1; month <= 12; month++) {
      final monthStart = DateTime(_selectedYear, month, 1);
      final weekIndex = monthStart.difference(gridStart).inDays ~/ 7;
      if (weekIndex < totalWeeks) {
        monthLabels.add(MapEntry(weekIndex, DateFormat('MMM').format(monthStart)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Total contributions + Year selector
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalContributions wake-ups in $_selectedYear',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: sortedYears.map((year) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _YearButton(
                      year: year,
                      isSelected: _selectedYear == year,
                      onTap: () => setState(() => _selectedYear = year),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Month labels
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 34), // Space for day labels + spacing
              SizedBox(
                width: totalWeeks * 13.0, // Width based on total weeks
                height: 20,
                child: Stack(
                  children: monthLabels.map((entry) {
                    return Positioned(
                      left: entry.key * 13.0, // 13 = cell width + spacing
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Main grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels (Mon, Wed, Fri)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 13), // Offset for first row
                _DayLabel('Mon'),
                _DayLabel(''),
                _DayLabel('Wed'),
                _DayLabel(''),
                _DayLabel('Fri'),
                _DayLabel(''),
                const SizedBox(height: 11),
              ],
            ),
            const SizedBox(width: 4),
            // Grid cells
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((week) {
                    return Column(
                      children: week.map((day) {
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        final normalizedToday = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        );

                        final yearStart = DateTime(_selectedYear, 1, 1);
                        final yearEnd = DateTime(_selectedYear, 12, 31);

                        // Check if this is a padding day (outside the actual year range)
                        final isPaddingDay = normalizedDay.isBefore(yearStart) || normalizedDay.isAfter(yearEnd);

                        final entry = streakMap[normalizedDay];
                        final isFuture = normalizedDay.isAfter(normalizedToday);
                        final isToday = normalizedDay == normalizedToday && !isPaddingDay;

                        Color backgroundColor;

                        if (isPaddingDay) {
                          // Padding days - default background, non-interactive
                          backgroundColor = Colors.grey[200]!;
                        } else if (isFuture) {
                          // Future days within the year
                          backgroundColor = Colors.grey[200]!;
                        } else if (entry != null) {
                          // Days with data
                          if (entry.success) {
                            backgroundColor = Theme.of(context).primaryColor;
                          } else {
                            backgroundColor = Colors.grey[400]!;
                          }
                        } else {
                          // Past days with no alarm set
                          backgroundColor = Colors.grey[200]!;
                        }

                        return Padding(
                          padding: const EdgeInsets.all(1.5),
                          child: GestureDetector(
                            onTap: !isPaddingDay && !isFuture
                                ? () => widget.onDayTapped(day)
                                : null,
                            child: Tooltip(
                              message: isPaddingDay
                                  ? ''
                                  : entry != null
                                      ? '${entry.success ? "Success" : "Failed"} on ${DateFormat('EEEE, MMMM d, y').format(day)}'
                                      : 'No alarm on ${DateFormat('EEEE, MMMM d, y').format(day)}',
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(2),
                                  border: isToday
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _LegendSquare(color: Colors.grey[200]!),
            const SizedBox(width: 6),
            Text(
              'No alarm',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            _LegendSquare(color: Colors.grey[400]!),
            const SizedBox(width: 6),
            Text(
              'Failed',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),
            _LegendSquare(color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(
              'Success',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

class _YearButton extends StatelessWidget {
  final int year;
  final bool isSelected;
  final VoidCallback onTap;

  const _YearButton({
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$year',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 14,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class _LegendSquare extends StatelessWidget {
  final Color color;

  const _LegendSquare({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
