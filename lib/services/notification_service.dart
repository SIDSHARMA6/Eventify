import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'device_service.dart';

class NotificationService {
  final FirebaseService _firebase = FirebaseService();
  final DeviceService _device = DeviceService();

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission
      await _firebase.messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final token = await _firebase.messaging.getToken();
      if (token != null) {
        await saveFCMToken(token);
      }

      // Listen for token refresh
      _firebase.messaging.onTokenRefresh.listen(saveFCMToken);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    } catch (e) {
      print('Initialize FCM error: $e');
    }
  }

  // Save FCM token to Firestore
  Future<void> saveFCMToken(String token) async {
    try {
      final deviceId = await _device.getDeviceId();

      await _firebase.fcmTokensCollection.doc(deviceId).set({
        'deviceId': deviceId,
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Save FCM token error: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    // Show local notification or update UI
  }

  // Send new event notification to all users
  Future<void> sendNewEventNotification(String title, String body) async {
    try {
      // In production, this would be handled by Cloud Functions
      // For now, we'll just log it
      print('New event notification: $title - $body');
    } catch (e) {
      print('Send notification error: $e');
    }
  }

  // Delete FCM token on logout
  Future<void> deleteFCMToken() async {
    try {
      final deviceId = await _device.getDeviceId();
      await _firebase.fcmTokensCollection.doc(deviceId).delete();
    } catch (e) {
      print('Delete FCM token error: $e');
    }
  }
}

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}
