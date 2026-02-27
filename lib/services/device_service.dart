import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class DeviceService {
  static const String _deviceIdKey = 'device_id';

  // Get or create device ID
  Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);

      if (deviceId == null) {
        // Generate new device ID
        deviceId = _generateDeviceId();
        await prefs.setString(_deviceIdKey, deviceId);
      }

      return deviceId;
    } catch (e) {
      print('Get device ID error: $e');
      return _generateDeviceId();
    }
  }

  // Generate random device ID
  String _generateDeviceId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      16,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // Clear device ID (for testing)
  Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
    } catch (e) {
      print('Clear device ID error: $e');
    }
  }
}
