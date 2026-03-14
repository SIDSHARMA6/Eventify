import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = base64Url
          .encode(List<int>.generate(16, (_) => Random.secure().nextInt(256)))
          .substring(0, 22);
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }
}
