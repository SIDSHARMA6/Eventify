import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_text.dart';
import '../../config/theme.dart';
import '../../config/admin_routes.dart';
import '../../widgets/gradient_app_bar.dart';
import 'manage_events_screen.dart';
import 'manage_creators_screen.dart';
import 'manage_locations_screen.dart';
import 'creator_summary_screen.dart';
import 'qr_scanner_screen.dart';
import '../creator/create_event_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.adminDashboard(context),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AdminRoutes.home,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Analytics Cards — live counts from Firestore
          Row(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .snapshots(),
                  builder: (context, snapshot) => _buildStatCard(
                    context,
                    AppText.totalEvents(context),
                    '${snapshot.data?.docs.length ?? 0}',
                    Icons.event,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('reservations')
                      .where('isCancelled', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) => _buildStatCard(
                    context,
                    AppText.totalTickets(context),
                    '${snapshot.data?.docs.length ?? 0}',
                    Icons.confirmation_number,
                    AppTheme.successColor,
                  ),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventScreen(
                      creatorId: 'admin',
                    ),
                  ),
                );
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
              subtitle: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('events').snapshots(),
                builder: (ctx, snap) => Text(
                  AppText.eventsCountSimple(
                      context, snap.data?.docs.length ?? 0),
                ),
              ),
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

          // 🆕 Creators Overview Table
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.withAlpha(25),
                child: const Icon(Icons.bar_chart, color: Colors.teal),
              ),
              title: const Text('Creators Overview',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Events & tickets grouped by creator'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatorSummaryScreen(),
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
              subtitle: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('locations')
                    .snapshots(),
                builder: (ctx, snap) => Text(
                  AppText.locationsCount(context, snap.data?.docs.length ?? 0),
                ),
              ),
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
