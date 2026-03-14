import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
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

    // Build Firestore query: scanned tickets, optionally filtered by event
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('reservations')
        .where('isScanned', isEqualTo: true);
    if (eventId != null) {
      query = query.where('eventId', isEqualTo: eventId);
    }

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          isEnglish ? 'Check-in History' : 'チェックイン履歴',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Map docs → tickets, always add id = doc.id
          final allTickets = (snapshot.data?.docs ?? [])
              .map((doc) {
                final data = Map<String, dynamic>.from(doc.data());
                data['id'] =
                    doc.id; // prevents ticket['id'].substring(0,8) crash
                return data;
              })
              .where((ticket) => ticket['checkedInAt'] != null)
              .toList();

          // Sort by check-in time (most recent first)
          allTickets.sort((a, b) {
            try {
              final aTime = DateTime.parse(a['checkedInAt']);
              final bTime = DateTime.parse(b['checkedInAt']);
              return bTime.compareTo(aTime);
            } catch (_) {
              return 0;
            }
          });

          if (allTickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner,
                      size: 80, color: Colors.grey[400]),
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allTickets.length,
            itemBuilder: (context, index) {
              final ticket = allTickets[index];
              final checkedInTime = DateTime.parse(ticket['checkedInAt']);
              final eventTitle = isEnglish
                  ? ticket['eventTitle_en']
                  : (ticket['eventTitle_ja'] ?? ticket['eventTitle_en']);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    child: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  title: Text(
                    ticket['userName'] ?? '',
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (ticket['id'] as String?)?.substring(0, 8) ?? 'N/A',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20),
                        tooltip: isEnglish ? 'Delete ticket' : '削除',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                  isEnglish ? 'Delete Ticket?' : 'チケットを削除？'),
                              content: Text(isEnglish
                                  ? 'This will permanently delete the check-in record for ${ticket['userName']}.'
                                  : '${ticket['userName']}のチェックイン記録を削除します。'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(isEnglish ? 'Cancel' : 'キャンセル'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).colorScheme.error),
                                  child: Text(isEnglish ? 'Delete' : '削除'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseFirestore.instance
                                .collection('reservations')
                                .doc(ticket['id'])
                                .delete();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
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
        : '${dateTime.year}年$month$day日 $hour:$minute';
  }
}
