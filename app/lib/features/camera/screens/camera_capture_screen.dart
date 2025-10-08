import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/camera/services/camera_service.dart';
import 'package:app/core/services/permission_service.dart';
import 'package:app/core/services/alarm_trigger_service.dart';
import 'package:app/core/services/photo_verification_service.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/streak/models/streak_entry.dart';
import 'package:app/features/streak/providers/streak_provider.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  ConsumerState<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraController? _controller;
  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _startGraceTimer();
  }

  void _startGraceTimer() {
    final deadline = AlarmTriggerService().graceDeadline;
    if (deadline == null) return;

    _remainingTime = deadline.difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = deadline.difference(DateTime.now());

      if (newRemaining.isNegative) {
        timer.cancel();
        _handleGraceExpired();
      } else {
        setState(() {
          _remainingTime = newRemaining;
        });
      }
    });
  }

  Future<void> _handleGraceExpired() async {
    final alarmId = AlarmTriggerService().activeAlarmId;
    if (alarmId == null) return;

    try {
      final alarm = StorageService().getAlarm(alarmId);
      if (alarm == null) return;

      final authState = ref.read(authProvider);
      final userName = authState.username ?? 'User';
      final userId = authState.userId ?? '';

      // Save failed streak entry
      final failedEntry = StreakEntry(
        userId: userId,
        date: DateTime.now(),
        success: false,
        photoUrl: null,
        alarmId: alarmId,
      );
      await ref.read(streakProvider.notifier).addStreakEntry(failedEntry);

      // Call Lambda to send accountability message
      await PhotoVerificationService().verifyPhoto(
        photoPath: '', // Empty path signals grace expiration
        contactPhone: alarm.accountabilityContactPhone ?? '',
        userName: userName,
        customMessage: alarm.customAccountabilityMessage,
      );
    } catch (e) {
      // Log error but continue
    }

    AlarmTriggerService().clearActiveAlarm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grace period expired! Accountability message sent.'),
          backgroundColor: Colors.red,
        ),
      );
      context.pop();
    }
  }

  Future<void> _initializeCamera() async {
    final hasPermission = await PermissionService().requestCameraPermission();

    if (!hasPermission) {
      setState(() {
        _error = 'Camera permission denied';
        _isLoading = false;
      });
      return;
    }

    final controller = await CameraService().getCameraController();

    if (controller == null) {
      setState(() {
        _error = 'Failed to initialize camera';
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final image = await _controller!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(image.path).copy(imagePath);

      // Get alarm details for verification
      final alarmId = AlarmTriggerService().activeAlarmId;
      if (alarmId == null) {
        throw Exception('No active alarm found');
      }

      // Get alarm from storage to get contact info
      final alarm = StorageService().getAlarm(alarmId);
      if (alarm == null) {
        throw Exception('Alarm not found');
      }

      // Get user info from auth provider
      final authState = ref.read(authProvider);
      final userName = authState.username ?? 'User';

      // Verify photo with Rekognition
      final verificationResult = await PhotoVerificationService().verifyPhoto(
        photoPath: imagePath,
        contactPhone: alarm.accountabilityContactPhone ?? '',
        userName: userName,
        customMessage: alarm.customAccountabilityMessage,
      );

      // Hide loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (verificationResult['isOutdoor'] == true) {
        // Success - outdoor photo verified!
        // Save successful streak entry
        final authState = ref.read(authProvider);
        final userId = authState.userId ?? '';

        final successEntry = StreakEntry(
          userId: userId,
          date: DateTime.now(),
          success: true,
          photoUrl: imagePath,
          alarmId: alarmId,
        );
        await ref.read(streakProvider.notifier).addStreakEntry(successEntry);

        AlarmTriggerService().clearActiveAlarm();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verificationResult['message'] ?? 'Photo verified!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(imagePath);
        }
      } else {
        // Failed - not outdoor or verification error
        // Save failed streak entry
        final authState = ref.read(authProvider);
        final userId = authState.userId ?? '';

        final failedEntry = StreakEntry(
          userId: userId,
          date: DateTime.now(),
          success: false,
          photoUrl: null,
          alarmId: alarmId,
        );
        await ref.read(streakProvider.notifier).addStreakEntry(failedEntry);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(verificationResult['message'] ?? 'Photo not verified'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading dialog if still showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      setState(() {
        _error = 'Failed to capture photo: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    CameraService().dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Take Outdoor Selfie'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: CameraPreview(_controller!),
                    ),
                    if (_remainingTime != null)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _remainingTime!.inMinutes < 2
                                  ? Colors.red.withValues(alpha: 0.9)
                                  : Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'Time remaining: ${_formatDuration(_remainingTime!)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        color: Colors.black54,
                        child: Column(
                          children: [
                            const Text(
                              'Make sure you\'re outdoors and visible',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FloatingActionButton.large(
                              onPressed: _takePicture,
                              child: const Icon(Icons.camera_alt, size: 32),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
