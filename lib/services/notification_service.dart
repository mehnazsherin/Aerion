import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  DateTime? _lastAlertTime;
  static const Duration _alertCooldown = Duration(minutes: 3);

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);
      _isInitialized = true;
    } catch (_) {
      // Graceful fallback if native platform doesn't have channels setup yet
    }
  }

  Future<void> showEnvironmentalAlert({
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    // Anti-spam cooldown check
    if (_lastAlertTime != null && now.difference(_lastAlertTime!) < _alertCooldown) {
      return;
    }
    _lastAlertTime = now;

    const androidDetails = AndroidNotificationDetails(
      'aerion_alerts_channel',
      'Aerion Air Alerts',
      channelDescription: 'Environmental threshold triggers for temperature and humidity',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: 1001,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (_) {}
  }
}
