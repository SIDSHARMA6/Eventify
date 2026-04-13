import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as cal;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import '../../utils/helpers.dart';
import '../../utils/language_helper.dart';
import '../../widgets/clickable_text.dart';
import '../../widgets/gender_icon.dart';
import '../../config/theme.dart';
import '../../services/event_service.dart';
import '../../services/ticket_service.dart';
import '../../services/device_service.dart';
import 'booking_dialog.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isChecking = true;
  bool _isBooked = false;
  bool _disposed =
      false; // FIX-022: guard against subscription assigned after dispose
  StreamSubscription<bool>? _bookingSub;

  late final Stream<Map<String, dynamic>?> _eventStream;

  @override
  void initState() {
    super.initState();
    _eventStream = EventService().watchEvent(widget.event['id']);
    _watchBooking();
  }

  Future<void> _watchBooking() async {
    try {
      final dId = await DeviceService().getDeviceId();
      if (_disposed || !mounted) return; // FIX-022: skip if already disposed
      _bookingSub = TicketService()
          .watchReservation(dId, widget.event['id'])
          .listen((booked) {
        if (mounted) {
          setState(() {
            _isBooked = booked;
            _isChecking = false;
          });
        }
      }, onError: (_) {
        if (mounted) setState(() => _isChecking = false);
      });
    } catch (_) {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  void dispose() {
    _disposed = true; // FIX-022: set before cancel so async gap is guarded
    _bookingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _eventStream,
      builder: (context, snap) {
        final event = snap.data ?? widget.event; // fallback to initial data
        return _buildContent(context, event);
      },
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> event) {
    final isJa = context.watch<LanguageProvider>().currentLanguage == 'ja';
    final title = LanguageHelper.getEventTitle(event, isJa);
    final desc = LanguageHelper.getEventDescription(event, isJa);
    final images = LanguageHelper.getImages(event, isJa);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final hPad = screenWidth * 0.05; // 5% horizontal padding
    final heroHeight = screenHeight * 0.38;
    final galleryHeight = screenWidth * 0.6;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: images.isNotEmpty
                  ? Image.network(images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[200]))
                  : Container(color: Colors.grey[200]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  _buildDateVenueCard(context, event, isJa, screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      _buildAction(
                          context, Icons.location_on, () => _launchMap(event)),
                      SizedBox(width: screenWidth * 0.025),
                      _buildAction(
                        context,
                        Icons.share,
                        () =>
                            Share.share(AppText.shareEventText(context, title)),
                      ),
                      SizedBox(width: screenWidth * 0.025),
                      _buildAction(context, Icons.event_available,
                          () => _addToCal(event, isJa)),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  _buildGreyCard(
                    context,
                    screenWidth,
                    title: AppText.aboutEvent(context),
                    child: ClickableText(
                        text: desc,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  _buildSection(
                    AppText.pricing(context),
                    Row(children: [
                      Expanded(
                          child: _buildPrice(
                              AppText.male(context),
                              (event['malePrice'] as num?)?.toInt() ?? 0,
                              true)),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                          child: _buildPrice(
                              AppText.female(context),
                              (event['femalePrice'] as num?)?.toInt() ?? 0,
                              false)),
                    ]),
                  ),

                  // Gallery for remaining images
                  if (images.length > 1)
                    ...images.skip(1).map((img) => Padding(
                          padding:
                              EdgeInsets.only(bottom: screenHeight * 0.015),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              img,
                              width: double.infinity,
                              height: galleryHeight,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        )),

                  SizedBox(height: screenHeight * 0.12),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(hPad),
          child: _isChecking
              ? const LinearProgressIndicator()
              : _isBooked
                  ? _buildBookedIndicator()
                  : _buildBookBtn(event),
        ),
      ),
    );
  }

  Widget _buildDateVenueCard(BuildContext context, Map<String, dynamic> event,
      bool isJa, double screenWidth) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color;
    final iconBg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final iconColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    final titleColor = isDark ? Colors.grey[100]! : Colors.grey[850]!;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;
    final dividerColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenWidth * 0.035),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.access_time, size: 20, color: iconColor),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  '${Helpers.formatDateWithJapaneseDay(event['date'], isJa)}  '
                  '${Helpers.formatTo12Hour(event['startTime'])} - '
                  '${Helpers.formatTo12Hour(event['endTime'])}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.025),
            child: Divider(color: dividerColor, height: 1),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('𖠿',
                    style: TextStyle(fontSize: 18, color: iconColor)),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isJa
                          ? (event['venueName_ja'] ?? '')
                          : (event['venueName_en'] ?? ''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.038,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isJa
                          ? (event['venueAddress_ja'] ?? '')
                          : (event['venueAddress_en'] ?? ''),
                      style: TextStyle(
                        fontSize: screenWidth * 0.033,
                        color: subColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildGreyCard(BuildContext context, double screenWidth,
      {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color;
    final titleColor = isDark ? Colors.grey[100]! : Colors.grey[850]!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor)),
          SizedBox(height: screenWidth * 0.03),
          child,
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title.isNotEmpty) ...[
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
      ],
      child,
      const Divider(height: 40),
    ]);
  }

  Widget _buildPrice(String label, int price, bool isMale) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        GenderIcon(isMale: isMale, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: screenWidth * 0.03)),
        const SizedBox(height: 2),
        Text(
          price == 0 ? AppText.free(context) : '¥$price',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ]),
    );
  }

  Widget _buildBookedIndicator() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Center(
        child: Text(
          AppText.ticketBooked(context),
          style:
              const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBookBtn(Map<String, dynamic> event) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.pinkGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (_) =>
                  BookingDialog(event: event)); // FIX-023: live event data
          // Stream auto-updates _isBooked — no manual refresh needed
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
        ),
        child: Text(
          AppText.reserveTicket(context),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _launchMap(Map<String, dynamic> event) async {
    final rawLink = (event['mapLink'] as String?)?.trim();
    if (rawLink == null || rawLink.isEmpty || !rawLink.startsWith('https://')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.mapUnavailable(context))),
        );
      }
      return;
    }
    try {
      final url = Uri.parse(rawLink);
      if (await canLaunchUrl(url)) {
        if (!mounted) return;
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppText.mapError(context, e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCal(Map<String, dynamic> event, bool isJa) async {
    try {
      final date = DateTime.parse(event['date']);
      final start = (event['startTime'] as String? ?? '18:00').split(':');
      final end = (event['endTime'] as String? ?? '23:00').split(':');

      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      final key = 'cal_added_${event['id']}';
      final alreadyAdded = prefs.getBool(key) ?? false;

      // 1. Open Native Calendar (Always)
      cal.Add2Calendar.addEvent2Cal(cal.Event(
        title: LanguageHelper.getEventTitle(event, isJa),
        description: LanguageHelper.getEventDescription(event, isJa),
        location: LanguageHelper.getVenueName(event, isJa),
        startDate: DateTime(date.year, date.month, date.day,
            int.parse(start[0]), int.parse(start[1])),
        endDate: DateTime(date.year, date.month, date.day, int.parse(end[0]),
            int.parse(end[1])),
      ));

      // 2. Initial Setup: FCM + In-app confirmation
      if (!alreadyAdded) {
        await NotificationService().scheduleEventReminder(
            LanguageHelper.getEventTitle(event, isJa),
            date,
            event['startTime'] ?? '18:00');
        if (!mounted) return;

        await prefs.setBool(key, true);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.reminderScheduled(context))),
        );
      }
    } catch (_) {}
  }
}
