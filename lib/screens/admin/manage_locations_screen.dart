import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../providers/demo_data_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/gradient_app_bar.dart';

class ManageLocationsScreen extends StatefulWidget {
  const ManageLocationsScreen({super.key});

  @override
  State<ManageLocationsScreen> createState() => _ManageLocationsScreenState();
}

class _ManageLocationsScreenState extends State<ManageLocationsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
  // final locationService = LocationManagementService();

  void _showAddLocationDialog() async {
    final nameEnController = TextEditingController();
    final nameJaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.addLocation(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEnController,
              decoration: InputDecoration(
                labelText: AppText.nameEnglish(context),
                hintText: 'e.g., Tokyo',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameJaController,
              decoration: InputDecoration(
                labelText: AppText.nameJapanese(context),
                hintText: 'e.g., 東京',
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
              if (nameEnController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppText.pleaseEnterEnglishName(context))),
                );
                return;
              }

              setState(() {
                DummyData.locations.add({
                  'name_en': nameEnController.text.trim(),
                  'name_ja': nameJaController.text.trim(),
                });
              });

              // Save to SharedPreferences
              await LocalStorageService.saveLocations();

              // Notify other screens to refresh
              if (context.mounted) {
                Provider.of<DemoDataProvider>(context, listen: false)
                    .notifyDataChanged();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppText.success(context))),
                );
              }

              // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
              // try {
              //   await service.createLocation({
              //     'name_en': nameEnController.text.trim(),
              //     'name_ja': nameJaController.text.trim(),
              //     'order': 999,
              //   });
              //   if (context.mounted) {
              //     Navigator.pop(context);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text(AppText.success(context))),
              //     );
              //   }
              // } catch (e) {
              //   if (context.mounted) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('Error: $e')),
              //     );
              //   }
              // }
            },
            child: Text(AppText.save(context)),
          ),
        ],
      ),
    );
  }

  void _showEditLocationDialog(Map<String, dynamic> location) async {
    final nameEnController = TextEditingController(text: location['name_en']);
    final nameJaController = TextEditingController(text: location['name_ja']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.editLocation(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEnController,
              decoration: InputDecoration(
                labelText: AppText.nameEnglish(context),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameJaController,
              decoration: InputDecoration(
                labelText: AppText.nameJapanese(context),
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
              setState(() {
                location['name_en'] = nameEnController.text.trim();
                location['name_ja'] = nameJaController.text.trim();
              });

              // Save to SharedPreferences
              await LocalStorageService.saveLocations();

              // Notify other screens to refresh
              if (context.mounted) {
                Provider.of<DemoDataProvider>(context, listen: false)
                    .notifyDataChanged();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppText.success(context))),
                );
              }

              // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
              // try {
              //   await service.updateLocation(location['id'], {
              //     'name_en': nameEnController.text.trim(),
              //     'name_ja': nameJaController.text.trim(),
              //   });
              //   if (context.mounted) {
              //     Navigator.pop(context);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text(AppText.success(context))),
              //     );
              //   }
              // } catch (e) {
              //   if (context.mounted) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('Error: $e')),
              //     );
              //   }
              // }
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
      setState(() {
        DummyData.locations.remove(location);
      });

      // Save to SharedPreferences
      await LocalStorageService.saveLocations();

      // Notify other screens to refresh
      if (mounted) {
        Provider.of<DemoDataProvider>(context, listen: false)
            .notifyDataChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.success(context))),
        );
      }

      // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
      // try {
      //   await locationService.deleteLocation(location['id']);
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(AppText.success(context))),
      //     );
      //   }
      // } catch (e) {
      //   if (context.mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Error: $e')),
      //     );
      //   }
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>(); // rebuild when language changes

    // Using dummy data for demo
    final locations = DummyData.locations;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.manageLocations(context),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddLocationDialog,
          ),
        ],
      ),
      body: locations.isEmpty
          ? Center(
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
                    onPressed: _showAddLocationDialog,
                    icon: const Icon(Icons.add),
                    label: Text(AppText.addLocation(context)),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: locations.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = locations.removeAt(oldIndex);
                  locations.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final location = locations[index];
                return Card(
                  key: ValueKey(location['name_en']),
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
                          onPressed: () => _showEditLocationDialog(location),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        child: const Icon(Icons.add),
      ),
    );

    // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(AppText.manageLocations(context)),
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.add),
    //         onPressed: () => _showAddLocationDialog(context, locationService),
    //       ),
    //     ],
    //   ),
    //   body: StreamBuilder<List<Map<String, dynamic>>>(
    //     stream: locationService.getAllLocations(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Center(child: CircularProgressIndicator());
    //       }
    //       // ... rest of Firebase implementation
    //     },
    //   ),
    // );
  }
}
