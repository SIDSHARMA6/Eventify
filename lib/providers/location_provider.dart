import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String _selectedLocation = 'All';

  String get selectedLocation => _selectedLocation;

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }
}
