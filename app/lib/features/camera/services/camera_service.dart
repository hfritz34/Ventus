import 'package:camera/camera.dart';
import 'package:logger/logger.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final Logger _logger = Logger();
  List<CameraDescription>? _cameras;
  CameraController? _controller;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      _logger.i('Found ${_cameras?.length ?? 0} cameras');
    } catch (e) {
      _logger.e('Error initializing cameras: $e');
    }
  }

  Future<CameraController?> getCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) {
      await initialize();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      _logger.e('No cameras available');
      return null;
    }

    final frontCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      _logger.i('Camera controller initialized');
      return _controller;
    } catch (e) {
      _logger.e('Error initializing camera controller: $e');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
