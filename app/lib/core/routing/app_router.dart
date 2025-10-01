import 'package:go_router/go_router.dart';
import 'package:app/features/alarm/screens/alarm_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const AlarmListScreen(),
    ),
  ],
);
