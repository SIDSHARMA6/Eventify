import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/language_provider.dart';
import '../utils/app_text.dart';
import '../utils/language_helper.dart';
import '../widgets/gender_icon.dart';

class TicketCard extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onCancel;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // rebuild when language changes
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isJapanese = languageProvider.currentLanguage == 'ja';

    // Use helper with fallback
    final eventTitle = LanguageHelper.getText(
      ticket['eventTitle_en'],
      ticket['eventTitle_ja'],
      isJapanese,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (ticket['eventImage'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (ticket['eventImage'] as String).startsWith('http')
                    ? Image.network(
                        ticket['eventImage'],
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => Container(
                          height: 150,
                          color: Colors.grey.withValues(alpha: 0.3),
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      )
                    : Image.asset(
                        ticket['eventImage'],
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        cacheWidth: 600,
                        cacheHeight: 300,
                      ),
              ),

            const SizedBox(height: 12),

            // Event Title
            Text(
              eventTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Date and Time (NO VENUE)
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  '${ticket['eventDate']} • ${ticket['eventTime']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Ticket Holder
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket['userName'],
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GenderIcon(
                  isMale: ticket['gender'] == 'male',
                  size: 16,
                ),
              ],
            ),

            const Divider(height: 24),

            // QR Code
            Center(
              child: QrImageView(
                data: ticket['id'],
                version: QrVersions.auto,
                size: 150,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: 12),

            // Ticket ID
            Center(
              child: Text(
                '${AppText.ticketId(context)}: ${ticket['id']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 8),

            // Pay at Venue
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppText.payAtVenue(context),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button (Full Width)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel),
                label: Text(AppText.cancelTickets(context)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
