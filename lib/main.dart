import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/event_service.dart';
import 'services/location_management_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseService().initialize();
  await NotificationService().initialize();
  await initializeDateFormatting('ja_JP', null);
  await initializeDateFormatting('en_US', null);

  // Pre-warm: await the FIRST emission of each stream so caches are
  // guaranteed populated before any screen opens — even on fresh install.
  await Future.wait([
    EventService().getEvents().first,
    EventService().getAllEvents().first,
    LocationManagementService().getAllLocations().first,
  ]).timeout(
    const Duration(seconds: 8),
    onTimeout: () => [[], [], []], // proceed even if offline/slow
  );

  runApp(const EventifyApp());
}
