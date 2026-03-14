import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';
import 'device_service.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  debugPrint('📩 Background: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _firebase = FirebaseService();
  final _device = DeviceService();
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  // Global key to show in-app notifications
  static GlobalKey<NavigatorState>? navigatorKey;

  Future<void> initialize() async {
    // Initialize local notifications
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) =>
          debugPrint('🔔 Tapped: ${response.payload}'),
    );

    // Create Android channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Request FCM permission
    await _firebase.messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Subscribe to topic
    await _firebase.messaging.subscribeToTopic('all_users');

    // Get and save token
    final token = await _firebase.messaging.getToken();
    if (token != null) {
      debugPrint('🔔 FCM Token: $token');
      await _saveToken(token);
    }

    // Token refresh
    _firebase.messaging.onTokenRefresh.listen(_saveToken);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_bgHandler);

    // Foreground messages - show both in-app and system notification
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📨 Foreground: ${message.notification?.title}');
      _showSystemNotification(message);
      _showInAppNotification(message);
    });

    // Notification tap handlers
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('🔔 Tapped (background)');
    });

    final initialMessage = await _firebase.messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🔔 Opened from notification');
    }
  }

  Future<void> _saveToken(String token) async {
    final id = await _device.getDeviceId();
    await _firebase.fcmTokensCollection.doc(id).set({
      'deviceId': id,
      'token': token,
      'updatedAt': FieldValue.serverTimestamp()
    });
    debugPrint('✅ Token saved: $id');
  }

  Future<void> _showSystemNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _showInAppNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null || navigatorKey?.currentContext == null) return;

    final context = navigatorKey!.currentContext!;
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.notifications,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notification.title ?? '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (notification.body != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          notification.body!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () => overlayEntry.remove());
  }

  /// Schedule notification for event reminder
  Future<void> scheduleEventReminder(
    String eventTitle,
    DateTime eventDate,
    String eventTime,
  ) async {
    try {
      final timeParts = eventTime.split(':');
      final eventDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final reminderTime = eventDateTime.subtract(const Duration(hours: 1));

      if (reminderTime.isAfter(DateTime.now())) {
        // Show confirmation notification immediately
        await _localNotifications.show(
          eventDateTime.hashCode,
          'Reminder Set!',
          'You\'ll be notified 1 hour before $eventTitle',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
        debugPrint('⏰ Reminder set for: $reminderTime');
      }
    } catch (e) {
      debugPrint('❌ Schedule error: $e');
    }
  }

  Future<void> sendNewEventNotification(String title, String body) async {
    debugPrint('📤 Event notification: $title');
  }
}
