import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/event_service.dart';
import '../providers/language_provider.dart';
import '../utils/app_text.dart';
import '../utils/helpers.dart';
import '../screens/user/event_details_screen.dart';

class EventCalendar extends StatefulWidget {
  final String?
      highlightedDate; // Date to highlight in pink (from "Add to Calendar")

  const EventCalendar({super.key, this.highlightedDate});

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _events = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // If a date is provided to highlight, set it as selected
    if (widget.highlightedDate != null) {
      try {
        final highlightDate = DateTime.parse(widget.highlightedDate!);
        _selectedDay = highlightDate;
        _focusedDay = highlightDate;
      } catch (_) {}
    }
  }

  DateTime get _lastEventDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 2, 0); // last day of next month
  }

  /// Get events for a specific calendar day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final twoMonthsLater = DateTime(now.year, now.month + 2, 1);

    return _events.where((event) {
      if (event['isHidden'] == true) return false;
      if (event['isDeleted'] == true) return false;
      try {
        final eventDate = DateTime.parse(event['date']);
        if (eventDate.isBefore(currentMonth) ||
            !eventDate.isBefore(twoMonthsLater)) {
          return false;
        }
        return isSameDay(eventDate, day);
      } catch (_) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: EventService().getEvents(),
      builder: (context, snapshot) {
        _events = snapshot.data ?? [];

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
              firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1),
              lastDay: _lastEventDate,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                final events = _getEventsForDay(selectedDay);
                if (events.isNotEmpty) {
                  _showEventsDialog(context, selectedDay, events);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No events on this day'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFE008B), Color(0xFFFF00FF)],
                  ),
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
      },
    );
  }

  void _showEventsDialog(
    BuildContext context,
    DateTime selectedDay,
    List<Map<String, dynamic>> events,
  ) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isJapanese = langProvider.currentLanguage == 'ja';

    final months = isJapanese
        ? [
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
          ]
        : [
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
          ];
    final month = months[selectedDay.month - 1];
    final dateStr = isJapanese
        ? '${selectedDay.year}年$month${selectedDay.day}日'
        : '${selectedDay.day} $month ${selectedDay.year}';

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
              final images = event['images_en'];
              final imgUrl = (images is List && images.isNotEmpty)
                  ? images[0] as String
                  : '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (() {
                    if (imgUrl.isEmpty) return null;
                    return imgUrl.startsWith('http')
                        ? NetworkImage(imgUrl) as ImageProvider
                        : AssetImage(imgUrl) as ImageProvider;
                  })(),
                  onBackgroundImageError: (_, __) {},
                  child: imgUrl.isEmpty ? const Icon(Icons.event) : null,
                ),
                title: Text(
                  event['title_en'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                    '${Helpers.formatTo12Hour(event['startTime'])} - ${Helpers.formatTo12Hour(event['endTime'])}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
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
