import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/ticket_card.dart';
import '../../utils/app_text.dart';
import '../../providers/language_provider.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../services/ticket_service.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = TicketService().getMyReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.myTicketsTitle(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          // Language read inside builder — avoids full screen rebuild on lang change
          context.watch<LanguageProvider>();
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
            ),
          );
        },
      ),
    );
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
