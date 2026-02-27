import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/demo_data_provider.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../config/theme.dart';
import '../../widgets/gradient_app_bar.dart';
import 'manage_events_screen.dart';
import 'manage_creators_screen.dart';
import 'manage_locations_screen.dart';
import 'qr_scanner_screen.dart';
import '../creator/create_event_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // rebuild when language changes
    context.watch<DemoDataProvider>(); // rebuild when events/tickets change
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppText.logout(context)),
            content: Text(AppText.confirmLogout(context)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppText.no(context)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppText.yes(context)),
              ),
            ],
          ),
        );

        if (shouldLogout == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: GradientAppBar(
          title: Text(
            AppText.adminDashboard(context),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Analytics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    AppText.totalEvents(context),
                    '${DummyData.events.length}',
                    Icons.event,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    AppText.totalTickets(context),
                    '${DummyData.tickets.length}',
                    Icons.confirmation_number,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              AppText.quickActions(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Create Event (Admin can also create events)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.add_circle,
                    color: AppTheme.successColor,
                  ),
                ),
                title: Text(AppText.createEvent(context)),
                subtitle: Text(AppText.createNewEvent(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateEventScreen(
                        creatorId: 'admin',
                      ),
                    ),
                  );

                  if (result == true && context.mounted) {
                    // Data already saved and snackbar shown by CreateEventScreen
                    Provider.of<DemoDataProvider>(context, listen: false)
                        .notifyDataChanged();
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // QR Scanner for Attendance
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.purple,
                  ),
                ),
                title: Text(AppText.scanTicketQR(context)),
                subtitle: Text(AppText.checkInAttendees(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRScannerScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Manage Events
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.event,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(AppText.manageEvents(context)),
                subtitle: Text(AppText.eventsCountSimple(
                    context, DummyData.events.length)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageEventsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Manage Creators
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.people,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(AppText.manageCreators(context)),
                subtitle: Text(AppText.manageEventCreators(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageCreatorsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Manage Locations
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(AppText.manageLocations(context)),
                subtitle: Text(AppText.locationsCount(
                    context, DummyData.locations.length)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageLocationsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
