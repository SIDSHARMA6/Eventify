import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/gender_icon.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final Map<String, dynamic>? event; // Optional event data for overlay

  const ImageCarousel({
    super.key,
    required this.images,
    this.height = 300,
    this.event,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel>
    with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  bool _imagesPrecached = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _precacheImages();
  }

  void _precacheImages() {
    if (_imagesPrecached) return;

    // Precache images for better performance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final imagePath in widget.images) {
        precacheImage(AssetImage(imagePath), context);
      }
      _imagesPrecached = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    context.watch<LanguageProvider>(); // rebuild when language changes

    if (widget.images.isEmpty) {
      return Container(
        height: widget.height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image,
            size: 50,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.images.length > 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.images.map((imagePath) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const SizedBox.expand(),
                );
              },
            );
          }).toList(),
        ),

        // Event Details Overlay (if event data provided)
        if (widget.event != null) _buildEventOverlay(),

        // Dots Indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildEventOverlay() {
    final event = widget.event!;
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final isEnglish = languageProvider.currentLanguage == 'en';

    final location = isEnglish ? event['location_en'] : event['location_ja'];
    final malePrice = event['malePrice'] as int;
    final femalePrice = event['femalePrice'] as int;

    return Positioned(
      bottom: 10,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Location
            Text(
              location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            // Male Price with custom icon
            GenderIcon(
              isMale: true,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              malePrice == 0 ? 'Free' : '¥$malePrice',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            // Female Price with custom icon
            GenderIcon(
              isMale: false,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              femalePrice == 0 ? 'Free' : '¥$femalePrice',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
