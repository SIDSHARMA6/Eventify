import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  String? _cachedId;

  Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;
    final prefs = await SharedPreferences.getInstance();
    _cachedId = prefs.getString('device_id');
    if (_cachedId == null) {
      _cachedId = base64Url
          .encode(List<int>.generate(16, (_) => Random.secure().nextInt(256)))
          .substring(0, 22);
      await prefs.setString('device_id', _cachedId!);
    }
    return _cachedId!;
  }
}
