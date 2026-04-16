import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  static Future<void> scheduleSessionReminder({
    required String sessionId,
    required String courseCode,
    required String room,
    required DateTime sessionDateTime,
  }) async {
    final reminderTime = DateTime.now().add(const Duration(hours: 1));

    if (reminderTime.isBefore(DateTime.now())) {
      print('Reminder time is in the past, skipping: $courseCode');
      return;
    }

    await _notifications.zonedSchedule(
      sessionId.hashCode.abs(),
      '📚 Session Starting Soon!',
      '$courseCode starts in 1 hour • Room $room',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'session_reminders',
          'Session Reminders',
          channelDescription: 'Reminds you 1 hour before a session starts',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: sessionId,
    );

    print('Reminder scheduled for $courseCode at $reminderTime');
  }

  static Future<void> cancelSessionReminder(String sessionId) async {
    await _notifications.cancel(sessionId.hashCode.abs());
    print('Reminder cancelled for session: $sessionId');
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    print('All reminders cancelled');
  }
}