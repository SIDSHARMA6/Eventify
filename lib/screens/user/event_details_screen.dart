import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import '../../utils/helpers.dart';
import '../../utils/language_helper.dart';
import '../../config/constants.dart';
import '../../widgets/clickable_text.dart';
import '../../widgets/gender_icon.dart';
import '../../services/ticket_service.dart';
import '../../services/device_service.dart';
import '../../services/notification_service.dart';
import 'booking_dialog.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isCheckingBooking = true;
  bool _isAlreadyBooked = false;

  @override
  void initState() {
    super.initState();
    _checkExistingBooking();
  }

  Future<void> _checkExistingBooking() async {
    try {
      final deviceId = await DeviceService().getDeviceId();
      final booked = await TicketService()
          .hasExistingReservation(deviceId, widget.event['id']);
      if (mounted) {
        setState(() {
          _isAlreadyBooked = booked;
          _isCheckingBooking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isCheckingBooking = false);
    }
  }

  Future<void> _openBookingDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BookingDialog(event: widget.event),
    );
    if (mounted) {
      await _checkExistingBooking();
      if (result == true && mounted) {
        setState(() => _isAlreadyBooked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isJapanese = languageProvider.currentLanguage == 'ja';
    final isEnglish = !isJapanese;

    final title = LanguageHelper.getEventTitle(widget.event, isJapanese);
    final description =
        LanguageHelper.getEventDescription(widget.event, isJapanese);
    final images = LanguageHelper.getImages(widget.event, isJapanese);
    final malePrice = widget.event['malePrice'] as int;
    final femalePrice = widget.event['femalePrice'] as int;

    return Scaffold(
      body: Stack(
        children: [
          // Full screen scrollable content
          CustomScrollView(
            slivers: [
              // Image Header - No AppBar
              SliverAppBar(
                expandedHeight: 400,
                pinned: false,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: images.isNotEmpty
                      ? (images[0].startsWith('http')
                          ? Image.network(
                              images[0],
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Container(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            )
                          : Image.asset(
                              images[0],
                              fit: BoxFit.cover,
                            ))
                      : Container(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),

              // Bottom Sheet Style Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      // Content Container
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Event Title - Centered
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            // Share Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final shareText = isEnglish
                                      ? 'Check out Best Evento app!\n\nApp Store: ${AppConstants.appStoreUrl}\nGoogle Play: ${AppConstants.playStoreUrl}'
                                      : 'Best Eventoアプリをチェック！\n\nApp Store: ${AppConstants.appStoreUrl}\nGoogle Play: ${AppConstants.playStoreUrl}';
                                  Share.share(shareText);
                                },
                                icon: const Icon(Icons.share),
                                label: Text(AppText.shareApp(context)),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Date & Location Section
                            _buildSection(
                              context,
                              title: isEnglish ? 'Date & Location' : '日時と場所',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Helpers.formatDateWithJapaneseDay(
                                        widget.event['date'], !isEnglish),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 20,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${Helpers.formatTo12Hour(widget.event['startTime'])} - ${Helpers.formatTo12Hour(widget.event['endTime'])}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        // Schedule notification reminder
                                        await NotificationService()
                                            .scheduleEventReminder(
                                          title,
                                          DateTime.parse(widget.event['date']),
                                          widget.event['startTime'],
                                        );

                                        if (!mounted) return;

                                        Navigator.popUntil(
                                            context, (route) => route.isFirst);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEnglish
                                                  ? 'Reminder set! You\'ll be notified 1 hour before the event'
                                                  : 'リマインダーを設定しました！イベントの1時間前に通知します',
                                            ),
                                            duration:
                                                const Duration(seconds: 3),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.calendar_today,
                                          size: 18),
                                      label:
                                          Text(AppText.addToCalendar(context)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 20,
                                          color:
                                              Theme.of(context).primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          isEnglish
                                              ? (widget.event['location_en'] ??
                                                  '')
                                              : (widget.event['location_ja'] ??
                                                  ''),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final rawLink =
                                            (widget.event['mapLink'] as String?)
                                                ?.trim();
                                        final link =
                                            (rawLink == null || rawLink.isEmpty)
                                                ? 'https://maps.google.com'
                                                : rawLink;
                                        final url = Uri.parse(link);
                                        try {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } catch (_) {}
                                      },
                                      icon: const Icon(Icons.map, size: 18),
                                      label: Text(AppText.viewMap(context)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Venue Section
                            _buildSection(
                              context,
                              title: AppText.venue(context),
                              child: Row(
                                children: [
                                  const Text('𖠿',
                                      style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isEnglish
                                              ? (widget.event['venueName_en'] ??
                                                  widget.event['venueName'] ??
                                                  '')
                                              : (widget.event['venueName_ja'] ??
                                                  widget.event['venueName'] ??
                                                  ''),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isEnglish
                                              ? (widget.event[
                                                      'venueAddress_en'] ??
                                                  'Address not available')
                                              : (widget.event[
                                                      'venueAddress_ja'] ??
                                                  '住所が利用できません'),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Description Section
                            _buildSection(
                              context,
                              title: isEnglish ? 'About Event' : 'イベントについて',
                              child: ClickableText(
                                text: description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Pricing Section
                            _buildSection(
                              context,
                              title: AppText.pricing(context),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildPriceCard(
                                      context,
                                      AppText.male(context),
                                      malePrice,
                                      true,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildPriceCard(
                                      context,
                                      AppText.female(context),
                                      femalePrice,
                                      false,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // Remaining Images
                      if (images.length > 1)
                        ...images.skip(1).map((imagePath) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: imagePath.startsWith('http')
                                ? Image.network(
                                    imagePath,
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => Container(
                                      height: 250,
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  )
                                : Image.asset(
                                    imagePath,
                                    width: double.infinity,
                                    height: 250,
                                    fit: BoxFit.cover,
                                  ),
                          );
                        }),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isCheckingBooking
              ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : _isAlreadyBooked
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            isJapanese
                                ? 'チケット取得済み'
                                : "You're In! Ticket Booked",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFE008B), Color(0xFFFF00FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _openBookingDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppText.reserveTicket(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceCard(
      BuildContext context, String label, int price, bool isMale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GenderIcon(isMale: isMale, size: 32),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            price == 0 ? AppText.free(context) : '¥$price',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
