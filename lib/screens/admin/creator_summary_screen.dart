import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../services/firebase_service.dart';
import 'manage_events_screen.dart';

/// Admin screen showing a table of all creators and their event/ticket stats.
/// Groups events by createdByEmail — no extra user collection queries needed.
class CreatorSummaryScreen extends StatelessWidget {
  const CreatorSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text(
          'Creators Overview',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService().eventsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          // Build creator summary map: email → stats
          final Map<String, _CreatorStats> creatorMap = {};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final email =
                (data['createdByEmail'] as String?)?.isNotEmpty == true
                    ? data['createdByEmail'] as String
                    : (data['createdBy'] as String? ?? 'Unknown');

            creatorMap.putIfAbsent(email, () => _CreatorStats(email: email));
            final stats = creatorMap[email]!;

            stats.totalEvents++;
            if (data['isHidden'] == true) stats.hiddenEvents++;
            stats.totalMaleBooked += (data['maleBooked'] as num?)?.toInt() ?? 0;
            stats.totalFemaleBooked +=
                (data['femaleBooked'] as num?)?.toInt() ?? 0;
          }

          final creators = creatorMap.values.toList()
            ..sort((a, b) => b.totalEvents.compareTo(a.totalEvents));

          if (creators.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          return Column(
            children: [
              // Summary header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.people,
                      label: '${creators.length} Creators',
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.event,
                      label: '${docs.length} Events',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.confirmation_number,
                      label:
                          '${creators.fold(0, (s, c) => s + c.totalMaleBooked + c.totalFemaleBooked)} Tickets',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              // Table header
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: const [
                    Expanded(
                        flex: 3,
                        child: Text('Creator Email',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                        child: Text('Events',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: Text('Hidden',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                    Expanded(
                        child: Text('Tickets',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Creator rows
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: creators.length,
                  itemBuilder: (context, index) {
                    final c = creators[index];
                    final totalTickets =
                        c.totalMaleBooked + c.totalFemaleBooked;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      title: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.email,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '♂ ${c.totalMaleBooked}  ♀ ${c.totalFemaleBooked}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${c.totalEvents}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              c.hiddenEvents > 0 ? '${c.hiddenEvents}' : '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: c.hiddenEvents > 0
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '$totalTickets',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        // Navigate to filtered ManageEventsScreen for this creator
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ManageEventsScreen(filterByEmail: c.email),
                          ),
                        );
                      },
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
}

class _CreatorStats {
  final String email;
  int totalEvents = 0;
  int hiddenEvents = 0;
  int totalMaleBooked = 0;
  int totalFemaleBooked = 0;

  _CreatorStats({required this.email});
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      backgroundColor: color.withAlpha(25),
      padding: EdgeInsets.zero,
    );
  }
}
