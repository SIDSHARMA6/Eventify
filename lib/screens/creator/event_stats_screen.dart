import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_text.dart';
import '../../utils/language_helper.dart';
import '../../config/theme.dart';
import '../../widgets/gender_icon.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../services/ticket_service.dart';
import 'all_tickets_screen.dart';

class EventStatsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventStatsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventStatsScreen> createState() => _EventStatsScreenState();
}

class _EventStatsScreenState extends State<EventStatsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  void _checkAdminRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isAdmin = authProvider.isAdmin;
    });
  }

  Future<void> _cancelTicket(Map<String, dynamic> ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket'),
        content: Text('Cancel ticket for ${ticket['userName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Ticket'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await TicketService().cancelReservation(
          ticket['id'],
          ticket['eventId'] ?? widget.event['id'],
          ticket['gender'] ?? 'male',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket cancelled')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: TicketService().getReservationsByEvent(widget.event['id']),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final activeBookings =
            bookings.where((b) => b['isCancelled'] != true).toList();
        final maleBookings =
            activeBookings.where((b) => b['gender'] == 'male').length;
        final femaleBookings =
            activeBookings.where((b) => b['gender'] == 'female').length;
        final totalBookings = activeBookings.length;
        final scannedCount =
            bookings.where((b) => b['isScanned'] == true).length;
        final cancelledCount =
            bookings.where((b) => b['isCancelled'] == true).length;

        final maleLimit = widget.event['maleLimit'] as int? ?? 0;
        final femaleLimit = widget.event['femaleLimit'] as int? ?? 0;
        final maleRemaining = maleLimit - maleBookings;
        final femaleRemaining = femaleLimit - femaleBookings;

        return Scaffold(
          appBar: GradientAppBar(
            title: Text(
              AppText.eventStats(context),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Event Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageHelper.getEventTitle(
                          widget.event,
                          Provider.of<LanguageProvider>(context, listen: false)
                                  .currentLanguage ==
                              'ja',
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${widget.event['date']} • ${widget.event['startTime']}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Total Bookings (Clickable)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AllTicketsScreen(event: widget.event),
                    ),
                  );
                },
                child: _buildStatCard(
                  context,
                  'Total Bookings',
                  totalBookings.toString(),
                  Icons.confirmation_number,
                  Theme.of(context).primaryColor,
                  isClickable: true,
                ),
              ),

              const SizedBox(height: 16),

              // Male Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Male Bookings',
                      '$maleBookings / $maleLimit',
                      Icons.male,
                      AppTheme.maleColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Male Remaining',
                      maleRemaining.toString(),
                      Icons.people,
                      AppTheme.maleColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Female Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Female Bookings',
                      '$femaleBookings / $femaleLimit',
                      Icons.female,
                      AppTheme.femaleColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Female Remaining',
                      femaleRemaining.toString(),
                      Icons.people,
                      AppTheme.femaleColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Cancelled & Scanned Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Cancelled',
                      cancelledCount.toString(),
                      Icons.cancel_outlined,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Scanned',
                      scannedCount.toString(),
                      Icons.qr_code_scanner,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Bookings
              Text(
                'Recent Bookings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 16),

              if (bookings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...bookings.map((booking) {
                  final isCancelled = booking['isCancelled'] ?? false;
                  final isScanned = booking['isScanned'] ?? false;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: GenderIcon(
                        isMale: booking['gender'] == 'male',
                        size: 24,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking['userName'] ?? '',
                              style: TextStyle(
                                decoration: isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (isCancelled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CANCELLED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isScanned && !isCancelled)
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SCANNED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        booking['timestamp'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            booking['gender'] == 'male' ? 'Male' : 'Female',
                            style: TextStyle(
                              color: booking['gender'] == 'male'
                                  ? AppTheme.maleColor
                                  : AppTheme.femaleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isAdmin && !isCancelled) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: Colors.red,
                              onPressed: () => _cancelTicket(booking),
                              tooltip: 'Delete ticket',
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isClickable = false,
  }) {
    return Card(
      elevation: isClickable ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                if (isClickable) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 16, color: color),
                ],
              ],
            ),
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
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (isClickable)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Tap to view all',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
