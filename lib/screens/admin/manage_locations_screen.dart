import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_text.dart';
import '../../providers/language_provider.dart';
import '../../services/location_management_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/loading_overlay.dart';

class ManageLocationsScreen extends StatefulWidget {
  const ManageLocationsScreen({super.key});

  @override
  State<ManageLocationsScreen> createState() => _ManageLocationsScreenState();
}

class _ManageLocationsScreenState extends State<ManageLocationsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _locationService = LocationManagementService();
  bool _isLoading = false;

  void _showLocationDialog({Map<String, dynamic>? location}) async {
    final isEditing = location != null;
    final nameEnController =
        TextEditingController(text: location?['name_en'] ?? '');
    final nameJaController =
        TextEditingController(text: location?['name_ja'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing
            ? AppText.editLocation(context)
            : AppText.addLocation(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEnController,
              decoration: InputDecoration(
                labelText: AppText.nameEnglish(context),
                hintText: isEditing ? null : 'e.g., Tokyo',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameJaController,
              decoration: InputDecoration(
                labelText: AppText.nameJapanese(context),
                hintText: isEditing ? null : 'e.g., 東京',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.cancel(context)),
          ),
          TextButton(
            onPressed: () async {
              if (nameEnController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppText.pleaseEnterEnglishName(context))),
                );
                return;
              }
              final messenger = ScaffoldMessenger.of(context);
              final successMsg = AppText.success(context);
              Navigator.pop(context); // close dialog first
              setState(() => _isLoading = true);
              try {
                if (isEditing) {
                  await _locationService.updateLocation(location['id'], {
                    'name_en': nameEnController.text.trim(),
                    'name_ja': nameJaController.text.trim(),
                  });
                } else {
                  await _locationService.createLocation({
                    'name_en': nameEnController.text.trim(),
                    'name_ja': nameJaController.text.trim(),
                    'order': 999,
                  });
                }
                if (mounted) {
                  messenger.showSnackBar(
                      SnackBar(content: Text(successMsg)));
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: Text(AppText.save(context)),
          ),
        ],
      ),
    );
  }

  void _deleteLocation(Map<String, dynamic> location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.deleteLocation(context)),
        content: Text(
          AppText.confirmDeleteLocation(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppText.cancel(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppText.delete(context),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _locationService.deleteLocation(location['id']);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(AppText.success(context))));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>();

    return LoadingOverlay(
        isLoading: _isLoading,
        child: Scaffold(
          appBar: GradientAppBar(
            title: Text(
              AppText.manageLocations(context),
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showLocationDialog(),
              ),
            ],
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _locationService.getAllLocations(),
            builder: (context, snapshot) {
              final locations = snapshot.data ?? [];

              if (snapshot.connectionState == ConnectionState.waiting &&
                  locations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (locations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppText.noLocationsYet(context),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showLocationDialog(),
                        icon: const Icon(Icons.add),
                        label: Text(AppText.addLocation(context)),
                      ),
                    ],
                  ),
                );
              }

              return ReorderableListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: locations.length,
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final reordered = List<Map<String, dynamic>>.from(locations);
                  final item = reordered.removeAt(oldIndex);
                  reordered.insert(newIndex, item);
                  // Update order field in Firestore
                  for (int i = 0; i < reordered.length; i++) {
                    await _locationService
                        .updateLocation(reordered[i]['id'], {'order': i});
                  }
                },
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return Card(
                    key: ValueKey(location['id'] ?? location['name_en']),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        location['name_en'] ?? 'No name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        location['name_ja'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () =>
                                _showLocationDialog(location: location),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                size: 20,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: () => _deleteLocation(location),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )); // LoadingOverlay
  }
}
