import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/constants/app_theme.dart';
import 'package:app/core/routing/app_router.dart';
import 'package:app/core/services/notification_service.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/core/services/amplify_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AmplifyService().configure();
  await StorageService().initialize();
  await NotificationService().initialize();
  runApp(const ProviderScope(child: VentusApp()));
}

class VentusApp extends StatelessWidget {
  const VentusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ventus',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
