import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../widgets/image_carousel.dart';
import '../utils/responsive.dart';
import '../utils/helpers.dart';
import '../utils/app_text.dart';
import '../utils/language_helper.dart';
import '../config/theme.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // rebuild when language changes
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isJapanese = languageProvider.currentLanguage == 'ja';
    final isEnglish = !isJapanese; // For backward compatibility

    // Use helper with fallback
    final title = LanguageHelper.getEventTitle(event, isJapanese);
    final venueName = LanguageHelper.getVenueName(event, isJapanese);
    final images = LanguageHelper.getImages(event, isJapanese);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context),
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel with event details overlay
          ImageCarousel(
            images: images,
            event: event,
          ),

          // Clickable content area (title, date, venue)
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title (clickable)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Date and Time (clickable) - New format
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          Helpers.formatDateTimeRange(
                            event['date'],
                            event['startTime'],
                            event['endTime'],
                            !isEnglish,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Venue Name and View Map — equal width
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.pinkGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '𖠿',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  venueName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // View Map Button
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final rawLink =
                                (event['mapLink'] as String?)?.trim();
                            if (rawLink == null ||
                                rawLink.isEmpty ||
                                !rawLink.startsWith('https://')) {
                              final url = Uri.parse('https://maps.google.com');
                              try {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } catch (_) {}
                              return;
                            }
                            final url = Uri.parse(rawLink);
                            try {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            } catch (_) {}
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.pinkGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.place,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppText.viewMap(context),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
