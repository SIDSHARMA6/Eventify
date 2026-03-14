import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_text.dart';
import '../../utils/helpers.dart';
import '../../utils/language_helper.dart';
import '../../providers/language_provider.dart';
import '../../services/event_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/status_badge.dart';
import '../creator/create_event_screen.dart';
import '../creator/event_stats_screen.dart';

class ManageEventsScreen extends StatefulWidget {
  /// Optional: filter to only show events by a specific creator email.
  final String? filterByEmail;

  const ManageEventsScreen({super.key, this.filterByEmail});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _editEvent(Map<String, dynamic> event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          creatorId: event['createdBy'] ?? 'admin',
          event: event,
        ),
      ),
    );
    // No notifyDataChanged needed — Firebase stream auto-refreshes
  }

  void _toggleVisibility(Map<String, dynamic> event) async {
    final newHidden = !(event['isHidden'] ?? false);
    await EventService().toggleEventVisibility(event['id'], newHidden);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newHidden ? 'Event hidden' : 'Event shown',
          ),
        ),
      );
    }
  }

  void _duplicateEvent(Map<String, dynamic> event) async {
    final duplicated = Map<String, dynamic>.from(event);
    duplicated.remove('id'); // Firestore will assign a new ID
    duplicated['title_en'] = '${event['title_en']} (Copy)';
    duplicated['title_ja'] = '${event['title_ja']} (コピー)';
    duplicated['maleBooked'] = 0;
    duplicated['femaleBooked'] = 0;
    duplicated['isDuplicated'] = true;

    try {
      await EventService().createEvent(duplicated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.eventDuplicatedSuccess(context))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      try {
        await EventService().deleteEvent(event['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppText.success(context))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: EventService().getAllEvents(),
      builder: (context, snapshot) {
        var events = snapshot.data ?? [];

        // Filter by creator email if coming from CreatorSummaryScreen
        final filter = widget.filterByEmail;
        if (filter != null) {
          events = events.where((e) => e['createdByEmail'] == filter).toList();
        }

        return Scaffold(
          appBar: GradientAppBar(
            title: Text(
              filter != null
                  ? 'Events by ${filter.contains('@') ? filter.split('@').first : filter}'
                  : AppText.manageEvents(context),
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
                                      (event['images_en'] != null &&
                                              (event['images_en'] as List)
                                                  .isNotEmpty)
                                          ? NetworkImage(event['images_en'][0])
                                          : null,
                                  child: (event['images_en'] == null ||
                                          (event['images_en'] as List).isEmpty)
                                      ? const Icon(Icons.event)
                                      : null,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
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
                                    LanguageHelper.getEventTitle(
                                      event,
                                      Provider.of<LanguageProvider>(context,
                                                  listen: false)
                                              .currentLanguage ==
                                          'ja',
                                    ),
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
                                  const StatusBadge(
                                      label: 'DELETED', color: Colors.red)
                                else if (isHidden)
                                  const StatusBadge(
                                      label: 'HIDDEN', color: Colors.orange)
                                else if (event['isDuplicated'] == true)
                                  const StatusBadge(
                                      label: 'DUPLICATED', color: Colors.blue)
                                else
                                  const StatusBadge(
                                      label: 'ACTIVE', color: Colors.green),
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
                                  '🕐 ${Helpers.formatTo12Hour(event['startTime'])} - ${Helpers.formatTo12Hour(event['endTime'])}',
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
                                  icon:
                                      const Icon(Icons.map, color: Colors.blue),
                                  onPressed: () async {
                                    final rawLink =
                                        (event['mapLink'] as String?)?.trim();
                                    // Validate: must exist and use HTTPS only
                                    if (rawLink == null ||
                                        rawLink.isEmpty ||
                                        !rawLink.startsWith('https://')) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Map link unavailable or insecure'),
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    final url = Uri.parse(rawLink);
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
                                                    EventStatsScreen(
                                                        event: event),
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
      },
    );
  }
}
