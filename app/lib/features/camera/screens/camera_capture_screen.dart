import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/features/camera/services/camera_service.dart';
import 'package:app/core/services/permission_service.dart';
import 'package:app/core/services/alarm_trigger_service.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
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

  void _handleGraceExpired() {
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
      final image = await _controller!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(image.path).copy(imagePath);

      AlarmTriggerService().clearActiveAlarm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured! Alarm completed successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(imagePath);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to capture photo: $e';
      });
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
