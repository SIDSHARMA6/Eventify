import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/event_card.dart';
import '../../widgets/latest_bookings.dart';
import '../../widgets/event_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String _selectedLocation = 'All';
  List<Map<String, dynamic>> _cachedEvents = [];
  List<Map<String, dynamic>>? _lastRawData;
  late final Stream<List<Map<String, dynamic>>> _eventsStream;

  String? _lastLanguage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _eventsStream = EventService().getEvents();
  }

  List<Map<String, dynamic>> _filterAndSort(List<Map<String, dynamic>> events, String currentLanguage) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final twoMonthsLater = DateTime(now.year, now.month + 2, 1);

    // Filter: visible, non-deleted, within this + next month
    final visible = events.where((event) {
      if (event['isHidden'] == true) return false;
      try {
        final d = DateTime.parse(event['date']);
        return !d.isBefore(currentMonth) && d.isBefore(twoMonthsLater);
      } catch (_) {
        return false;
      }
    }).toList();

    // Filter by location
    final byLocation = _selectedLocation.trim().toLowerCase() == 'all'
        ? visible
        : visible.where((e) {
            final venueEn = (e['venueName_en'] ?? e['venueName'] as String? ?? '').trim().toLowerCase();
            final locationEn = (e['location_en'] as String? ?? '').trim().toLowerCase();
            final filter = _selectedLocation.trim().toLowerCase();
            return venueEn == filter || locationEn == filter;
          }).toList();

    // Sort by date ascending (nearest first)
    byLocation.sort((a, b) {
      try {
        return DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
      } catch (_) {
        return 0;
      }
    });

    return byLocation;
  }

  List<Map<String, dynamic>> _getEvents(List<Map<String, dynamic>> raw, String currentLanguage) {
    // Only recompute when raw data or location filter or language actually changes
    if (identical(raw, _lastRawData) && 
        _cachedEvents.isNotEmpty && 
        _lastLanguage == currentLanguage) {
      return _cachedEvents;
    }
    _lastRawData = raw;
    _lastLanguage = currentLanguage;
    _cachedEvents = _filterAndSort(raw, currentLanguage);
    return _cachedEvents;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentLanguage = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      appBar: TopBar(
        selectedLocation: _selectedLocation,
        onLocationChanged: (loc) => setState(() {
          _selectedLocation = loc;
          _lastRawData = null; // invalidate cache so filter reruns
        }),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = _getEvents(snapshot.data ?? [], currentLanguage);

          return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.discoverEvents(context),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppText.eventsCount(context, events.length),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Event Cards
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 32),
                      child: Center(
                        child: Text(
                          AppText.noEventsYet(context),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...events.map((event) => EventCard(
                          key: ValueKey('${event['id']}_$currentLanguage'),
                          event: event,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailsScreen(event: event),
                              ),
                            );
                          },
                        )),

                  const SizedBox(height: 24),
                  const LatestBookings(),
                  const SizedBox(height: 24),
                  const EventCalendar(),
                  const SizedBox(height: 24),
                ],
              ));
        },
      ),
    );
  }
}
