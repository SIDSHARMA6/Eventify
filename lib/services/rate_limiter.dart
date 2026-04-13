import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent rate limiter — survives app restarts.
/// Stores timestamps in SharedPreferences keyed by deviceId + action.
class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();

  static const _windowMs = 60000; // 1 minute
  static const _maxAttempts = 5;

  Future<bool> isAllowed(String deviceId, String action) async {
    final key = 'rl_${deviceId}_$action';
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    final now = DateTime.now().millisecondsSinceEpoch;

    List<int> timestamps = [];
    if (raw != null) {
      try {
        timestamps = List<int>.from(jsonDecode(raw) as List);
      } catch (_) {}
    }

    // Remove entries older than window
    timestamps = timestamps.where((t) => now - t < _windowMs).toList();

    if (timestamps.length >= _maxAttempts) return false;

    timestamps.add(now);
    await prefs.setString(key, jsonEncode(timestamps));
    return true;
  }
}
