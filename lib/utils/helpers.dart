import 'package:intl/intl.dart';

class Helpers {
  // Cache for formatted dates to avoid repeated parsing
  static final Map<String, String> _dateWithDayCache = {};
  static final Map<String, String> _dateTimeRangeCache = {};

  /// Convert 24-hour time to 12-hour AM/PM format
  /// Example: "18:00" -> "6:00 PM", "09:30" -> "9:30 AM"
  static String formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour -= 12;
      }

      return '$hour:$minute $period';
    } catch (e) {
      return time24;
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
        const japaneseWeekdays = ['日', '月', '火', '水', '木', '金', '土'];
        final dayChar = japaneseWeekdays[date.weekday % 7];
        formatted = '${date.year}年${date.month}月${date.day}日 ($dayChar)';
      } else {
        formatted = DateFormat('EEE, MMM dd, yyyy').format(date);
      }

      _dateWithDayCache[cacheKey] = formatted;
      return formatted;
    } catch (e) {
      return dateString;
    }
  }

  /// Format date and time together: Sat Feb 28, 2026  6:00 PM-9:00 PM
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
      final start12 = formatTo12Hour(startTime);
      final end12 = formatTo12Hour(endTime);
      String formatted;

      if (isJapanese) {
        const japaneseWeekdays = ['日', '月', '火', '水', '木', '金', '土'];
        final dayChar = japaneseWeekdays[date.weekday % 7];
        formatted =
            '${date.year}年${date.month}月${date.day}日 ($dayChar)  $start12-$end12';
      } else {
        final formattedDate = DateFormat('EEE MMM dd, yyyy').format(date);
        formatted = '$formattedDate  $start12-$end12';
      }

      _dateTimeRangeCache[cacheKey] = formatted;
      return formatted;
    } catch (e) {
      return '$dateString  $startTime-$endTime';
    }
  }
}
