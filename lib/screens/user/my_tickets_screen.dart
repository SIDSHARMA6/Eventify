import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/ticket_card.dart';
import '../../utils/app_text.dart';
import '../../services/ticket_service.dart';
import '../../providers/language_provider.dart';
import '../../widgets/gradient_app_bar.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text(
          'My Tickets (Best Evento 🎉)',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: TicketService().getMyReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Filter out deleted tickets and past events
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final tickets = (snapshot.data ?? []).where((ticket) {
            if (ticket['isDeleted'] == true) return false;
            // Exclude tickets for events that already ended
            try {
              final eventDate = DateTime.parse(ticket['eventDate'] ?? '');
              return !eventDate.isBefore(today);
            } catch (_) {
              return true; // keep if can't parse
            }
          }).toList();

          if (tickets.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              return TicketCard(
                ticket: tickets[index],
                onCancel: () => _cancelTicket(context, tickets[index]),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancelTicket(
      BuildContext context, Map<String, dynamic> ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.cancelTicket(context)),
        content: Text(AppText.cancelConfirm(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppText.no(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(AppText.yes(context)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await TicketService().cancelReservation(
          ticket['id'],
          ticket['eventId'],
          ticket['gender'],
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppText.success(context))),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 100,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 16),
          Text(
            AppText.noTicketsYet(context),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            AppText.browseEvents(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
        ],
      ),
    );
  }
}
