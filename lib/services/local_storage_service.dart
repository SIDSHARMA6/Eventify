import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dummy_data.dart';

/// Service to persist data locally using SharedPreferences
/// This ensures data persists across app restarts in demo mode
class LocalStorageService {
  static const String _eventsKey = 'demo_events';
  static const String _ticketsKey = 'demo_tickets';
  static const String _locationsKey = 'demo_locations';
  static const String _creatorsKey = 'demo_creators';
  static const String _bookedEventsKey =
      'booked_events'; // Track which events user booked

  /// Initialize and load data from SharedPreferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load events
    final eventsJson = prefs.getString(_eventsKey);
    if (eventsJson != null) {
      final List<dynamic> eventsList = jsonDecode(eventsJson);
      DummyData.events.clear();
      DummyData.events.addAll(
        eventsList.map((e) {
          final event = Map<String, dynamic>.from(e);
          // Ensure images are List<String>
          if (event['images_en'] is List) {
            event['images_en'] = (event['images_en'] as List)
                .map((img) => img.toString())
                .toList();
          }
          if (event['images_ja'] is List) {
            event['images_ja'] = (event['images_ja'] as List)
                .map((img) => img.toString())
                .toList();
          }
          return event;
        }).toList(),
      );
    }

    // Load tickets
    final ticketsJson = prefs.getString(_ticketsKey);
    if (ticketsJson != null) {
      final List<dynamic> ticketsList = jsonDecode(ticketsJson);
      DummyData.tickets.clear();
      DummyData.tickets.addAll(
        ticketsList.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    }

    // Load locations
    final locationsJson = prefs.getString(_locationsKey);
    if (locationsJson != null) {
      final List<dynamic> locationsList = jsonDecode(locationsJson);
      DummyData.locations.clear();
      DummyData.locations.addAll(
        locationsList.map((e) => Map<String, dynamic>.from(e)).toList(),
      );
    }
  }

  /// Save events to SharedPreferences
  static Future<void> saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = jsonEncode(DummyData.events);
    await prefs.setString(_eventsKey, eventsJson);
  }

  /// Save tickets to SharedPreferences
  static Future<void> saveTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsJson = jsonEncode(DummyData.tickets);
    await prefs.setString(_ticketsKey, ticketsJson);
  }

  /// Save locations to SharedPreferences
  static Future<void> saveLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final locationsJson = jsonEncode(DummyData.locations);
    await prefs.setString(_locationsKey, locationsJson);
  }

  /// Check if user has already booked a ticket for this event
  static Future<bool> hasBookedEvent(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookedEvents = prefs.getStringList(_bookedEventsKey) ?? [];
    return bookedEvents.contains(eventId);
  }

  /// Mark event as booked for this device
  static Future<void> markEventAsBooked(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookedEvents = prefs.getStringList(_bookedEventsKey) ?? [];
    if (!bookedEvents.contains(eventId)) {
      bookedEvents.add(eventId);
      await prefs.setStringList(_bookedEventsKey, bookedEvents);
    }
  }

  /// Remove event from booked list (when ticket is cancelled)
  static Future<void> unmarkEventAsBooked(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookedEvents = prefs.getStringList(_bookedEventsKey) ?? [];
    bookedEvents.remove(eventId);
    await prefs.setStringList(_bookedEventsKey, bookedEvents);
  }

  /// Get all booked event IDs for this device
  static Future<List<String>> getBookedEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookedEventsKey) ?? [];
  }

  /// Clear all data (for testing)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
    await prefs.remove(_ticketsKey);
    await prefs.remove(_locationsKey);
    await prefs.remove(_creatorsKey);
    await prefs.remove(_bookedEventsKey);
  }
}
