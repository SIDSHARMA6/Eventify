import 'package:intl/intl.dart';

class Helpers {
  // Cache for formatted dates to avoid repeated parsing
  static final Map<String, String> _dateCache = {};
  static final Map<String, String> _dateWithDayCache = {};
  static final Map<String, String> _dateTimeRangeCache = {};

  static String formatDate(String dateString) {
    if (_dateCache.containsKey(dateString)) {
      return _dateCache[dateString]!;
    }

    try {
      final date = DateTime.parse(dateString);
      final formatted = DateFormat('MMM dd, yyyy').format(date);
      _dateCache[dateString] = formatted;
      return formatted;
    } catch (e) {
      return dateString;
    }
  }

  /// Format date with Japanese day character (金、土、日, etc.)
  static String formatDateWithJapaneseDay(String dateString, bool isJapanese) {
    final cacheKey = '$dateString-$isJapanese';
    if (_dateWithDayCache.containsKey(cacheKey)) {
      return _dateWithDayCache[cacheKey]!;
    }

    try {
      final date = DateTime.parse(dateString);
      String formatted;

      if (isJapanese) {
        // Japanese day characters
        const japaneseWeekdays = ['日', '月', '火', '水', '木', '金', '土'];
        final dayChar = japaneseWeekdays[date.weekday % 7];

        // Format: 2026年2月28日 (金)
        formatted = '${date.year}年${date.month}月${date.day}日 ($dayChar)';
      } else {
        // English format with day name: Sat, Feb 28, 2026
        formatted = DateFormat('EEE, MMM dd, yyyy').format(date);
      }

      _dateWithDayCache[cacheKey] = formatted;
      return formatted;
    } catch (e) {
      return dateString;
    }
  }

  /// Format date and time together: Sat Feb 28, 2026 ・18:00-21:00
  static String formatDateTimeRange(
    String dateString,
    String startTime,
    String endTime,
    bool isJapanese,
  ) {
    final cacheKey = '$dateString-$startTime-$endTime-$isJapanese';
    if (_dateTimeRangeCache.containsKey(cacheKey)) {
      return _dateTimeRangeCache[cacheKey]!;
    }

    try {
      final date = DateTime.parse(dateString);
      String formatted;

      if (isJapanese) {
        const japaneseWeekdays = ['日', '月', '火', '水', '木', '金', '土'];
        final dayChar = japaneseWeekdays[date.weekday % 7];
        formatted =
            '${date.year}年${date.month}月${date.day}日 ($dayChar) ・$startTime-$endTime';
      } else {
        // Format: Sat Feb 28, 2026 ・18:00-21:00
        final formattedDate = DateFormat('EEE MMM dd, yyyy').format(date);
        formatted = '$formattedDate ・$startTime-$endTime';
      }

      _dateTimeRangeCache[cacheKey] = formatted;
      return formatted;
    } catch (e) {
      return '$dateString ・$startTime-$endTime';
    }
  }

  static String formatTime(String timeString) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return timeString;
    }
  }

  static String formatPrice(int price, String currency) {
    if (price == 0) return 'Free';
    return '$currency$price';
  }

  // Clear cache if needed (e.g., on language change)
  static void clearCache() {
    _dateCache.clear();
    _dateWithDayCache.clear();
    _dateTimeRangeCache.clear();
  }
}
