import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/alarm/screens/alarm_list_screen.dart';
import 'package:app/features/alarm/screens/add_alarm_screen.dart';
import 'package:app/features/alarm/screens/edit_alarm_screen.dart';
import 'package:app/features/alarm/models/alarm.dart';
import 'package:app/features/camera/screens/camera_capture_screen.dart';
import 'package:app/features/auth/screens/login_screen.dart';
import 'package:app/features/auth/screens/signup_screen.dart';
import 'package:app/features/auth/screens/verify_email_screen.dart';
import 'package:app/features/auth/screens/profile_screen.dart';
import 'package:app/features/auth/screens/settings_screen.dart';
import 'package:app/features/auth/screens/splash_screen.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/streak/screens/stats_screen.dart';
import 'package:app/features/streak/screens/day_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final isGoingToSplash = state.matchedLocation == '/splash';
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToVerify = state.matchedLocation == '/verify-email';

      // Show splash screen while checking auth
      if (isLoading && !isGoingToSplash) {
        return '/splash';
      }

      // Once loaded, redirect away from splash
      if (!isLoading && isGoingToSplash) {
        return isAuthenticated ? '/' : '/login';
      }

      // If not authenticated and not going to auth screens, redirect to login
      if (!isLoading &&
          !isAuthenticated &&
          !isGoingToLogin &&
          !isGoingToSignup &&
          !isGoingToVerify) {
        return '/login';
      }

      // If authenticated and going to auth screens, redirect to home
      if (isAuthenticated && (isGoingToLogin || isGoingToSignup)) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          final email = state.extra as String;
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const AlarmListScreen(),
      ),
      GoRoute(
        path: '/add-alarm',
        name: 'add-alarm',
        builder: (context, state) => const AddAlarmScreen(),
      ),
      GoRoute(
        path: '/edit-alarm',
        name: 'edit-alarm',
        builder: (context, state) {
          final alarm = state.extra as Alarm;
          return EditAlarmScreen(alarm: alarm);
        },
      ),
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) => const CameraCaptureScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/day-detail',
        name: 'day-detail',
        builder: (context, state) {
          final date = state.extra as DateTime;
          return DayDetailScreen(date: date);
        },
      ),
    ],
  );
});
