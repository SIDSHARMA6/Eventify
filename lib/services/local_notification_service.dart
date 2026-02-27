import 'package:flutter/material.dart';

/// Local Notification Service for Event Reminders
///
/// NOTE: This is a demo implementation showing the structure.
/// In production, install flutter_local_notifications package and implement:
/// 1. Initialize notification plugin
/// 2. Request permissions
/// 3. Schedule notifications using timezone package
/// 4. Handle notification taps
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() => _instance;

  LocalNotificationService._internal();

  /// Initialize local notifications
  ///
  /// Production implementation:
  /// ```dart
  /// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  ///     FlutterLocalNotificationsPlugin();
  ///
  /// const AndroidInitializationSettings initializationSettingsAndroid =
  ///     AndroidInitializationSettings('@mipmap/ic_launcher');
  ///
  /// const DarwinInitializationSettings initializationSettingsIOS =
  ///     DarwinInitializationSettings();
  ///
  /// const InitializationSettings initializationSettings =
  ///     InitializationSettings(
  ///   android: initializationSettingsAndroid,
  ///   iOS: initializationSettingsIOS,
  /// );
  ///
  /// await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  /// ```
  Future<void> initialize() async {
    debugPrint('📱 Local Notification Service: Initialized (Demo Mode)');
    // In production: Initialize flutter_local_notifications plugin
  }

  /// Schedule reminder notifications for an event
  ///
  /// Schedules two notifications:
  /// 1. One day before the event
  /// 2. Three hours before the event
  Future<void> scheduleEventReminders({
    required String eventId,
    required String eventTitle,
    required DateTime eventDateTime,
  }) async {
    // Calculate notification times
    final oneDayBefore = eventDateTime.subtract(const Duration(days: 1));
    final threeHoursBefore = eventDateTime.subtract(const Duration(hours: 3));

    final now = DateTime.now();

    // Schedule 1 day before notification
    if (oneDayBefore.isAfter(now)) {
      await _scheduleNotification(
        id: '${eventId}_1day'.hashCode,
        title: 'Event Tomorrow! 📅',
        body: '$eventTitle starts tomorrow at ${_formatTime(eventDateTime)}',
        scheduledDate: oneDayBefore,
      );
    }

    // Schedule 3 hours before notification
    if (threeHoursBefore.isAfter(now)) {
      await _scheduleNotification(
        id: '${eventId}_3hours'.hashCode,
        title: 'Event Starting Soon! ⏰',
        body: '$eventTitle starts in 3 hours',
        scheduledDate: threeHoursBefore,
      );
    }

    debugPrint('📅 Scheduled reminders for: $eventTitle');
    debugPrint('   - 1 day before: $oneDayBefore');
    debugPrint('   - 3 hours before: $threeHoursBefore');
  }

  /// Schedule a single notification
  ///
  /// Production implementation:
  /// ```dart
  /// await flutterLocalNotificationsPlugin.zonedSchedule(
  ///   id,
  ///   title,
  ///   body,
  ///   tz.TZDateTime.from(scheduledDate, tz.local),
  ///   const NotificationDetails(
  ///     android: AndroidNotificationDetails(
  ///       'event_reminders',
  ///       'Event Reminders',
  ///       channelDescription: 'Reminders for upcoming events',
  ///       importance: Importance.high,
  ///       priority: Priority.high,
  ///     ),
  ///     iOS: DarwinNotificationDetails(),
  ///   ),
  ///   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  ///   uiLocalNotificationDateInterpretation:
  ///       UILocalNotificationDateInterpretation.absoluteTime,
  /// );
  /// ```
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    debugPrint('🔔 Notification scheduled:');
    debugPrint('   ID: $id');
    debugPrint('   Title: $title');
    debugPrint('   Body: $body');
    debugPrint('   Time: $scheduledDate');

    // In production: Use flutter_local_notifications to schedule
  }

  /// Cancel all reminders for an event (when ticket is cancelled)
  Future<void> cancelEventReminders(String eventId) async {
    debugPrint('🔕 Cancelled reminders for event: $eventId');
    debugPrint('   - 1 day notification ID: ${'${eventId}_1day'.hashCode}');
    debugPrint('   - 3 hours notification ID: ${'${eventId}_3hours'.hashCode}');

    // Production implementation:
    // final oneDayId = '${eventId}_1day'.hashCode;
    // final threeHoursId = '${eventId}_3hours'.hashCode;
    // await flutterLocalNotificationsPlugin.cancel(oneDayId);
    // await flutterLocalNotificationsPlugin.cancel(threeHoursId);
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    debugPrint('🔕 Cancelled all notifications');

    // Production implementation:
    // await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('🔔 Immediate notification:');
    debugPrint('   Title: $title');
    debugPrint('   Body: $body');

    // Production implementation:
    // await flutterLocalNotificationsPlugin.show(
    //   DateTime.now().millisecondsSinceEpoch.remainder(100000),
    //   title,
    //   body,
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'event_reminders',
    //       'Event Reminders',
    //       channelDescription: 'Reminders for upcoming events',
    //       importance: Importance.high,
    //       priority: Priority.high,
    //     ),
    //     iOS: DarwinNotificationDetails(),
    //   ),
    // );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

/// Production Setup Instructions:
/// 
/// 1. Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   flutter_local_notifications: ^17.0.0
///   timezone: ^0.9.2
/// ```
/// 
/// 2. Android Setup (android/app/src/main/AndroidManifest.xml):
/// ```xml
/// <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
/// <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
/// <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
/// ```
/// 
/// 3. iOS Setup (ios/Runner/AppDelegate.swift):
/// ```swift
/// if #available(iOS 10.0, *) {
///   UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
/// }
/// ```
/// 
/// 4. Initialize in main.dart:
/// ```dart
/// await LocalNotificationService().initialize();
/// ```
/// 
/// 5. Call when booking ticket:
/// ```dart
/// await LocalNotificationService().scheduleEventReminders(
///   eventId: event['id'],
///   eventTitle: event['title_en'],
///   eventDateTime: DateTime.parse('${event['date']} ${event['startTime']}'),
/// );
/// ```
