import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app/features/streak/providers/streak_provider.dart';
import 'package:app/features/streak/models/streak_entry.dart';

class StreakCalendar extends ConsumerStatefulWidget {
  final Function(DateTime) onDayTapped;

  const StreakCalendar({super.key, required this.onDayTapped});

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
      final normalizedDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
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

    final sortedYears = availableYears.toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order

    // Ensure selected year is valid
    if (!availableYears.contains(_selectedYear)) {
      _selectedYear = sortedYears.first;
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    // Calculate grid based on the selected year (GitHub-style)
    // 1. Define the date range for the selected year
    final yearStartDate = DateTime(_selectedYear, 1, 1);

    // For the current year, end at today. For past years, end at Dec 31.
    final yearEndDate = _selectedYear == today.year
        ? normalizedToday
        : DateTime(_selectedYear, 12, 31);

    // 2. Pad to complete weeks at the START only
    // Find the Sunday of the week containing January 1st
    int daysToSunday = yearStartDate.weekday % 7;
    final gridStart = yearStartDate.subtract(Duration(days: daysToSunday));

    // End at the actual last day (no padding at the end)
    final gridEnd = yearEndDate;

    // 3. Build weeks data structure
    final weeks = <List<DateTime>>[];
    DateTime currentDate = gridStart;
    while (currentDate.isBefore(gridEnd.add(const Duration(days: 1)))) {
      final weekDays = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        weekDays.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      weeks.add(weekDays);
    }

    // Get month labels and their positions for all months in the visible range
    final monthLabels = <MapEntry<int, String>>[];
    DateTime currentMonth = DateTime(gridStart.year, gridStart.month, 1);
    final endMonth = DateTime(gridEnd.year, gridEnd.month, 1);

    while (currentMonth.isBefore(endMonth) || currentMonth == endMonth) {
      final weekIndex = currentMonth.difference(gridStart).inDays ~/ 7;
      if (weekIndex >= 0 && weekIndex < weeks.length) {
        monthLabels.add(
          MapEntry(weekIndex, DateFormat('MMM').format(currentMonth)),
        );
      }
      // Move to next month
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
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
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF9C784), // Pale peachy orange
                    Color(0xFFFC7A1E), // Vibrant orange
                    Color(0xFFF24C00), // Rich reddish-orange
                  ],
                ).createShader(bounds),
                child: Text(
                  '$totalContributions wake-ups in $_selectedYear',
                  style: const TextStyle(
                    fontSize: 14,
                    color:
                        Colors.white, // Base color (will be masked by gradient)
                    fontWeight: FontWeight.w500,
                  ),
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
        // Main grid with month labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels (Mon, Wed, Fri) - Fixed on left
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 20), // Space for month labels
                const SizedBox(height: 4),
                const SizedBox(height: 15), // Offset for first row
                _DayLabel('Mon'),
                _DayLabel(''),
                _DayLabel('Wed'),
                _DayLabel(''),
                _DayLabel('Fri'),
                _DayLabel(''),
                const SizedBox(height: 15),
              ],
            ),
            const SizedBox(width: 4),
            // Scrollable area with month labels and grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Start at the end (most recent)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month labels
                    SizedBox(
                      height: 20,
                      child: Row(
                        children: List.generate(weeks.length, (index) {
                          // Find if this week index has a month label
                          final monthEntry = monthLabels.firstWhere(
                            (entry) => entry.key == index,
                            orElse: () => const MapEntry(-1, ''),
                          );

                          return SizedBox(
                            width: 17.0, // Same as cell width + padding
                            child: monthEntry.key != -1
                                ? Text(
                                    monthEntry.value,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Grid cells
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weeks.map((week) {
                        return Column(
                          children: week.map((day) {
                            final normalizedDay = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );

                            // Don't render future dates at all
                            if (normalizedDay.isAfter(gridEnd)) {
                              return const SizedBox.shrink();
                            }

                            final entry = streakMap[normalizedDay];
                            final isPaddingDay = day.year != _selectedYear;
                            final isToday = normalizedDay == normalizedToday;

                            Color backgroundColor;

                            if (isPaddingDay) {
                              // Padding days at the start (before Jan 1)
                              backgroundColor = Colors.grey[100]!;
                            } else if (entry != null) {
                              // Days with alarm data
                              if (entry.success) {
                                backgroundColor = Theme.of(
                                  context,
                                ).primaryColor;
                              } else {
                                backgroundColor = Colors.grey[400]!;
                              }
                            } else {
                              // Past days with no alarm set
                              backgroundColor = Colors.grey[200]!;
                            }

                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: GestureDetector(
                                onTap: !isPaddingDay
                                    ? () => widget.onDayTapped(day)
                                    : null,
                                child: Tooltip(
                                  message: entry != null
                                      ? '${entry.success ? "Success" : "Failed"} on ${DateFormat('EEEE, MMMM d, y').format(day)}'
                                      : 'No alarm on ${DateFormat('EEEE, MMMM d, y').format(day)}',
                                  child: Container(
                                    width: 13,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(2),
                                      border: isToday
                                          ? Border.all(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
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
                  ],
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
      height: 17,
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
