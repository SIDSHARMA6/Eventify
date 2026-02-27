import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/language_provider.dart';
import '../../providers/demo_data_provider.dart';
import '../../utils/app_text.dart';
import '../../utils/responsive.dart';
import '../../utils/helpers.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../widgets/clickable_text.dart';
import '../../widgets/gender_icon.dart';
import '../../widgets/gradient_app_bar.dart';
import 'booking_dialog.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // rebuild when language changes
    context.watch<DemoDataProvider>(); // rebuild when booking counts change
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isEnglish = languageProvider.currentLanguage == 'en';

    final title = isEnglish ? event['title_en'] : event['title_ja'];
    final description =
        isEnglish ? event['description_en'] : event['description_ja'];
    final images = isEnglish ? event['images_en'] : event['images_ja'];
    final malePrice = event['malePrice'] as int;
    final femalePrice = event['femalePrice'] as int;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.eventDetails(context),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Share App Button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final shareText = isEnglish
                  ? 'Check out Best Event app!\n\nApp Store: ${AppConstants.appStoreUrl}\nGoogle Play: ${AppConstants.playStoreUrl}'
                  : 'Best Eventアプリをチェック！\n\nApp Store: ${AppConstants.appStoreUrl}\nGoogle Play: ${AppConstants.playStoreUrl}';
              Share.share(shareText);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Image Only
            if ((images as List<String>).isNotEmpty)
              Image.asset(
                images[0],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                cacheWidth: 800, // Optimize memory usage
                cacheHeight: 500,
              ),

            Padding(
              padding: EdgeInsets.all(Responsive.padding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Date and Time
                  _buildInfoRow(
                    context,
                    Icons.calendar_today,
                    Helpers.formatDateWithJapaneseDay(
                        event['date'], !isEnglish),
                  ),

                  const SizedBox(height: 8),

                  _buildInfoRow(
                    context,
                    Icons.access_time,
                    '${event['startTime']} - ${event['endTime']}',
                  ),

                  const SizedBox(height: 8),

                  _buildInfoRow(
                    context,
                    Icons.location_on,
                    isEnglish
                        ? (event['venueName_en'] ?? event['venueName'] ?? '')
                        : (event['venueName_ja'] ?? event['venueName'] ?? ''),
                  ),

                  const SizedBox(height: 16),

                  // Venue Address Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.place,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEnglish ? 'Venue Address' : '会場住所',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEnglish
                              ? (event['venueAddress_en'] ??
                                  'Address not available')
                              : (event['venueAddress_ja'] ?? '住所が利用できません'),
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // View Map Button
                  InkWell(
                    onTap: () async {
                      final rawLink = (event['mapLink'] as String?)?.trim();
                      final link = (rawLink == null || rawLink.isEmpty)
                          ? 'https://maps.google.com'
                          : rawLink;
                      final url = Uri.parse(link);
                      try {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (_) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.pinkGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.map,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppText.viewMap(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Description with clickable links
                  ClickableText(
                    text: description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const Divider(height: 32),

                  // Pricing
                  Text(
                    isEnglish ? 'Pricing' : '料金',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceCard(
                          context,
                          AppText.male(context),
                          malePrice,
                          true, // isMale
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPriceCard(
                          context,
                          AppText.female(context),
                          femalePrice,
                          false, // isMale
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Remaining Images at Bottom
            if ((images as List<String>).length > 1)
              ...(images as List<String>).skip(1).map((imagePath) {
                return Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  cacheWidth: 800, // Optimize memory usage
                  cacheHeight: 500,
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.appBarGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => BookingDialog(event: event),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
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
          GenderIcon(
            isMale: isMale,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
