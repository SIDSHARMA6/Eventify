import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_text.dart';
import '../../utils/language_helper.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/event_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';
import '../admin/qr_scanner_screen.dart';
import 'create_event_screen.dart';
import 'event_stats_screen.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  String? _creatorId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.userId == null || (!auth.isCreator && !auth.isAdmin)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      _creatorId = auth.userId;
    }
  }

  Stream<List<Map<String, dynamic>>> _myEventsStream() {
    if (_creatorId == null) return const Stream.empty();
    return EventService().getEventsByCreator(_creatorId!);
  }

  bool _isEventOutsideVisibleRange(Map<String, dynamic> event) {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final twoMonthsLater = DateTime(now.year, now.month + 2, 1);
      final eventDate = DateTime.parse(event['date']);

      // Event is outside the 2-month visible range on home screen
      return eventDate.isBefore(currentMonth) ||
          eventDate.isAfter(twoMonthsLater) ||
          eventDate.isAtSameMomentAs(twoMonthsLater);
    } catch (e) {
      return false;
    }
  }

  Future<void> _logout() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteEvent(Map<String, dynamic> event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.confirmDeleteEvent(context)),
        content: const Text(
            'This will permanently delete the event and all its tickets. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppText.no(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(AppText.yes(context)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
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
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleVisibility(Map<String, dynamic> event) async {
    final newHidden = !(event['isHidden'] ?? false);
    setState(() => _isLoading = true);
    try {
      await EventService().toggleEventVisibility(event['id'], newHidden);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newHidden ? 'Event hidden' : 'Event visible'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _duplicateEvent(Map<String, dynamic> event) async {
    final duplicated = Map<String, dynamic>.from(event);
    duplicated.remove('id');
    duplicated['title_en'] = '${event['title_en']} (Copy)';
    duplicated['title_ja'] = '${event['title_ja']} (コピー)';
    duplicated['maleBooked'] = 0;
    duplicated['femaleBooked'] = 0;
    duplicated['isDuplicated'] = true;

    setState(() => _isLoading = true);
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
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    if (_creatorId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return LoadingOverlay(
      isLoading: _isLoading,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _myEventsStream(),
        builder: (context, snapshot) {
          final myEvents = snapshot.data ?? [];

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppText.logout(context)),
                  content: Text(AppText.confirmLogout(context)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppText.no(context)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(AppText.yes(context)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                _logout();
              }
            },
            child: Scaffold(
              appBar: GradientAppBar(
                title: Text(
                  AppText.creatorDashboard(context),
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
                ],
              ),
              body: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // QR Scanner Button — admin only
                  if (Provider.of<AuthProvider>(context, listen: false).isAdmin)
                    GradientButtonIcon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(AppText.scanTicketQR(context)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),

                  const SizedBox(height: 16),

                  // Create Event Button
                  GradientButtonIcon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateEventScreen(creatorId: _creatorId!),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(AppText.createEvent(context)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    AppText.myEvents(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${myEvents.length} events created',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // My Events List (Only creator's own events)
                  if (myEvents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No events created yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...myEvents.map((event) {
                      final isHidden = event['isHidden'] ?? false;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: _getEventImage(event),
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Status badges
                              if (isHidden)
                                const StatusBadge(
                                    label: 'HIDDEN', color: Colors.orange)
                              else if (event['isDuplicated'] == true)
                                const StatusBadge(
                                    label: 'DUPLICATED', color: Colors.blue)
                              else if (_isEventOutsideVisibleRange(event))
                                const StatusBadge(
                                    label: 'PAST/FUTURE', color: Colors.grey)
                              else
                                const StatusBadge(
                                    label: 'ACTIVE', color: Colors.green),
                            ],
                          ),
                          subtitle:
                              Text('${event['date']} • ${event['startTime']}'),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              // Edit
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit, size: 20),
                                    const SizedBox(width: 8),
                                    Text(AppText.edit(context)),
                                  ],
                                ),
                                onTap: () {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
                                    if (!mounted) return;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateEventScreen(
                                          creatorId: _creatorId!,
                                          event: event,
                                        ),
                                      ),
                                    );
                                  });
                                },
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
                              // Hide/Show
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      (event['isHidden'] ?? false)
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text((event['isHidden'] ?? false)
                                        ? AppText.show(context)
                                        : AppText.hide(context)),
                                  ],
                                ),
                                onTap: () {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
                                    if (mounted) {
                                      await _toggleVisibility(event);
                                    }
                                  });
                                },
                              ),
                              // Duplicate
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    const Icon(Icons.copy, size: 20),
                                    const SizedBox(width: 8),
                                    Text(AppText.duplicate(context)),
                                  ],
                                ),
                                onTap: () {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
                                    if (mounted) {
                                      await _duplicateEvent(event);
                                    }
                                  });
                                },
                              ),
                              // Delete
                              PopupMenuItem(
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
                                onTap: () {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (mounted) {
                                      _deleteEvent(event);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ); // PopScope
        },
      ), // StreamBuilder
    ); // LoadingOverlay
  }

  ImageProvider _getEventImage(Map<String, dynamic> event) {
    final images = event['images_en'];
    if (images is List && images.isNotEmpty) {
      final img = images[0]?.toString() ?? '';
      if (img.startsWith('http')) return NetworkImage(img);
    }
    return const AssetImage('assets/images/placeholder.png');
  }
}
