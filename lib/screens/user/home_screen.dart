import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/event_service.dart';
import '../../providers/language_provider.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/event_card.dart';
import '../../widgets/latest_bookings.dart';
import '../../widgets/event_calendar.dart';
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

  @override
  bool get wantKeepAlive => true;


  List<Map<String, dynamic>> _filterAndSort(List<Map<String, dynamic>> events) {
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
    final byLocation = _selectedLocation == 'All'
        ? visible
        : visible.where((e) => e['location_en'] == _selectedLocation).toList();

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>();

    return Scaffold(
      appBar: TopBar(
        selectedLocation: _selectedLocation,
        onLocationChanged: (loc) => setState(() => _selectedLocation = loc),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: EventService().getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = _filterAndSort(snapshot.data ?? []);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
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
              ),
            ),
          );
        },
      ),
    );
  }
}
