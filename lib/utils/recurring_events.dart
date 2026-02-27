import '../data/dummy_data.dart';

class RecurringEvents {
  /// Generate recurring events for the next N months
  /// Pattern: First Saturday of every month
  static List<Map<String, dynamic>> generateMonthlyRecurring({
    required Map<String, dynamic> baseEvent,
    required int monthsAhead,
    required String dayOfWeek, // 'Monday', 'Tuesday', etc.
    required int weekOfMonth, // 1 = first, 2 = second, etc.
  }) {
    final generatedEvents = <Map<String, dynamic>>[];
    final baseDate = DateTime.parse(baseEvent['date']);

    for (int i = 1; i <= monthsAhead; i++) {
      final targetMonth = DateTime(
        baseDate.year,
        baseDate.month + i,
        1,
      );

      final eventDate = _findNthWeekdayOfMonth(
        targetMonth.year,
        targetMonth.month,
        dayOfWeek,
        weekOfMonth,
      );

      if (eventDate != null) {
        final newEvent = Map<String, dynamic>.from(baseEvent);
        newEvent['id'] =
            'EVENT-REC-${DateTime.now().millisecondsSinceEpoch}-$i';
        newEvent['date'] = eventDate.toIso8601String().split('T')[0];
        newEvent['maleBooked'] = 0;
        newEvent['femaleBooked'] = 0;
        newEvent['isRecurring'] = true;
        newEvent['recurringParentId'] = baseEvent['id'];

        generatedEvents.add(newEvent);
      }
    }

    return generatedEvents;
  }

  /// Find the Nth occurrence of a weekday in a month
  /// Example: Find the 1st Saturday of March 2026
  static DateTime? _findNthWeekdayOfMonth(
    int year,
    int month,
    String dayOfWeek,
    int weekOfMonth,
  ) {
    final weekdayMap = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    final targetWeekday = weekdayMap[dayOfWeek];
    if (targetWeekday == null) return null;

    // Start from the first day of the month
    var date = DateTime(year, month, 1);
    var count = 0;

    // Find all occurrences of the target weekday in the month
    while (date.month == month) {
      if (date.weekday == targetWeekday) {
        count++;
        if (count == weekOfMonth) {
          return date;
        }
      }
      date = date.add(const Duration(days: 1));
    }

    return null;
  }

  /// Create recurring events and add them to DummyData
  static void createRecurringEvents({
    required Map<String, dynamic> baseEvent,
    required int monthsAhead,
    required String dayOfWeek,
    required int weekOfMonth,
  }) {
    final events = generateMonthlyRecurring(
      baseEvent: baseEvent,
      monthsAhead: monthsAhead,
      dayOfWeek: dayOfWeek,
      weekOfMonth: weekOfMonth,
    );

    DummyData.events.addAll(events);
  }
}
