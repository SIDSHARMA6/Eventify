import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../config/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'device_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage m) async {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _firebase = FirebaseService();
  final _device = DeviceService();
  final _local = FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState>? navigatorKey;

  // FIX L-32: Cap simultaneous in-app overlays to prevent screen flooding
  final List<OverlayEntry> _activeOverlays = [];
  static const int _maxOverlays = 2;

  Future<void> initialize() async {
    const android =
        AndroidInitializationSettings('@drawable/notification_logo');
    const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    await _local
        .initialize(const InitializationSettings(android: android, iOS: ios));
    tz.initializeTimeZones();
    await _firebase.messaging.requestPermission();
    await _firebase.messaging.subscribeToTopic('all_users');
    final token = await _firebase.messaging.getToken();
    if (token != null) _saveToken(token);
    _firebase.messaging.onTokenRefresh.listen(_saveToken);
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
    FirebaseMessaging.onMessage.listen((m) {
      _showSys(m);
      _showInApp(m);
    });
  }

  // FIX D-10: Use DateTime.now() instead of FieldValue.serverTimestamp() to remove Firestore import
  Future<void> _saveToken(String t) async {
    final id = await _device.getDeviceId();
    await _firebase.fcmTokensCollection.doc(id).set({
      'deviceId': id,
      'token': t,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
            'high_importance_channel', 'High Importance',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/notification_logo',
            largeIcon:
                DrawableResourceAndroidBitmap('@drawable/notification_logo')),
        iOS: DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true),
      );

  Future<void> _showSys(RemoteMessage m) async {
    final n = m.notification;
    if (n != null) await _local.show(n.hashCode, n.title, n.body, _details());
  }

  void _showInApp(RemoteMessage m) {
    final n = m.notification;
    if (n == null || navigatorKey?.currentContext == null) return;
    final ctx = navigatorKey!.currentContext!;
    final overlay = Overlay.of(ctx);

    // FIX M-08/L-32: Remove oldest if at cap
    if (_activeOverlays.length >= _maxOverlays) {
      final oldest = _activeOverlays.removeAt(0);
      if (oldest.mounted) oldest.remove();
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
        builder: (c) => Positioned(
              top: MediaQuery.of(c).padding.top + 10,
              left: 10,
              right: 10,
              child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Theme.of(c).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ]),
                    child: Row(children: [
                      Image.asset(AppImages.logo, width: 32, height: 32),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Text(n.title ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            if (n.body != null)
                              Text(n.body!,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                          ])),
                    ]),
                  )),
            ));

    _activeOverlays.add(entry);
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
      _activeOverlays.remove(entry);
    });
  }

  Future<void> scheduleEventReminder(
      String title, DateTime date, String time) async {
    // FIX L-33: Guard against malformed time string (no colon)
    final parts = time.split(':');
    if (parts.length < 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return;

    final dt = DateTime(date.year, date.month, date.day, hour, minute);
    final scheduleTime = dt.subtract(const Duration(hours: 1));

    if (scheduleTime.isAfter(DateTime.now())) {
      await _local.zonedSchedule(
        dt.hashCode,
        'Event Reminder ⏰',
        'Starting in 1 hour: $title',
        tz.TZDateTime.from(scheduleTime, tz.local),
        _details(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> sendTicketConfirmation(
      {required String eventTitle, required String ticketId}) async {
    await _local.show(ticketId.hashCode, 'Ticket Booked! 🎟️',
        'Confirmed for $eventTitle. ID: $ticketId', _details());
  }

  String _sanitize(String text) {
    if (text.isEmpty) return '';
    final s = text.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
    return s.length > 255 ? '${s.substring(0, 252)}...' : s;
  }

  Future<void> sendNewEventNotification(String title, String body) async {
    final cleanTitle = _sanitize(title);
    final cleanBody = _sanitize(body);
    if (cleanTitle.isEmpty) return;
    await _local.show(cleanTitle.hashCode, cleanTitle, cleanBody, _details());
  }
}
