import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/ticket_card.dart';
import '../../utils/app_text.dart';
import '../../services/ticket_service.dart';
import '../../providers/language_provider.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/loading_overlay.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  late Stream<List<Map<String, dynamic>>> _stream;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stream = TicketService().getMyReservations();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Cancelling...',
      child: Scaffold(
        appBar: GradientAppBar(
          title: const Text(
            'My Tickets - Best Evento 🎉',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final tickets = snapshot.data ?? [];
            if (tickets.isEmpty) return _buildEmptyState(context);

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: tickets.length,
              itemBuilder: (context, index) => TicketCard(
                ticket: tickets[index],
                onCancel: () => _cancelTicket(tickets[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _cancelTicket(Map<String, dynamic> ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppText.cancelTicket(ctx)),
        content: Text(AppText.cancelConfirm(ctx)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppText.no(ctx)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(AppText.yes(ctx)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      final messenger = ScaffoldMessenger.of(context);
      final successMsg = AppText.success(context);
      final errorColor = Theme.of(context).colorScheme.error;
      try {
        await TicketService().cancelReservation(
          ticket['id'],
          ticket['eventId'],
          ticket['gender'],
        );
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(successMsg)),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: errorColor,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined,
              size: 100, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(height: 16),
          Text(AppText.noTicketsYet(context),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(AppText.browseEvents(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  )),
        ],
      ),
    );
  }
}
