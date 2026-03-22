import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/content_service.dart';
import '../widgets/gradient_app_bar.dart';

class PolicyContentScreen extends StatefulWidget {
  final String docId;
  final String titleEn;
  final String titleJa;

  const PolicyContentScreen({
    super.key,
    required this.docId,
    required this.titleEn,
    required this.titleJa,
  });

  @override
  State<PolicyContentScreen> createState() => _PolicyContentScreenState();
}

class _PolicyContentScreenState extends State<PolicyContentScreen> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentService().getContent(widget.docId);
  }

  @override
  Widget build(BuildContext context) {
    final isEn =
        Provider.of<LanguageProvider>(context, listen: false).currentLanguage ==
            'en';

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          isEn ? widget.titleEn : widget.titleJa,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          final enContent = (data?['en'] as String? ?? '').trim();
          final jaContent = (data?['ja'] as String? ?? '').trim();
          final content = isEn
              ? (enContent.isNotEmpty ? enContent : jaContent)
              : (jaContent.isNotEmpty ? jaContent : enContent);

          if (content.isEmpty) {
            return Center(
              child: Text(
                isEn ? 'Coming soon.' : '準備中です。',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Text(content,
                style: const TextStyle(fontSize: 15, height: 1.7)),
          );
        },
      ),
    );
  }
}
