import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../widgets/image_carousel.dart';
import '../utils/responsive.dart';
import '../utils/helpers.dart';
import '../utils/app_text.dart';
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
    final isEnglish = languageProvider.currentLanguage == 'en';

    final title = isEnglish ? event['title_en'] : event['title_ja'];
    final venueName = isEnglish
        ? (event['venueName_en'] ?? event['venueName'] ?? '')
        : (event['venueName_ja'] ?? event['venueName'] ?? '');

    // Safely convert images to List<String> - use cast for better performance
    final imagesRaw = isEnglish ? event['images_en'] : event['images_ja'];
    final List<String> images;
    if (imagesRaw is List<String>) {
      images = imagesRaw;
    } else if (imagesRaw is List) {
      images = imagesRaw.cast<String>();
    } else {
      images = <String>[];
    }

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

                  // Venue Name and View Map Button
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Venue Name Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.pinkGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          venueName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

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
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.pinkGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.map,
                                size: 14,
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
