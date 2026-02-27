import '../data/dummy_data.dart';
import 'local_storage_service.dart';
import 'package:flutter/foundation.dart';

class TicketCleanupService {
  /// Remove tickets for events that have ended
  static Future<int> cleanupExpiredTickets() async {
    final now = DateTime.now();
    int removedCount = 0;

    // Create a map of events for O(1) lookup instead of O(n)
    final eventsMap = <String, Map<String, dynamic>>{};
    for (final event in DummyData.events) {
      eventsMap[event['id']] = event;
    }

    // Find tickets for events that have ended
    final ticketsToRemove = <Map<String, dynamic>>[];

    for (final ticket in DummyData.tickets) {
      final eventId = ticket['eventId'];
      final event = eventsMap[eventId];

      if (event != null) {
        try {
          final eventDate = DateTime.parse(event['date']);
          final endTimeParts = (event['endTime'] as String).split(':');
          final eventEndTime = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
          );

          // If event has ended, mark ticket for removal
          if (eventEndTime.isBefore(now)) {
            ticketsToRemove.add(ticket);
          }
        } catch (e) {
          // Skip if date parsing fails
          debugPrint('Failed to parse event date: $e');
        }
      }
    }

    // Remove expired tickets
    for (final ticket in ticketsToRemove) {
      DummyData.tickets.remove(ticket);
      removedCount++;
    }

    // Save to storage if any tickets were removed
    if (removedCount > 0) {
      await LocalStorageService.saveTickets();
    }

    return removedCount;
  }

  /// Check and cleanup on app start
  static Future<void> checkOnStartup() async {
    final removed = await cleanupExpiredTickets();
    if (removed > 0) {
      debugPrint('Cleaned up $removed expired tickets');
    }
  }
}
