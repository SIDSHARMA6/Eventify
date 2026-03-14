class RateLimiter {
  static final RateLimiter _instance = RateLimiter._internal();
  factory RateLimiter() => _instance;
  RateLimiter._internal();

  final Map<String, List<DateTime>> _history = {};

  bool isAllowed(String deviceId, String actionType) {
    final key = '${deviceId}_$actionType';
    final now = DateTime.now();
    _history[key] = (_history[key] ?? [])
      ..removeWhere(
          (t) => t.isBefore(now.subtract(const Duration(minutes: 1))));

    if (_history[key]!.length >= 5) return false;
    _history[key]!.add(now);
    return true;
  }
}
