import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../config/theme.dart';
import '../../widgets/gender_icon.dart';
import '../../widgets/gradient_app_bar.dart';

class EventStatsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventStatsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventStatsScreen> createState() => _EventStatsScreenState();
}

class _EventStatsScreenState extends State<EventStatsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late List<Map<String, dynamic>> _bookings;
  late int _maleBookings;
  late int _femaleBookings;
  late int _totalBookings;

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  void _calculateStats() {
    _bookings = DummyData.tickets
        .where((ticket) => ticket['eventId'] == widget.event['id'])
        .toList();

    _maleBookings = _bookings.where((b) => b['gender'] == 'male').length;
    _femaleBookings = _bookings.where((b) => b['gender'] == 'female').length;
    _totalBookings = _bookings.length;
  }

  int get _deletedTicketsCount =>
      _bookings.where((b) => b['isDeleted'] == true).length;

  int get _scannedTicketsCount => _bookings
      .where((b) => b['isScanned'] == true && b['isDeleted'] != true)
      .length;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>(); // rebuild when language changes

    final maleLimit = widget.event['maleLimit'] as int;
    final femaleLimit = widget.event['femaleLimit'] as int;
    final maleRemaining = maleLimit - _maleBookings;
    final femaleRemaining = femaleLimit - _femaleBookings;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.eventStats(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Event Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Provider.of<LanguageProvider>(context, listen: false)
                                .currentLanguage ==
                            'en'
                        ? widget.event['title_en']
                        : widget.event['title_ja'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.event['date']} • ${widget.event['startTime']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Total Bookings
          _buildStatCard(
            context,
            'Total Bookings',
            _totalBookings.toString(),
            Icons.confirmation_number,
            Theme.of(context).primaryColor,
          ),

          const SizedBox(height: 16),

          // Male Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Male Bookings',
                  '$_maleBookings / $maleLimit',
                  Icons.male,
                  AppTheme.maleColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Male Remaining',
                  maleRemaining.toString(),
                  Icons.people,
                  AppTheme.maleColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Female Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Female Bookings',
                  '$_femaleBookings / $femaleLimit',
                  Icons.female,
                  AppTheme.femaleColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Female Remaining',
                  femaleRemaining.toString(),
                  Icons.people,
                  AppTheme.femaleColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Deleted & Scanned Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Deleted Tickets',
                  _deletedTicketsCount.toString(),
                  Icons.delete_outline,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Scanned Tickets',
                  _scannedTicketsCount.toString(),
                  Icons.qr_code_scanner,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Bookings
          Text(
            'Recent Bookings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          if (_bookings.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookings yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._bookings.map((booking) {
              final isDeleted = booking['isDeleted'] ?? false;
              final isScanned = booking['isScanned'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: GenderIcon(
                    isMale: booking['gender'] == 'male',
                    size: 24,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking['userName'],
                          style: TextStyle(
                            decoration:
                                isDeleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (isDeleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DELETED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isScanned && !isDeleted)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SCANNED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    booking['timestamp'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    booking['gender'] == 'male' ? 'Male' : 'Female',
                    style: TextStyle(
                      color: booking['gender'] == 'male'
                          ? AppTheme.maleColor
                          : AppTheme.femaleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
