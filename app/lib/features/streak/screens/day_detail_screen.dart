import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:app/features/streak/providers/streak_provider.dart';
import 'package:app/core/services/storage_service.dart';

class DayDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DayDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(streakProvider.notifier).getEntryForDate(date);
    final alarm = entry != null ? StorageService().getAlarm(entry.alarmId) : null;

    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(formattedDate),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: entry == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No alarm data for this day',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo section
                  if (entry.photoUrl != null && entry.photoUrl!.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: PhotoView(
                        imageProvider: FileImage(File(entry.photoUrl!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      color: Colors.grey[900],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 64,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No photo available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Details section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: entry.success
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: entry.success
                                      ? Colors.green[300]!
                                      : Colors.red[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    entry.success
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 20,
                                    color: entry.success
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.success ? 'Success' : 'Failed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: entry.success
                                          ? Colors.green[700]
                                          : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Alarm details
                        if (alarm != null) ...[
                          _DetailRow(
                            icon: Icons.alarm,
                            label: 'Alarm Time',
                            value: DateFormat.jm().format(alarm.alarmTime),
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.timer,
                            label: 'Grace Window',
                            value: '${alarm.graceWindowMinutes} minutes',
                          ),
                          const SizedBox(height: 16),
                          if (alarm.accountabilityContactName != null)
                            _DetailRow(
                              icon: Icons.person,
                              label: 'Accountability Partner',
                              value: alarm.accountabilityContactName!,
                            ),
                          const SizedBox(height: 16),
                        ],
                        _DetailRow(
                          icon: Icons.access_time,
                          label: 'Recorded At',
                          value: DateFormat('h:mm a').format(entry.createdAt),
                        ),
                        if (!entry.success && alarm?.accountabilityContactPhone != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.message, color: Colors.orange[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Accountability message sent',
                                    style: TextStyle(
                                      color: Colors.orange[900],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
