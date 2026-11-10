import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopNotificationService {
  DesktopNotificationService._();

  static const _enabledKey = 'desktop_notifications_enabled';
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  static Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    if (enabled && !isSupported) {
      throw UnsupportedError(
        'Notifikasi desktop hanya tersedia di Windows, macOS, dan Linux.',
      );
    }

    if (enabled) {
      await _initialize();
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: false, sound: true);
        if (granted != true) {
          throw StateError('Izin notifikasi macOS belum diberikan.');
        }
      }
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, enabled);
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!isSupported || !await isEnabled()) {
      throw StateError('Notifikasi desktop belum diizinkan.');
    }

    await _initialize();
    final details = switch (defaultTargetPlatform) {
      TargetPlatform.windows => const NotificationDetails(
        windows: WindowsNotificationDetails(),
      ),
      TargetPlatform.macOS => const NotificationDetails(
        macOS: DarwinNotificationDetails(),
      ),
      TargetPlatform.linux => const NotificationDetails(
        linux: LinuxNotificationDetails(
          urgency: LinuxNotificationUrgency.normal,
        ),
      ),
      _ => throw UnsupportedError('Platform desktop tidak didukung.'),
    };

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  static Future<void> _initialize() async {
    if (_initialized) return;

    final settings = switch (defaultTargetPlatform) {
      TargetPlatform.windows => const InitializationSettings(
        windows: WindowsInitializationSettings(
          appName: 'LokaTrip Admin',
          appUserModelId: 'LokaTrip.Admin',
          guid: '6a5a55f0-f793-4c54-a014-6e8f69a8fd32',
        ),
      ),
      TargetPlatform.macOS => const InitializationSettings(
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      TargetPlatform.linux => const InitializationSettings(
        linux: LinuxInitializationSettings(defaultActionName: 'Buka LokaTrip'),
      ),
      _ => throw UnsupportedError('Platform desktop tidak didukung.'),
    };

    final initialized = await _plugin.initialize(settings: settings);
    if (initialized != true) {
      throw StateError('Layanan notifikasi desktop gagal diinisialisasi.');
    }
    _initialized = true;
  }
}
