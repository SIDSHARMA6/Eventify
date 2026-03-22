import 'package:flutter/material.dart';
import '../../services/content_service.dart';
import '../../widgets/gradient_app_bar.dart';

// ── Section list screen ───────────────────────────────────────────────────────
class AdminPolicyEditorScreen extends StatelessWidget {
  const AdminPolicyEditorScreen({super.key});

  static const _sections = [
    {'id': 'about_app', 'label': 'About App', 'icon': Icons.info_outline},
    {
      'id': 'privacy_policy',
      'label': 'Privacy Policy',
      'icon': Icons.privacy_tip_outlined
    },
    {
      'id': 'commercial_disclosure',
      'label': 'Commercial Disclosure',
      'icon': Icons.business_outlined
    },
    {
      'id': 'cancellation_policy',
      'label': 'Cancellation Policy',
      'icon': Icons.cancel_outlined
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('App Content', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final s = _sections[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Icon(s['icon'] as IconData,
                    color: Theme.of(context).primaryColor),
              ),
              title: Text(s['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Tap to add / edit content'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _PolicyEditScreen(
                    docId: s['id'] as String,
                    title: s['label'] as String,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Individual section editor ─────────────────────────────────────────────────
class _PolicyEditScreen extends StatefulWidget {
  final String docId;
  final String title;

  const _PolicyEditScreen({required this.docId, required this.title});

  @override
  State<_PolicyEditScreen> createState() => _PolicyEditScreenState();
}

class _PolicyEditScreenState extends State<_PolicyEditScreen> {
  final _enCtrl = TextEditingController();
  final _jaCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _enCtrl.dispose();
    _jaCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await ContentService().getContent(widget.docId);
    if (data != null) {
      _enCtrl.text = data['en'] ?? '';
      _jaCtrl.text = data['ja'] ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ContentService().saveContent(
      widget.docId,
      _enCtrl.text.trim(),
      _jaCtrl.text.trim(),
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _enCtrl,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: 'English Content',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _jaCtrl,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: '日本語コンテンツ (任意)',
                      hintText: 'Optional — leave blank to use English content',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
