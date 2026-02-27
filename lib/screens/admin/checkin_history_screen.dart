import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../widgets/gradient_app_bar.dart';

class CheckinHistoryScreen extends StatelessWidget {
  final String? eventId; // Optional: filter by specific event

  const CheckinHistoryScreen({
    super.key,
    this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isEnglish = languageProvider.currentLanguage == 'en';

    // Get all tickets with check-in data
    final allTickets = DummyData.tickets.where((ticket) {
      final hasCheckedIn = ticket['checkedInAt'] != null;
      if (eventId != null) {
        return hasCheckedIn && ticket['eventId'] == eventId;
      }
      return hasCheckedIn;
    }).toList();

    // Sort by check-in time (most recent first)
    allTickets.sort((a, b) {
      final aTime = DateTime.parse(a['checkedInAt']);
      final bTime = DateTime.parse(b['checkedInAt']);
      return bTime.compareTo(aTime);
    });

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          isEnglish ? 'Check-in History' : 'チェックイン履歴',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: allTickets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEnglish ? 'No check-ins yet' : 'チェックインはまだありません',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEnglish
                        ? 'Scanned tickets will appear here'
                        : 'スキャンされたチケットがここに表示されます',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allTickets.length,
              itemBuilder: (context, index) {
                final ticket = allTickets[index];
                final checkedInTime = DateTime.parse(ticket['checkedInAt']);
                final eventTitle = isEnglish
                    ? ticket['eventTitle_en']
                    : ticket['eventTitle_ja'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(
                      ticket['userName'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '🎫 $eventTitle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '👤 ${ticket['gender'] == 'male' ? (isEnglish ? 'Male' : '男性') : (isEnglish ? 'Female' : '女性')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '🕐 ${_formatDateTime(checkedInTime, isEnglish)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Text(
                      ticket['id'].substring(0, 8),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDateTime(DateTime dateTime, bool isEnglish) {
    final months = isEnglish
        ? [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ]
        : [
            '1月',
            '2月',
            '3月',
            '4月',
            '5月',
            '6月',
            '7月',
            '8月',
            '9月',
            '10月',
            '11月',
            '12月'
          ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return isEnglish
        ? '$day $month ${dateTime.year}, $hour:$minute'
        : '${dateTime.year}年$month${day}日 $hour:$minute';
  }
}
