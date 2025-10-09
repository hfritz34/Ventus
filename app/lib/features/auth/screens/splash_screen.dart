import 'package:flutter/material.dart';
import 'package:app/shared/widgets/sun_loading_spinner.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/ventus_branding_dark.png', height: 80),
            const SizedBox(height: 48),
            const SunLoadingSpinner(size: 50, strokeWidth: 4),
            const SizedBox(height: 24),
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
              child: const Text(
                'Starting your day...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
