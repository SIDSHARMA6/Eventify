import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/gender_icon.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../services/ticket_service.dart';

class AllTicketsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const AllTicketsScreen({
    super.key,
    required this.event,
  });

  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  bool _isAdmin = false;
  String _filterType = 'all'; // all, scanned, deleted, active

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

  List<Map<String, dynamic>> _getFilteredBookings(
      List<Map<String, dynamic>> allBookings) {
    switch (_filterType) {
      case 'scanned':
        return allBookings
            .where((b) => b['isScanned'] == true && b['isCancelled'] != true)
            .toList();
      case 'deleted':
        return allBookings.where((b) => b['isCancelled'] == true).toList();
      case 'active':
        return allBookings
            .where((b) => b['isCancelled'] != true && b['isScanned'] != true)
            .toList();
      default:
        return allBookings;
    }
  }

  Future<void> _deleteTicket(Map<String, dynamic> ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket'),
        content: Text(
          'Are you sure you want to cancel this ticket for ${ticket['userName']}?',
        ),
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
          SnackBar(
            content: Text('Ticket cancelled for ${ticket['userName']}'),
            backgroundColor: Colors.red,
          ),
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: TicketService().getReservationsByEvent(widget.event['id']),
      builder: (context, snapshot) {
        final allBookings = snapshot.data ?? [];
        final filteredBookings = _getFilteredBookings(allBookings);

        final totalCount = allBookings.length;
        final scannedCount = allBookings
            .where((b) => b['isScanned'] == true && b['isCancelled'] != true)
            .length;
        final deletedCount =
            allBookings.where((b) => b['isCancelled'] == true).length;
        final activeCount = allBookings
            .where((b) => b['isCancelled'] != true && b['isScanned'] != true)
            .length;

        return Scaffold(
          appBar: GradientAppBar(
            title: const Text(
              'All Tickets',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'All',
                        'all',
                        totalCount,
                        Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Active',
                        'active',
                        activeCount,
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Scanned',
                        'scanned',
                        scannedCount,
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Deleted',
                        'deleted',
                        deletedCount,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Summary
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Total', totalCount, Icons.confirmation_number),
                    _buildStatItem('Active', activeCount, Icons.check_circle),
                    _buildStatItem(
                        'Scanned', scannedCount, Icons.qr_code_scanner),
                    _buildStatItem('Deleted', deletedCount, Icons.delete),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tickets List
              Expanded(
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 64,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filterType == 'all'
                                  ? 'No tickets yet'
                                  : 'No $_filterType tickets',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          final isDeleted = booking['isDeleted'] ?? false;
                          final isScanned = booking['isScanned'] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: GenderIcon(
                                isMale: booking['gender'] == 'male',
                                size: 28,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking['userName'],
                                      style: TextStyle(
                                        decoration: isDeleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isDeleted)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'DELETED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (isScanned && !isDeleted)
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'SCANNED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ticket ID: ${booking['ticketId']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking['timestamp'],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: booking['gender'] == 'male'
                                          ? AppTheme.maleColor
                                              .withValues(alpha: 0.2)
                                          : AppTheme.femaleColor
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      booking['gender'] == 'male'
                                          ? 'Male'
                                          : 'Female',
                                      style: TextStyle(
                                        color: booking['gender'] == 'male'
                                            ? AppTheme.maleColor
                                            : AppTheme.femaleColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // Show delete icon for admin (except already deleted)
                                  if (_isAdmin && !isDeleted) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 22),
                                      color: Colors.red,
                                      onPressed: () => _deleteTicket(booking),
                                      tooltip: 'Delete ticket',
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, int count, Color color) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterType = value;
        });
      },
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
