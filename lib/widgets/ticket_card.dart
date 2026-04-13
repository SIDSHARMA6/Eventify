import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/app_text.dart';
import '../utils/language_helper.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/gender_icon.dart';

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isJa = context.watch<LanguageProvider>().currentLanguage == 'ja';
    final title = LanguageHelper.getText(
        ticket['eventTitle_en'], ticket['eventTitle_ja'], isJa);

    // QR encodes the opaque ticketId token (TICKET-xxxxxxxxxxxx),
    // NOT the document ID (deviceId_eventId) which is guessable.
    // checkIn() now queries by this field, so only the token holder can scan in.
    final qrData = ticket['ticketId'] as String? ?? ticket['id'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (ticket['eventImage'] != null)
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(ticket['eventImage'],
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 50))),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Text('${ticket['eventDate']} • ${ticket['eventTime']}')
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(ticket['userName'])),
            GenderIcon(isMale: ticket['gender'] == 'male', size: 16)
          ]),
          const Divider(height: 24),
          Center(
              child: RepaintBoundary(
                child: QrImageView(
                    data: qrData, version: QrVersions.auto, size: 120),
              )),
          const SizedBox(height: 12),
          Center(
              child: Text('${AppText.ticketId(context)}: $qrData',
                  style: Theme.of(context).textTheme.bodySmall)),
        ]),
      ),
    );
  }
}
