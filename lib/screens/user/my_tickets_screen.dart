import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/ticket_card.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../services/local_storage_service.dart';
import '../../services/local_notification_service.dart';
import '../../providers/demo_data_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/gradient_app_bar.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    // Auto-expire tickets for events that have already passed
    await _expirePastTickets();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _expirePastTickets() async {
    final now = DateTime.now();
    final expired = DummyData.tickets.where((ticket) {
      try {
        final eventDate =
            DateTime.parse(ticket['eventDate'] ?? ticket['date'] ?? '');
        // Expire after midnight of the event day
        return eventDate.isBefore(DateTime(now.year, now.month, now.day));
      } catch (_) {
        return false;
      }
    }).toList();

    if (expired.isEmpty) return;

    for (final ticket in expired) {
      // Decrement booked count on the event
      final eventId = ticket['eventId'];
      final event = DummyData.events.firstWhere(
        (e) => e['id'] == eventId,
        orElse: () => {},
      );
      if (event.isNotEmpty) {
        if (ticket['gender'] == 'male') {
          final cur = (event['maleBooked'] as int?) ?? 0;
          event['maleBooked'] = (cur - 1).clamp(0, 9999);
        } else {
          final cur = (event['femaleBooked'] as int?) ?? 0;
          event['femaleBooked'] = (cur - 1).clamp(0, 9999);
        }
      }
      DummyData.tickets.remove(ticket);
    }

    await LocalStorageService.saveTickets();
    await LocalStorageService.saveEvents();
  }

  Future<void> _cancelTicket(Map<String, dynamic> ticket) async {
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
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppText.yes(context)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Find the event and decrement booked count
      final eventId = ticket['eventId'];
      final gender = ticket['gender'];
      final event = DummyData.events.firstWhere(
        (e) => e['id'] == eventId,
        orElse: () => {},
      );

      if (event.isNotEmpty) {
        if (gender == 'male') {
          final cur = (event['maleBooked'] as int?) ?? 0;
          event['maleBooked'] = (cur - 1).clamp(0, 9999);
        } else {
          final cur = (event['femaleBooked'] as int?) ?? 0;
          event['femaleBooked'] = (cur - 1).clamp(0, 9999);
        }
      }

      setState(() {
        DummyData.tickets.remove(ticket);
      });

      // Save to SharedPreferences
      await LocalStorageService.saveTickets();
      await LocalStorageService.saveEvents();
      await LocalStorageService.unmarkEventAsBooked(eventId);

      // Cancel reminder notifications
      await LocalNotificationService().cancelEventReminders(eventId);

      if (mounted) {
        // Notify other screens to refresh
        Provider.of<DemoDataProvider>(context, listen: false)
            .notifyDataChanged();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.success(context))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    context.watch<LanguageProvider>(); // rebuild when language changes
    context.watch<DemoDataProvider>(); // rebuild when tickets change

    // Always read live list from DummyData - filter out deleted tickets
    final tickets = DummyData.tickets
        .where((ticket) => ticket['isDeleted'] != true)
        .toList();

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.myTickets(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      return TicketCard(
                        ticket: tickets[index],
                        onCancel: () => _cancelTicket(tickets[index]),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
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
