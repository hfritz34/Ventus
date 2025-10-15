import 'package:hive/hive.dart';

class NotificationSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String soundType; // 'default', 'gentle', 'loud'

  NotificationSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.soundType = 'default',
  });

  NotificationSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? soundType,
  }) {
    return NotificationSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundType: soundType ?? this.soundType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'soundType': soundType,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      soundType: json['soundType'] as String? ?? 'default',
    );
  }
}

class NotificationSettingsService {
  static final NotificationSettingsService _instance =
      NotificationSettingsService._internal();
  factory NotificationSettingsService() => _instance;
  NotificationSettingsService._internal();

  static const String _boxName = 'settings';
  static const String _settingsKey = 'notification_settings';

  Future<NotificationSettings> getSettings() async {
    final box = await Hive.openBox(_boxName);
    final data = box.get(_settingsKey);

    if (data == null) {
      return NotificationSettings();
    }

    return NotificationSettings.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_settingsKey, settings.toJson());
  }
}
