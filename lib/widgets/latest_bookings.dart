import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/dummy_data.dart';
import '../providers/demo_data_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_text.dart';

class LatestBookings extends StatefulWidget {
  const LatestBookings({super.key});

  @override
  State<LatestBookings> createState() => _LatestBookingsState();
}

class _LatestBookingsState extends State<LatestBookings>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<DemoDataProvider>(); // rebuild after new bookings
    context.watch<LanguageProvider>(); // rebuild on language change

    // Get last 3 bookings sorted by timestamp (newest first) - exclude deleted tickets
    final allTickets = List<Map<String, dynamic>>.from(
        DummyData.tickets.where((ticket) => ticket['isDeleted'] != true));
    allTickets.sort((a, b) {
      try {
        return DateTime.parse(b['timestamp'])
            .compareTo(DateTime.parse(a['timestamp']));
      } catch (_) {
        return 0;
      }
    });
    final latestBookings = allTickets.take(3).toList();

    if (latestBookings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppText.latestBookings(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        ...latestBookings.map((booking) {
          final timestamp = (() {
            try {
              return DateTime.parse(booking['timestamp']);
            } catch (_) {
              return DateTime.now();
            }
          })();

          // Format date and time
          final dateFormat = DateFormat('d MMM yyyy');
          final timeFormat = DateFormat('h:mm a');
          final dateStr = dateFormat.format(timestamp);
          final timeStr = timeFormat.format(timestamp);

          // Check if booking is within last 5 minutes (NEW badge)
          final isNew = DateTime.now().difference(timestamp).inMinutes < 5;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.confirmation_number,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['eventTitle_en'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateStr at $timeStr',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
