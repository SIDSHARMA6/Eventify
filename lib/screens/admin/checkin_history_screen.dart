import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/ticket_service.dart';
import '../../widgets/gradient_app_bar.dart';

class CheckinHistoryScreen extends StatefulWidget {
  final String? eventId;

  const CheckinHistoryScreen({super.key, this.eventId});

  @override
  State<CheckinHistoryScreen> createState() => _CheckinHistoryScreenState();
}

class _CheckinHistoryScreenState extends State<CheckinHistoryScreen> {
  // FIX C-05/C-10: Stream stored in initState, not recreated each build
  late final Stream<List<Map<String, dynamic>>> _historyStream;
  final Set<String> _selected = {};
  bool _isSelecting = false;
  bool _isDeleting = false;
  int _deleteProgress = 0;
  int _deleteTotal = 0;
  // _currentTickets updated via postFrameCallback to avoid side-effect in builder
  List<Map<String, dynamic>> _currentTickets = [];

  @override
  void initState() {
    super.initState();
    _historyStream = TicketService().getCheckinHistory(eventId: widget.eventId);
  }


  void _toggleSelect(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) _isSelecting = false;
      } else {
        _selected.add(id);
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> tickets) {
    setState(() {
      _selected.addAll(tickets.map((t) => t['id'] as String));
    });
  }

  void _clearSelection() {
    setState(() {
      _selected.clear();
      _isSelecting = false;
    });
  }

  Future<void> _deleteSelected(bool isEnglish) async {
    if (_selected.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEnglish ? 'Delete Selected?' : '選択を削除？'),
        content: Text(
          isEnglish
              ? 'Delete ${_selected.length} check-in record(s)? This cannot be undone.'
              : '${_selected.length}件のチェックイン記録を削除しますか？この操作は元に戻せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isEnglish ? 'Cancel' : 'キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isEnglish ? 'Delete' : '削除'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
      _deleteProgress = 0;
      _deleteTotal = _selected.length;
    });

    try {
      final toDelete = _currentTickets
          .where((t) => _selected.contains(t['id'] as String))
          .toList();
      await TicketService().deleteReservations(
        toDelete,
        onProgress: (completed, total) {
          if (mounted) setState(() => _deleteProgress = completed);
        },
      );
      _clearSelection();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEnglish ? 'Delete failed: $e' : '削除失敗: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _deleteSingle(
      Map<String, dynamic> ticket, bool isEnglish) async {
    final id = ticket['id'] as String;
    final name = ticket['userName'] as String? ?? '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEnglish ? 'Delete Ticket?' : 'チケットを削除？'),
        content: Text(
          isEnglish
              ? 'This will permanently delete the check-in record for $name.'
              : '$nameのチェックイン記録を削除します。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isEnglish ? 'Cancel' : 'キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(isEnglish ? 'Delete' : '削除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isDeleting = true;
        _deleteTotal = 1;
        _deleteProgress = 0;
      });
      try {
        await TicketService().deleteReservation(
          id,
          ticket['eventId'] as String? ?? '',
          ticket['gender'] as String? ?? 'male',
        );
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use read — AppBar text is static per build; language changes trigger
    // a full rebuild via InheritedWidget anyway when locale changes.
    final isEnglish = context.watch<LanguageProvider>().currentLanguage == 'en';

    return Scaffold(
      appBar: GradientAppBar(
        title: _isSelecting
            ? Text(
                '${_selected.length} ${isEnglish ? 'selected' : '件選択中'}',
                style: const TextStyle(color: Colors.white),
              )
            : Text(
                isEnglish ? 'Check-in History' : 'チェックイン履歴',
                style: const TextStyle(color: Colors.white),
              ),
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _clearSelection,
              )
            : null,
        actions: _isSelecting
            ? [
                Builder(builder: (context) {
                  final allSelected = _currentTickets.isNotEmpty &&
                      _selected.length == _currentTickets.length;
                  return TextButton(
                    onPressed: allSelected
                        ? _clearSelection
                        : () => _selectAll(_currentTickets),
                    child: Text(
                      allSelected
                          ? (isEnglish ? 'Deselect All' : '全解除')
                          : (isEnglish ? 'Select All' : '全選択'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  tooltip: isEnglish ? 'Delete selected' : '選択を削除',
                  onPressed: _selected.isEmpty
                      ? null
                      : () => _deleteSelected(isEnglish),
                ),
              ]
            : [],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _historyStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final allTickets = _sortTickets(snapshot.data ?? []);
              // Plain assignment — _currentTickets is only read in async
              // action handlers, never during build, so no setState needed.
              _currentTickets = allTickets;

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
                  final id = ticket['id'] as String;
                  final checkedInTime = DateTime.tryParse(
                          ticket['checkedInAt'] as String? ?? '') ??
                      DateTime.now(); // FIX-021: tryParse never throws
                  final eventTitle = isEnglish
                      ? ticket['eventTitle_en']
                      : (ticket['eventTitle_ja'] ?? ticket['eventTitle_en']);
                  final isSelected = _selected.contains(id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isSelected
                          ? BorderSide(
                              color: Theme.of(context).primaryColor, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      onTap: _isSelecting ? () => _toggleSelect(id) : null,
                      onLongPress: () {
                        setState(() => _isSelecting = true);
                        _toggleSelect(id);
                      },
                      leading: _isSelecting
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleSelect(id),
                              activeColor: Theme.of(context).primaryColor,
                            )
                          : CircleAvatar(
                              backgroundColor:
                                  Colors.green.withValues(alpha: 0.1),
                              child: const Icon(Icons.check_circle,
                                  color: Colors.green),
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
                          Text('🎫 $eventTitle',
                              maxLines: 1, overflow: TextOverflow.ellipsis),
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
                      trailing: _isSelecting
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  id.substring(0, 8),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      size: 20),
                                  tooltip: isEnglish ? 'Delete' : '削除',
                                  onPressed: () =>
                                      _deleteSingle(ticket, isEnglish),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              );
            },
          ),

          // Progress loader during bulk delete
          if (_isDeleting)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: CircularProgressIndicator(
                                value: _deleteTotal > 0
                                    ? _deleteProgress / _deleteTotal
                                    : null,
                                strokeWidth: 6,
                              ),
                            ),
                            Text(
                              '$_deleteProgress/$_deleteTotal',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEnglish ? 'Deleting...' : '削除中...',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _sortTickets(List<Map<String, dynamic>> list) {
    final filtered = list.where((t) => t['checkedInAt'] != null).toList();
    filtered.sort((a, b) {
      try {
        return DateTime.parse(b['checkedInAt'])
            .compareTo(DateTime.parse(a['checkedInAt']));
      } catch (_) {
        return 0;
      }
    });
    return filtered;
  }

  static const List<String> _monthsEn = [
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
  ];
  static const List<String> _monthsJa = [
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

  String _formatDateTime(DateTime dateTime, bool isEnglish) {
    final months = isEnglish ? _monthsEn : _monthsJa;
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return isEnglish
        ? '${dateTime.day} $month ${dateTime.year}, $hour:$minute'
        : '${dateTime.year}年$month${dateTime.day}日 $hour:$minute';
  }
}
