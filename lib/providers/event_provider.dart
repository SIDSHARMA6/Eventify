import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../data/dummy_data.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = false;
  String _selectedLocation = 'All';
  bool _useFirebase = false; // Toggle between dummy data and Firebase

  List<Map<String, dynamic>> get events => _events;
  bool get isLoading => _isLoading;
  String get selectedLocation => _selectedLocation;
  bool get useFirebase => _useFirebase;

  EventProvider() {
    loadEvents();
  }

  // Toggle between Firebase and dummy data
  void toggleFirebase(bool value) {
    _useFirebase = value;
    loadEvents();
  }

  // Load events
  void loadEvents() {
    _isLoading = true;
    notifyListeners();

    if (_useFirebase) {
      // Load from Firebase
      if (_selectedLocation == 'All') {
        _eventService.getEvents().listen((events) {
          _events = events;
          _isLoading = false;
          notifyListeners();
        });
      } else {
        _eventService.getEventsByLocation(_selectedLocation).listen((events) {
          _events = events;
          _isLoading = false;
          notifyListeners();
        });
      }
    } else {
      // Load from dummy data
      if (_selectedLocation == 'All') {
        _events = DummyData.events;
      } else {
        _events = DummyData.events
            .where((event) => event['location_en'] == _selectedLocation)
            .toList();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set location filter
  void setLocation(String location) {
    _selectedLocation = location;
    loadEvents();
  }

  // Get events by location
  List<Map<String, dynamic>> getEventsByLocation(String location) {
    if (location == 'All') return _events;
    return _events.where((event) => event['location_en'] == location).toList();
  }

  // Create event (Firebase only)
  Future<String?> createEvent(Map<String, dynamic> eventData) async {
    try {
      final eventId = await _eventService.createEvent(eventData);
      loadEvents(); // Reload events
      return eventId;
    } catch (e) {
      debugPrint('Create event error: $e');
      rethrow;
    }
  }

  // Update event (Firebase only)
  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      await _eventService.updateEvent(eventId, updates);
      loadEvents(); // Reload events
    } catch (e) {
      debugPrint('Update event error: $e');
      rethrow;
    }
  }

  // Delete event (Firebase only)
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
      loadEvents(); // Reload events
    } catch (e) {
      debugPrint('Delete event error: $e');
      rethrow;
    }
  }

  // Toggle event visibility (Firebase only)
  Future<void> toggleEventVisibility(String eventId, bool isHidden) async {
    try {
      await _eventService.toggleEventVisibility(eventId, isHidden);
      loadEvents(); // Reload events
    } catch (e) {
      debugPrint('Toggle visibility error: $e');
      rethrow;
    }
  }
}
