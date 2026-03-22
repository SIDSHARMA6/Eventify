import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_service.dart';
import 'device_service.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage m) async =>
    debugPrint('📩 BG: ${m.notification?.title}');

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _firebase = FirebaseService();
  final _device = DeviceService();
  final _local = FlutterLocalNotificationsPlugin();
  static GlobalKey<NavigatorState>? navigatorKey;

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    await _local
        .initialize(const InitializationSettings(android: android, iOS: ios));
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

  Future<void> _saveToken(String t) async {
    final id = await _device.getDeviceId();
    await _firebase.fcmTokensCollection.doc(id).set({
      'deviceId': id,
      'token': t,
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
            'high_importance_channel', 'High Importance',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon'),
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
    final entry = OverlayEntry(
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
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ]),
                    child: Row(children: [
                      Icon(Icons.notifications,
                          color: Theme.of(c).primaryColor),
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
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), () => entry.remove());
  }

  Future<void> scheduleEventReminder(
      String title, DateTime date, String time) async {
    final parts = time.split(':');
    final dt = DateTime(date.year, date.month, date.day, int.parse(parts[0]),
        int.parse(parts[1]));
    if (dt.subtract(const Duration(hours: 1)).isAfter(DateTime.now())) {
      await _local.show(
          dt.hashCode, 'Reminder Set!', '1 hour before $title', _details());
    }
  }

  Future<void> sendTicketConfirmation(
      {required String eventTitle, required String ticketId}) async {
    await _local.show(ticketId.hashCode, 'Ticket Booked! 🎟️',
        'Confirmed for $eventTitle. ID: $ticketId', _details());
  }

  Future<void> sendNewEventNotification(String title, String body) async {
    await _local.show(title.hashCode, title, body, _details());
  }
}
