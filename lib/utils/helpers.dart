import 'package:intl/intl.dart';

class Helpers {
  static String formatTo12Hour(String t) {
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      return '${h == 0 ? 12 : h > 12 ? h - 12 : h}:${p[1]} ${h >= 12 ? 'PM' : 'AM'}';
    } catch (_) { return t; }
  }

  static String formatDateWithJapaneseDay(String s, bool isJa) {
    try {
      final d = DateTime.parse(s);
      if (isJa) return '${d.year}年${d.month}月${d.day}日 (${['日','月','火','水','木','金','土'][d.weekday % 7]})';
      return DateFormat('EEE, MMM dd, yyyy').format(d);
    } catch (_) { return s; }
  }

  static String formatDateTimeRange(String s, String st, String et, bool isJa) {
    try {
      final d = DateTime.parse(s);
      final range = '${formatTo12Hour(st)}-${formatTo12Hour(et)}';
      if (isJa) return '${formatDateWithJapaneseDay(s, true)}  $range';
      return '${DateFormat('EEE MMM dd, yyyy').format(d)}  $range';
    } catch (_) { return '$s  $st-$et'; }
  }
}
