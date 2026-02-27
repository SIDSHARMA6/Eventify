import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../providers/demo_data_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../creator/create_event_screen.dart';
import '../creator/event_stats_screen.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
  // Uncomment when Firebase is enabled:
  // final _eventService = EventService();

  void _editEvent(Map<String, dynamic> event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          creatorId: event['createdBy'] ?? 'admin',
          event: event,
        ),
      ),
    );

    if (result == true && mounted) {
      // Notify other screens to refresh (saveEvents already done in CreateEventScreen)
      Provider.of<DemoDataProvider>(context, listen: false).notifyDataChanged();
    }
  }

  void _toggleVisibility(Map<String, dynamic> event) async {
    setState(() {
      event['isHidden'] = !(event['isHidden'] ?? false);
    });

    // Persist change
    await LocalStorageService.saveEvents();

    // Notify other screens to refresh
    if (mounted) {
      Provider.of<DemoDataProvider>(context, listen: false).notifyDataChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            event['isHidden']
                ? 'Event hidden successfully'
                : 'Event shown successfully',
          ),
        ),
      );
    }

    // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
    // final newHiddenState = !(event['isHidden'] ?? false);
    // try {
    //   await _eventService.toggleEventVisibility(event['id'], newHiddenState);
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           newHiddenState
    //               ? 'Event hidden successfully'
    //               : 'Event shown successfully',
    //         ),
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error: $e'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // }
  }

  void _duplicateEvent(Map<String, dynamic> event) async {
    final duplicated = Map<String, dynamic>.from(event);
    duplicated['id'] = 'EVENT-DUP-${DateTime.now().millisecondsSinceEpoch}';
    duplicated['title_en'] = '${event['title_en']} (Copy)';
    duplicated['title_ja'] = '${event['title_ja']} (コピー)';
    duplicated['maleBooked'] = 0;
    duplicated['femaleBooked'] = 0;
    duplicated['isDuplicated'] = true; // Mark as duplicated

    setState(() {
      DummyData.events.add(duplicated);
    });

    // Save to SharedPreferences
    await LocalStorageService.saveEvents();

    // Notify other screens to refresh
    if (mounted) {
      Provider.of<DemoDataProvider>(context, listen: false).notifyDataChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.eventDuplicatedSuccess(context))),
      );
    }

    // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
    // try {
    //   await _eventService.duplicateEvent(event['id']);
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Event duplicated successfully')),
    //     );
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error: $e'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // }
  }

  void _deleteEvent(Map<String, dynamic> event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.deleteEvent(context)),
        content: Text(
          AppText.confirmDeleteEventWithTickets(context, event['title_en']),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppText.cancel(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppText.delete(context),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final eventId = event['id'];

      // Mark all tickets for this event as deleted
      for (var ticket in DummyData.tickets) {
        if (ticket['eventId'] == eventId) {
          ticket['isDeleted'] = true;
          ticket['deletedAt'] = DateTime.now().toIso8601String();
        }
      }

      // Mark the event as deleted (soft delete)
      setState(() {
        event['isDeleted'] = true;
        event['deletedAt'] = DateTime.now().toIso8601String();
      });

      // Save to SharedPreferences
      await LocalStorageService.saveEvents();
      await LocalStorageService.saveTickets();

      // Notify other screens to refresh
      if (mounted) {
        Provider.of<DemoDataProvider>(context, listen: false)
            .notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.success(context))),
        );
      }

      // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
      // try {
      //   await _eventService.deleteEvent(event['id']);
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(AppText.success(context))),
      //     );
      //   }
      // } catch (e) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('Error: $e'),
      //         backgroundColor: Colors.red,
      //       ),
      //     );
      //   }
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Listen to demo data and language changes
    context.watch<DemoDataProvider>();
    context.watch<LanguageProvider>();

    // Using dummy data for demo
    final events = DummyData.events;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.manageEvents(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppText.noEventsYet(context),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final isHidden = event['isHidden'] ?? false;
                final isDeleted = event['isDeleted'] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage(event['images_en'][0]),
                              onBackgroundImageError: (_, __) {},
                            ),
                            if (isHidden)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.visibility_off,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                Provider.of<LanguageProvider>(context,
                                                listen: false)
                                            .currentLanguage ==
                                        'en'
                                    ? event['title_en']
                                    : event['title_ja'],
                                style: TextStyle(
                                  decoration: isHidden || isDeleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status badges
                            if (isDeleted)
                              _buildStatusBadge('DELETED', Colors.red)
                            else if (isHidden)
                              _buildStatusBadge('HIDDEN', Colors.orange)
                            else if (event['isDuplicated'] == true)
                              _buildStatusBadge('DUPLICATED', Colors.blue)
                            else
                              _buildStatusBadge('ACTIVE', Colors.green),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '📅 ${event['date']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '🕐 ${event['startTime']} - ${event['endTime']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '📍 ${Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'en' ? event['location_en'] : event['location_ja']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (event['venueAddress_en'] != null ||
                                event['venueAddress_ja'] != null)
                              Text(
                                '🏢 ${Provider.of<LanguageProvider>(context, listen: false).currentLanguage == 'en' ? (event['venueAddress_en'] ?? '') : (event['venueAddress_ja'] ?? '')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (event['isRecurring'] == true)
                              Text(
                                '🔁 ${event['recurringLabel'] ?? 'Recurring'}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
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
                            // Map Icon
                            IconButton(
                              icon: const Icon(Icons.map, color: Colors.blue),
                              onPressed: () async {
                                final url = Uri.parse(event['mapLink']);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                }
                              },
                              tooltip: AppText.openMap(context),
                            ),
                            // Menu
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                // Only show Edit for non-deleted events
                                if (!isDeleted)
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _editEvent(event),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit, size: 20),
                                        const SizedBox(width: 8),
                                        Text(AppText.edit(context)),
                                      ],
                                    ),
                                  ),
                                // Always show Event Stats
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.bar_chart, size: 20),
                                      const SizedBox(width: 8),
                                      Text(AppText.eventStats(context)),
                                    ],
                                  ),
                                  onTap: () {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EventStatsScreen(event: event),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                ),
                                // Only show Hide/Show for non-deleted events
                                if (!isDeleted)
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _toggleVisibility(event),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isHidden
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(isHidden
                                            ? AppText.show(context)
                                            : AppText.hide(context)),
                                      ],
                                    ),
                                  ),
                                // Only show Duplicate for non-deleted events
                                if (!isDeleted)
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _duplicateEvent(event),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.copy, size: 20),
                                        const SizedBox(width: 8),
                                        Text(AppText.duplicate(context)),
                                      ],
                                    ),
                                  ),
                                // Only show Delete for non-deleted events
                                if (!isDeleted)
                                  PopupMenuItem(
                                    onTap: () => Future.delayed(
                                      Duration.zero,
                                      () => _deleteEvent(event),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppText.delete(context),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );

    // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(AppText.manageEvents(context)),
    //   ),
    //   body: StreamBuilder<List<Map<String, dynamic>>>(
    //     stream: _eventService.getAllEvents(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    //
    //       if (snapshot.hasError) {
    //         return Center(
    //           child: Text('Error: ${snapshot.error}'),
    //         );
    //       }
    //
    //       final events = snapshot.data ?? [];
    //       // ... rest of the Firebase implementation
    //     },
    //   ),
    // );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
