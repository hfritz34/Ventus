import 'package:flutter/material.dart';
import 'dart:math' as math;

class SunLoadingSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const SunLoadingSpinner({
    super.key,
    this.size = 50.0,
    this.strokeWidth = 4.0,
  });

  @override
  State<SunLoadingSpinner> createState() => _SunLoadingSpinnerState();
}

class _SunLoadingSpinnerState extends State<SunLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SunGradientPainter(strokeWidth: widget.strokeWidth),
          ),
        );
      },
    );
  }
}

class _SunGradientPainter extends CustomPainter {
  final double strokeWidth;

  _SunGradientPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      colors: const [
        Color(0xFFF9C784), // Pale peachy orange
        Color(0xFFFC7A1E), // Vibrant orange
        Color(0xFFF24C00), // Rich reddish-orange
        Color(0xFFF9C784), // Back to start for smooth loop
      ],
      stops: const [0.0, 0.5, 0.75, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc (3/4 of circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      3 * math.pi / 2, // Draw 3/4 circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Full screen loading overlay with sun spinner
class SunLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isDismissible;

  const SunLoadingOverlay({
    super.key,
    this.message,
    this.isDismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDismissible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SunLoadingSpinner(size: 60, strokeWidth: 5),
              if (message != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    message!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show loading overlay
  static void show(
    BuildContext context, {
    String? message,
    bool isDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: Colors.transparent,
      builder: (context) =>
          SunLoadingOverlay(message: message, isDismissible: isDismissible),
    );
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
