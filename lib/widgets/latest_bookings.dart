import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/ticket_service.dart';
import '../providers/language_provider.dart';
import '../utils/app_text.dart';
import '../config/theme.dart';

class LatestBookings extends StatefulWidget {
  const LatestBookings({super.key});

  @override
  State<LatestBookings> createState() => _LatestBookingsState();
}

class _LatestBookingsState extends State<LatestBookings> {
  late Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = TicketService().getLatestBookings(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        // Read language inside builder — language changes only rebuild this subtree,
        // not the outer widget which would re-subscribe to the stream.
        final isJa = context.watch<LanguageProvider>().currentLanguage == 'ja';
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(AppText.latestBookings(context),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            ...bookings.map((booking) {
              final ts = DateTime.tryParse(booking['timestamp'] ?? '') ??
                  DateTime.now();
              final isNew = DateTime.now().difference(ts).inMinutes < 15;
              final title = isJa
                  ? (booking['eventTitle_ja'] ?? booking['eventTitle_en'] ?? '')
                  : (booking['eventTitle_en'] ?? '');

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.1))),
                child: Row(children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                      child: Icon(Icons.confirmation_number_outlined,
                          color: Theme.of(context).primaryColor, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(
                            DateFormat(isJa ? 'M月d日 H:mm' : 'MMM d, h:mm a')
                                .format(ts),
                            style: Theme.of(context).textTheme.bodySmall),
                      ])),
                  if (isNew)
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppTheme.primaryPink,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('NEW',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                ]),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
