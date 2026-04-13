import 'package:intl/intl.dart';

class Helpers {
  // FIX-004/SX-07: Use intl DateFormat — handles all edge cases correctly
  static String formatTo12Hour(String t) {
    try {
      final parts = t.split(':');
      if (parts.length < 2) return t;
      final dt = DateFormat('HH:mm')
          .parse('${parts[0].padLeft(2, '0')}:${parts[1]}');
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return t;
    }
  }

  static String formatDateWithJapaneseDay(String s, bool isJa) {
    try {
      final d = DateTime.parse(s);
      if (isJa) {
        return '${d.year}年${d.month}月${d.day}日 (${['日', '月', '火', '水', '木', '金', '土'][d.weekday % 7]})';
      }
      return DateFormat('EEE, MMM dd, yyyy').format(d);
    } catch (_) {
      return s;
    }
  }

  static String formatDateTimeRange(String s, String st, String et, bool isJa) {
    try {
      final d = DateTime.parse(s);
      final range = '${formatTo12Hour(st)}-${formatTo12Hour(et)}';
      if (isJa) return '${formatDateWithJapaneseDay(s, true)}  $range';
      return '${DateFormat('EEE MMM dd, yyyy').format(d)}  $range';
    } catch (_) {
      return '$s  $st-$et';
    }
  }
}
