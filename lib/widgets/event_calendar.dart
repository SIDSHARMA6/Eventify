import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/event_service.dart';
import '../utils/app_text.dart';
import '../utils/helpers.dart';
import '../utils/language_helper.dart';
import '../screens/user/event_details_screen.dart';

class EventCalendar extends StatefulWidget {
  final String? highlightedDate;
  const EventCalendar({super.key, this.highlightedDate});

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.highlightedDate != null) {
      _selected =
          _focused = DateTime.tryParse(widget.highlightedDate!) ?? _focused;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: EventService().getEvents(),
      builder: (context, snap) {
        final allEvents = snap.data ?? [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppText.eventCalendar(context),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold))),
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focused,
            selectedDayPredicate: (d) => isSameDay(_selected, d),
            eventLoader: (d) => allEvents
                .where((e) =>
                    !e['isHidden'] &&
                    isSameDay(DateTime.tryParse(e['date']), d))
                .toList(),
            onDaySelected: (s, f) {
              setState(() {
                _selected = s;
                _focused = f;
              });
              final evs = allEvents
                  .where((e) =>
                      !e['isHidden'] &&
                      isSameDay(DateTime.tryParse(e['date']), s))
                  .toList();
              if (evs.isNotEmpty) _showEvs(context, s, evs);
            },
            calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFFE008B), Color(0xFFFF00FF)]),
                    shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                markerDecoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle)),
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
          ),
        ]);
      },
    );
  }

  void _showEvs(BuildContext ctx, DateTime d, List<Map<String, dynamic>> evs) {
    final isJa = LanguageHelper.isJapanese(ctx);
    showDialog(
        context: ctx,
        builder: (c) => AlertDialog(
              title: Text(isJa
                  ? '${d.year}年${d.month}月${d.day}日のイベント'
                  : 'Events on ${d.day}/${d.month}'),
              content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: evs.length,
                      itemBuilder: (cc, i) => ListTile(
                            leading: CircleAvatar(
                                backgroundImage:
                                    (evs[i]['images_en']?[0] != null)
                                        ? NetworkImage(evs[i]['images_en'][0])
                                        : null),
                            title: Text(
                                LanguageHelper.getEventTitle(evs[i], isJa)),
                            subtitle: Text(
                                '${Helpers.formatTo12Hour(evs[i]['startTime'])} - ${Helpers.formatTo12Hour(evs[i]['endTime'])}'),
                            onTap: () => Navigator.pushReplacement(
                                c,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailsScreen(event: evs[i]))),
                          ))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('Close'))
              ],
            ));
  }
}
