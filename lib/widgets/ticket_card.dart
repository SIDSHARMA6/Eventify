import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/app_text.dart';
import '../utils/language_helper.dart';
import '../widgets/gender_icon.dart';

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onCancel;
  const TicketCard({super.key, required this.ticket, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isJa = LanguageHelper.isJapanese(context);
    final title = LanguageHelper.getText(ticket['eventTitle_en'], ticket['eventTitle_ja'], isJa);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (ticket['eventImage'] != null) ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(ticket['eventImage'], width: double.infinity, height: 150, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.broken_image, size: 50))),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 8), Text('${ticket['eventDate']} • ${ticket['eventTime']}')]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.person, size: 16), const SizedBox(width: 8), Expanded(child: Text(ticket['userName'])), GenderIcon(isMale: ticket['gender'] == 'male', size: 16)]),
          const Divider(height: 24),
          Center(child: QrImageView(data: ticket['id'], version: QrVersions.auto, size: 120)),
          const SizedBox(height: 12),
          Center(child: Text('${AppText.ticketId(context)}: ${ticket['id']}', style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onCancel, icon: const Icon(Icons.cancel), label: Text(AppText.cancelTickets(context)), style: OutlinedButton.styleFrom(foregroundColor: Colors.red))),
        ]),
      ),
    );
  }
}
