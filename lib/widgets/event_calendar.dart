import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/dummy_data.dart';
import '../providers/demo_data_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_text.dart';
import '../screens/user/event_details_screen.dart';

class EventCalendar extends StatefulWidget {
  const EventCalendar({super.key});

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime _lastEventDate;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _calculateLastEventDate();
  }

  void _calculateLastEventDate() {
    final now = DateTime.now();
    // Set last date to end of next month
    _lastEventDate =
        DateTime(now.year, now.month + 2, 0); // Last day of next month

    // No need to check all events since we're limiting to 2 months
  }

  // Get events for a specific day (only from this month and next month)
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final twoMonthsLater = DateTime(now.year, now.month + 2, 1);

    return DummyData.events.where((event) {
      // Skip hidden events
      if (event['isHidden'] == true) return false;

      try {
        final eventDate = DateTime.parse(event['date']);

        // Only show events from this month and next month
        if (eventDate.isBefore(currentMonth) ||
            eventDate.isAfter(twoMonthsLater) ||
            eventDate.isAtSameMomentAs(twoMonthsLater)) {
          return false;
        }

        return isSameDay(eventDate, day);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<DemoDataProvider>(); // rebuild when events change
    context.watch<LanguageProvider>(); // rebuild on language change
    _calculateLastEventDate(); // recalc whenever events change

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            AppText.eventCalendar(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        TableCalendar(
          firstDay: DateTime(DateTime.now().year, DateTime.now().month,
              1), // Start of current month
          lastDay: _lastEventDate, // End of next month
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            // Show events for selected day and navigate to first event
            final events = _getEventsForDay(selectedDay);
            if (events.isNotEmpty) {
              // Show dialog with events for this day
              _showEventsDialog(context, selectedDay, events);
            } else {
              final languageProvider =
                  Provider.of<LanguageProvider>(context, listen: false);
              final isEnglish = languageProvider.currentLanguage == 'en';
              final months = isEnglish
                  ? [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ]
                  : [
                      '1月',
                      '2月',
                      '3月',
                      '4月',
                      '5月',
                      '6月',
                      '7月',
                      '8月',
                      '9月',
                      '10月',
                      '11月',
                      '12月'
                    ];
              final month = months[selectedDay.month - 1];
              final dateStr = isEnglish
                  ? '${selectedDay.day} $month ${selectedDay.year}'
                  : '${selectedDay.year}年$month${selectedDay.day}日';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No events on $dateStr'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).textTheme.titleMedium!,
          ),
        ),
      ],
    );
  }

  void _showEventsDialog(
    BuildContext context,
    DateTime selectedDay,
    List<Map<String, dynamic>> events,
  ) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isEnglish = languageProvider.currentLanguage == 'en';
    final months = isEnglish
        ? [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ]
        : [
            '1月',
            '2月',
            '3月',
            '4月',
            '5月',
            '6月',
            '7月',
            '8月',
            '9月',
            '10月',
            '11月',
            '12月'
          ];
    final month = months[selectedDay.month - 1];
    final dateStr = isEnglish
        ? '${selectedDay.day} $month ${selectedDay.year}'
        : '${selectedDay.year}年$month${selectedDay.day}日';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Events on $dateStr'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(event['images_en'][0]),
                  onBackgroundImageError: (_, __) {},
                ),
                title: Text(
                  event['title_en'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${event['startTime']} - ${event['endTime']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(event: event),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
