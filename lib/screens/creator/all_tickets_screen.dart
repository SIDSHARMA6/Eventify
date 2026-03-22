import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../widgets/gender_icon.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/loading_overlay.dart';
import '../../services/ticket_service.dart';

class AllTicketsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const AllTicketsScreen({super.key, required this.event});

  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  bool _isAdmin = false;
  String _filterType = 'all';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> list) {
    switch (_filterType) {
      case 'scanned':
        return list.where((b) => b['isScanned'] == true).toList();
      case 'active':
        return list.where((b) => b['isScanned'] != true).toList();
      default:
        return list;
    }
  }

  Future<void> _deleteTicket(Map<String, dynamic> ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: Text('Delete ticket for ${ticket['userName']}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await TicketService().deleteReservation(
          ticket['id'],
          ticket['eventId'] ?? widget.event['id'],
          ticket['gender'] ?? 'male',
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: _isLoading,
        message: 'Deleting...',
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: TicketService().getReservationsByEvent(widget.event['id']),
          builder: (context, snapshot) {
            final all = snapshot.data ?? [];
            final filtered = _filtered(all);
            final scannedCount =
                all.where((b) => b['isScanned'] == true).length;
            final activeCount = all.where((b) => b['isScanned'] != true).length;

            return Scaffold(
              appBar: GradientAppBar(
                title: const Text('All Tickets',
                    style: TextStyle(color: Colors.white)),
              ),
              body: Column(
                children: [
                  // Filter Chips
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _chip('All', 'all', all.length,
                              Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          _chip('Active', 'active', activeCount, Colors.blue),
                          const SizedBox(width: 8),
                          _chip(
                              'Scanned', 'scanned', scannedCount, Colors.green),
                        ],
                      ),
                    ),
                  ),

                  // Stats
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('Total', all.length, Icons.confirmation_number),
                        _stat('Active', activeCount, Icons.check_circle),
                        _stat('Scanned', scannedCount, Icons.qr_code_scanner),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No tickets yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final booking = filtered[index];
                              final isScanned = booking['isScanned'] == true;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: GenderIcon(
                                      isMale: booking['gender'] == 'male',
                                      size: 28),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          booking['userName'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (isScanned)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text('SCANNED',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text('Ticket ID: ${booking['ticketId']}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'monospace')),
                                      const SizedBox(height: 2),
                                      Text(booking['timestamp'],
                                          style: const TextStyle(fontSize: 11)),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                      if (_isAdmin) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 22),
                                          color: Colors.red,
                                          onPressed: () =>
                                              _deleteTicket(booking),
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
        )); // LoadingOverlay
  }

  Widget _chip(String label, String value, int count, Color color) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text('$label ($count)',
          style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterType = value),
      selectedColor: color,
      checkmarkColor: Colors.white,
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _stat(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(count.toString(),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
