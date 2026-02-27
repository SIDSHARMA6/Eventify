import 'package:flutter/foundation.dart';

/// Provider to notify listeners when dummy data changes
/// This allows the UI to refresh when events are added/edited/deleted
class DemoDataProvider extends ChangeNotifier {
  /// Call this whenever DummyData.events is modified
  void notifyDataChanged() {
    notifyListeners();
  }
}
