import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import '../../services/user_management_service.dart';
import '../../services/event_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/loading_overlay.dart';
import 'creator_detail_screen.dart';

class ManageCreatorsScreen extends StatefulWidget {
  const ManageCreatorsScreen({super.key});

  @override
  State<ManageCreatorsScreen> createState() => _ManageCreatorsScreenState();
}

class _ManageCreatorsScreenState extends State<ManageCreatorsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _userService = UserManagementService();
  late final Stream<List<Map<String, dynamic>>> _creatorsStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _creatorsStream = _userService.getAllCreators();
  }

  Future<void> _deleteCreator(Map<String, dynamic> creator) async {
    final isJa = context.read<LanguageProvider>().currentLanguage == 'ja';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppText.deleteCreator(context)),
          content: Text(
            isJa
                ? '${creator['email']}を削除しますか？\n\nすべてのイベントとチケットも削除され、元に戻せません。'
                : 'Delete ${creator['email']}?\n\nThis will also delete all their events and tickets. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppText.cancel(context)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppText.delete(context)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      // 1. Get all events by this creator and delete them (cascade deletes tickets)
      final events = await EventService().getEventsByCreatorOnce(creator['id']);
      for (final event in events) {
        await EventService().deleteEvent(event['id']);
      }

      // 2. Delete creator user document
      await UserManagementService().deleteCreator(creator['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.success(context))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadingOverlay(
      isLoading: _isDeleting,
      message: AppText.deletingCreator(context),
      child: Scaffold(
        appBar: GradientAppBar(
          title: Text(
            AppText.manageCreators(context),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _creatorsStream,
          builder: (context, snapshot) {
            context.watch<LanguageProvider>();

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final creators = snapshot.data ?? [];

            if (creators.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppText.noCreatorsYet(context),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppText.creatorsMustBeAddedFromConsole(context),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: creators.length,
              itemBuilder: (context, index) {
                final creator = creators[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        creator['email']?.substring(0, 1).toUpperCase() ?? 'C',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    title: Text(
                      creator['email'] ?? 'No email',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'ID: ${creator['id']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Theme.of(context).colorScheme.error,
                          onPressed: () => _deleteCreator(creator),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreatorDetailScreen(creator: creator),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
