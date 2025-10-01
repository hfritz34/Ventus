import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class PermissionService {
  final Logger _logger = Logger();

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    _logger.i('Camera permission status: $status');
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    _logger.i('Notification permission status: $status');
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    _logger.i('Location permission status: $status');
    return status.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  Future<bool> checkNotificationPermission() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> checkLocationPermission() async {
    return await Permission.location.isGranted;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
