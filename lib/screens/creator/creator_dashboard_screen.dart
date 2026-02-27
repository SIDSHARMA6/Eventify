import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../providers/demo_data_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/gradient_button.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCreatorId();
  }

  Future<void> _loadCreatorId() async {
    final prefs = await SharedPreferences.getInstance();
    String? creatorId = prefs.getString('creator_id');

    // For demo mode, set a default creator ID if not exists
    if (creatorId == null) {
      creatorId = 'demo-creator-1';
      await prefs.setString('creator_id', creatorId);
      await prefs.setString('creator_email', 'demo@creator.com');
    }

    setState(() {
      _creatorId = creatorId;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _myEvents {
    if (_creatorId == null) return [];
    // Show events created by this creator OR events with no owner (seed events)
    return DummyData.events.where((event) {
      final createdBy = event['createdBy'];
      return createdBy == _creatorId || createdBy == null || createdBy == '';
    }).toList();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('creator_email');
    await prefs.remove('creator_id');

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteEvent(Map<String, dynamic> event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.confirmDeleteEvent(context)),
        content: Text(AppText.confirmLogout(context)),
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

      // Persist and notify
      await LocalStorageService.saveEvents();
      await LocalStorageService.saveTickets();

      if (mounted) {
        Provider.of<DemoDataProvider>(context, listen: false)
            .notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.success(context))),
        );
      }
    }
  }

  Future<void> _toggleVisibility(Map<String, dynamic> event) async {
    setState(() {
      event['isHidden'] = !(event['isHidden'] ?? false);
    });

    await LocalStorageService.saveEvents();

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
  }

  Future<void> _duplicateEvent(Map<String, dynamic> event) async {
    final duplicated = Map<String, dynamic>.from(event);
    duplicated['id'] = 'EVENT-DUP-${DateTime.now().millisecondsSinceEpoch}';
    duplicated['title_en'] = '${event['title_en']} (Copy)';
    duplicated['title_ja'] = '${event['title_ja']} (コピー)';
    duplicated['maleBooked'] = 0;
    duplicated['femaleBooked'] = 0;
    duplicated['isDeleted'] = false;
    duplicated['isDuplicated'] = true; // Mark as duplicated

    setState(() {
      DummyData.events.add(duplicated);
    });

    await LocalStorageService.saveEvents();

    if (mounted) {
      Provider.of<DemoDataProvider>(context, listen: false).notifyDataChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.eventDuplicatedSuccess(context))),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // rebuild when language changes
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            // QR Scanner Button
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateEventScreen(creatorId: _creatorId!),
                  ),
                );

                if (result == true && mounted) {
                  // Notify other screens to refresh
                  Provider.of<DemoDataProvider>(context, listen: false)
                      .notifyDataChanged();
                  setState(() {}); // Refresh list
                }
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
              '${_myEvents.length} events created',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),

            const SizedBox(height: 16),

            // My Events List (Only creator's own events)
            if (_myEvents.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
              ..._myEvents.map((event) {
                final isDeleted = event['isDeleted'] ?? false;
                final isHidden = event['isHidden'] ?? false;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(event['images_en'][0]),
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
                    subtitle: Text('${event['date']} • ${event['startTime']}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        // Only show Edit for non-deleted events
                        if (!isDeleted)
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

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateEventScreen(
                                      creatorId: _creatorId!,
                                      event: event,
                                    ),
                                  ),
                                );

                                if (result == true && mounted) {
                                  Provider.of<DemoDataProvider>(context,
                                          listen: false)
                                      .notifyDataChanged();
                                  setState(() {});
                                }
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
                            WidgetsBinding.instance.addPostFrameCallback((_) {
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
                        // Only show Duplicate for non-deleted events
                        if (!isDeleted)
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
                        // Only show Delete for non-deleted events
                        if (!isDeleted)
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.error),
                                const SizedBox(width: 8),
                                Text(
                                  AppText.delete(context),
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                ),
                              ],
                            ),
                            onTap: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
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
    );
  }
}
