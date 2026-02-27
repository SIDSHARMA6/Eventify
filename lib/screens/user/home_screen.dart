import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/dummy_data.dart';
import '../../providers/demo_data_provider.dart';
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

  List<Map<String, dynamic>> get _filteredEvents {
    // Get current date
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final twoMonthsLater = DateTime(now.year, now.month + 2, 1);

    // Filter out hidden and deleted events, and events outside this month and next month
    final visibleEvents = DummyData.events.where((event) {
      // Skip hidden events
      if (event['isHidden'] == true) return false;

      // Skip deleted events
      if (event['isDeleted'] == true) return false;

      // Parse event date
      try {
        final eventDate = DateTime.parse(event['date']);

        // Only show events from this month and next month
        // Event must be >= start of current month AND < start of month after next
        if (eventDate.isBefore(currentMonth) ||
            eventDate.isAfter(twoMonthsLater) ||
            eventDate.isAtSameMomentAs(twoMonthsLater)) {
          return false;
        }
      } catch (e) {
        // If date parsing fails, exclude the event
        return false;
      }

      return true;
    }).toList();

    // Apply location filter
    List<Map<String, dynamic>> filteredByLocation;
    if (_selectedLocation == 'All') {
      filteredByLocation = visibleEvents;
    } else {
      filteredByLocation = visibleEvents.where((event) {
        return event['location_en'] == _selectedLocation;
      }).toList();
    }

    // Sort by date (nearest first)
    filteredByLocation.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateA.compareTo(dateB); // Ascending order (nearest first)
      } catch (e) {
        return 0;
      }
    });

    return filteredByLocation;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Listen to demo data and language changes
    context.watch<DemoDataProvider>();
    context.watch<LanguageProvider>();

    return Scaffold(
      appBar: TopBar(
        selectedLocation: _selectedLocation,
        onLocationChanged: (location) {
          setState(() {
            _selectedLocation = location;
          });
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discover Events Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.discoverEvents(context),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppText.eventsCount(context, _filteredEvents.length),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),

            // Event Cards
            ..._filteredEvents.map((event) {
              return EventCard(
                event: event,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(event: event),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 24),

            // Latest Bookings
            const LatestBookings(),

            const SizedBox(height: 24),

            // Event Calendar
            const EventCalendar(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
