import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/language_helper.dart';
import 'gender_icon.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final Map<String, dynamic>? event;
  const ImageCarousel({super.key, required this.images, this.height = 300, this.event});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return Container(height: widget.height, color: Colors.grey[200], child: const Icon(Icons.image, size: 50));

    return Stack(children: [
      CarouselSlider(
        options: CarouselOptions(height: widget.height, viewportFraction: 1, onPageChanged: (i, _) => setState(() => _idx = i)),
        items: widget.images.map((img) => Container(width: double.infinity, decoration: BoxDecoration(image: DecorationImage(image: img.startsWith('http') ? NetworkImage(img) : AssetImage(img) as ImageProvider, fit: BoxFit.cover)))).toList(),
      ),
      if (widget.event != null) _overlay(),
      if (widget.images.length > 1) Positioned(bottom: 10, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.images.asMap().entries.map((e) => Container(width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: _idx == e.key ? Colors.white : Colors.white38))).toList())),
    ]);
  }

  Widget _overlay() {
    final e = widget.event!;
    final isJa = LanguageHelper.isJapanese(context);
    return Positioned(bottom: 10, left: 12, right: 12, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text(isJa ? (e['location_ja'] ?? '') : (e['location_en'] ?? ''), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const Spacer(),
        const GenderIcon(isMale: true, size: 14), Text(' ¥${e['malePrice']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(width: 10),
        const GenderIcon(isMale: false, size: 14), Text(' ¥${e['femalePrice']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
      ]),
    ));
  }
}
