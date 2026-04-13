import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/event_service.dart';
import '../utils/app_text.dart';
import '../utils/helpers.dart';
import '../utils/language_helper.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../screens/user/event_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

class EventCalendar extends StatefulWidget {
  final String? highlightedDate;
  const EventCalendar({super.key, this.highlightedDate});

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  Set<String> _addedEventIds = {};
  late final Stream<List<Map<String, dynamic>>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _eventsStream = EventService().getEvents();
    // Defer SharedPreferences read to after first frame to avoid jank
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAddedEvents());
    if (widget.highlightedDate != null) {
      _selected =
          _focused = DateTime.tryParse(widget.highlightedDate!) ?? _focused;
    }
  }

  bool _isEventOnDay(Map<String, dynamic> e, DateTime day) {
    try {
      final ds = e['date'] as String? ?? '';
      if (ds.isEmpty) return false;
      final parsed = DateTime.tryParse(ds);
      return parsed != null && isSameDay(parsed, day);
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadAddedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cal_added_'));
    setState(() {
      _addedEventIds = keys
          .where((k) => prefs.getBool(k) == true)
          .map((k) => k.replaceFirst('cal_added_', ''))
          .toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _eventsStream,
      builder: (context, snap) {
        final isJa = context.watch<LanguageProvider>().currentLanguage == 'ja';
        final now = DateTime.now();
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 2, 0);
        final allEvents = snap.data ?? [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppText.eventCalendar(context),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold))),
          TableCalendar(
            locale: isJa ? 'ja_JP' : 'en_US',
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: _focused.isBefore(firstDay)
                ? firstDay
                : (_focused.isAfter(lastDay) ? lastDay : _focused),
            selectedDayPredicate: (d) => isSameDay(_selected, d),
            eventLoader: (d) => allEvents
                .where((e) => e['isHidden'] != true && _isEventOnDay(e, d))
                .toList(),
            onDaySelected: (s, f) {
              setState(() {
                _selected = s;
                _focused = f;
              });
              final evs = allEvents
                  .where((e) => e['isHidden'] != true && _isEventOnDay(e, s))
                  .toList();

              if (evs.isNotEmpty) _showEvs(context, s, evs);
            },
            calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppTheme.primaryPink, AppTheme.primaryMagenta]),
                    shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                markerDecoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle)),
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                final list = events as List<Map<String, dynamic>>;
                final hasAdded =
                    list.any((e) => _addedEventIds.contains(e['id']));
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: hasAdded ? AppTheme.primaryPink : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
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
                                backgroundImage: (LanguageHelper.getImages(
                                            evs[i], isJa)
                                        .isNotEmpty)
                                    ? NetworkImage(
                                        LanguageHelper.getImages(evs[i], isJa)
                                            .first)
                                    : null),
                            title: Text(
                                LanguageHelper.getEventTitle(evs[i], isJa)),
                            subtitle: Text(
                                '${Helpers.formatTo12Hour(evs[i]['startTime'])} - ${Helpers.formatTo12Hour(evs[i]['endTime'])}'),
                            onTap: () {
                              Navigator.pop(c);
                              Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailsScreen(event: evs[i]),
                                ),
                              ).then((_) => _loadAddedEvents());
                            },
                          ))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(AppText.close(ctx)))
              ],
            ));
  }
}
