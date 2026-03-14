import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isDeleting = false;

  Future<void> _deleteCreator(Map<String, dynamic> creator) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Creator'),
        content: Text(
          'Delete ${creator['email']}?\n\nThis will also delete all their events and tickets. This action cannot be undone.',
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
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      // 1. Get all events by this creator and delete them (cascade deletes tickets)
      final events =
          await EventService().getEventsByCreator(creator['id']).first;
      for (final event in events) {
        // deleteEvent now automatically deletes all tickets (including scanned)
        await EventService().deleteEvent(event['id']);
      }

      // 2. Delete creator user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(creator['id'])
          .delete();

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
    context.watch<LanguageProvider>();

    return LoadingOverlay(
      isLoading: _isDeleting,
      message: 'Deleting creator...',
      child: Scaffold(
        appBar: GradientAppBar(
          title: Text(
            AppText.manageCreators(context),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _userService.getAllCreators(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

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
                      'Creators must be added from Firebase Console',
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
