import 'package:go_router/go_router.dart';
import 'package:app/features/alarm/screens/alarm_list_screen.dart';
import 'package:app/features/alarm/screens/add_alarm_screen.dart';
import 'package:app/features/alarm/screens/edit_alarm_screen.dart';
import 'package:app/features/alarm/models/alarm.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
  ],
);
