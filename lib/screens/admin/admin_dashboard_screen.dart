import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import '../../config/theme.dart';
import '../../config/admin_routes.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../services/event_service.dart';
import '../../services/ticket_service.dart';
import 'manage_events_screen.dart';
import 'manage_creators_screen.dart';
import 'manage_locations_screen.dart';
import 'qr_scanner_screen.dart';
import '../creator/create_event_screen.dart';

// FIX C-01: Converted to StatefulWidget — streams stored in initState, not recreated each build
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final Stream<List<Map<String, dynamic>>> _eventsStream;
  late final Future<int> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _eventsStream = EventService().getAllEvents();
    _ticketsFuture = TicketService().getTotalActiveCount();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(AppText.adminDashboard(context),
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AdminRoutes.home, (_) => false);
              }
            },
          ),
        ],
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, _, __) => ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _eventsStream,
                    builder: (context, snap) => _statCard(
                      context,
                      AppText.totalEvents(context),
                      '${snap.data?.length ?? 0}',
                      Icons.event,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<int>(
                    future: _ticketsFuture,
                    builder: (context, snap) => _statCard(
                      context,
                      AppText.totalTickets(context),
                      '${snap.data ?? 0}',
                      Icons.confirmation_number,
                      AppTheme.successColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(AppText.quickActions(context),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _tile(
              context,
              icon: Icons.add_circle,
              color: AppTheme.successColor,
              title: AppText.createEvent(context),
              subtitle: AppText.createNewEvent(context),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const CreateEventScreen(creatorId: 'admin'))),
            ),
            _tile(
              context,
              icon: Icons.qr_code_scanner,
              color: Colors.purple,
              title: AppText.scanTicketQR(context),
              subtitle: AppText.checkInAttendees(context),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const QRScannerScreen())),
            ),
            _tile(
              context,
              icon: Icons.event,
              color: Theme.of(context).primaryColor,
              title: AppText.manageEvents(context),
              subtitle: AppText.manageEvents(context),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageEventsScreen())),
            ),
            _tile(
              context,
              icon: Icons.people,
              color: Theme.of(context).primaryColor,
              title: AppText.manageCreators(context),
              subtitle: AppText.manageEventCreators(context),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageCreatorsScreen())),
            ),
            _tile(
              context,
              icon: Icons.location_on,
              color: Theme.of(context).primaryColor,
              title: AppText.manageLocations(context),
              subtitle: AppText.manageLocations(context),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageLocationsScreen())),
            ),
          ],
        ),
      ), // Consumer<LanguageProvider>
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
