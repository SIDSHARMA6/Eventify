import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/language_helper.dart';
import '../../services/event_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/status_badge.dart';
import '../creator/event_stats_screen.dart';

// FIX C-03: Converted to StatefulWidget — stream stored in initState, not recreated each build
class CreatorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> creator;

  const CreatorDetailScreen({super.key, required this.creator});

  @override
  State<CreatorDetailScreen> createState() => _CreatorDetailScreenState();
}

class _CreatorDetailScreenState extends State<CreatorDetailScreen> {
  late final Stream<List<Map<String, dynamic>>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _eventsStream = EventService().getEventsByCreator(widget.creator['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          widget.creator['email'] ?? 'Creator',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          // Language read inside builder — avoids full screen rebuild on lang change
          context.watch<LanguageProvider>();
          final events = snapshot.data ?? [];

          return Column(
            children: [
              // Creator Info Card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          widget.creator['email']
                                  ?.substring(0, 1)
                                  .toUpperCase() ??
                              'C',
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.creator['email'] ?? 'No email',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Creator ID: ${widget.creator['id']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(
                            context,
                            'Events',
                            events.length.toString(),
                            Icons.event,
                          ),
                          _buildStat(
                            context,
                            'Active',
                            events
                                .where((e) => !(e['isHidden'] ?? false))
                                .length
                                .toString(),
                            Icons.visibility,
                          ),
                          _buildStat(
                            context,
                            'Hidden',
                            events
                                .where((e) => e['isHidden'] == true)
                                .length
                                .toString(),
                            Icons.visibility_off,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Events List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Events',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${events.length} total',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              if (events.isEmpty)
                Expanded(
                  child: Center(
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
                          'No events created yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isHidden = event['isHidden'] ?? false;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: event['images_en'] != null &&
                                    (event['images_en'] as List).isNotEmpty
                                ? NetworkImage(event['images_en'][0])
                                : null,
                            child: event['images_en'] == null ||
                                    (event['images_en'] as List).isEmpty
                                ? const Icon(Icons.event)
                                : null,
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  LanguageHelper.getEventTitle(
                                    event,
                                    context.watch<LanguageProvider>().currentLanguage ==
                                        'ja',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isHidden)
                                const StatusBadge(
                                    label: 'HIDDEN', color: Colors.orange)
                              else
                                const StatusBadge(
                                    label: 'ACTIVE', color: Colors.green),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('📅 ${event['date']}'),
                              Text(
                                  '🎫 ${event['maleBooked'] ?? 0}/${event['maleLimit']} ♂  ${event['femaleBooked'] ?? 0}/${event['femaleLimit']} ♀'),
                            ],
                          ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventStatsScreen(event: event),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
