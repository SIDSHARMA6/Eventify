import 'package:flutter/material.dart';
import 'services/local_storage_service.dart';
import 'services/ticket_cleanup_service.dart';
import 'app.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();


  // Load data from SharedPreferences
  await LocalStorageService.initialize();

  // Cleanup expired tickets
  await TicketCleanupService.checkOnStartup();

  runApp(const EventifyApp());
}
