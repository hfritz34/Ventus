import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/services/notification_settings_service.dart';

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings()) {
    _loadSettings();
  }

  final _service = NotificationSettingsService();

  Future<void> _loadSettings() async {
    state = await _service.getSettings();
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _service.saveSettings(state);
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _service.saveSettings(state);
  }

  Future<void> setSoundType(String type) async {
    state = state.copyWith(soundType: type);
    await _service.saveSettings(state);
  }
}
