import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../widgets/gradient_app_bar.dart';

class ManageCreatorsScreen extends StatefulWidget {
  const ManageCreatorsScreen({super.key});

  @override
  State<ManageCreatorsScreen> createState() => _ManageCreatorsScreenState();
}

class _ManageCreatorsScreenState extends State<ManageCreatorsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
  // final userService = UserManagementService();

  // Dummy creators for demo
  final List<Map<String, dynamic>> _creators = [
    {'id': 'creator1', 'email': 'creator1@eventify.com'},
    {'id': 'creator2', 'email': 'creator2@eventify.com'},
  ];

  void _showAddCreatorDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.addCreator(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: AppText.email(context),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: AppText.password(context),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.cancel(context)),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppText.pleaseFillAllFields(context)),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              // Add to dummy data
              setState(() {
                _creators.add({
                  'id': 'creator${_creators.length + 1}',
                  'email': emailController.text,
                });
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppText.success(context))),
              );

              // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
              // try {
              //   await userService.createUser(
              //     emailController.text,
              //     passwordController.text,
              //     'creator',
              //   );
              //   if (context.mounted) {
              //     Navigator.pop(context);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text(AppText.success(context))),
              //     );
              //   }
              // } catch (e) {
              //   if (context.mounted) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text('Error: $e'),
              //         backgroundColor: Colors.red,
              //       ),
              //     );
              //   }
              // }
            },
            child: Text(AppText.add(context)),
          ),
        ],
      ),
    );
  }

  void _showEditCreatorDialog(Map<String, dynamic> creator) {
    final emailController = TextEditingController(text: creator['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.editCreator(context)),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: AppText.email(context),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.cancel(context)),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppText.emailCannotBeEmpty(context)),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              setState(() {
                creator['email'] = emailController.text;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppText.success(context))),
              );

              // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
              // try {
              //   await userService.updateUser(creator['id'], {
              //     'email': emailController.text,
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
              //       SnackBar(
              //         content: Text('Error: $e'),
              //         backgroundColor: Colors.red,
              //       ),
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

  void _showResetPasswordDialog(Map<String, dynamic> creator) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.resetPassword(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppText.resetPasswordFor(context, creator['email']),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: AppText.newPassword(context),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                labelText: AppText.confirmPassword(context),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.cancel(context)),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.isEmpty ||
                  confirmController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppText.pleaseFillAllFields(context)),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppText.passwordsDoNotMatch(context)),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppText.passwordResetSuccess(context)),
                ),
              );

              // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
              // try {
              //   await userService.resetPassword(
              //     creator['id'],
              //     passwordController.text,
              //   );
              //   if (context.mounted) {
              //     Navigator.pop(context);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text('Password reset successfully'),
              //       ),
              //     );
              //   }
              // } catch (e) {
              //   if (context.mounted) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text('Error: $e'),
              //         backgroundColor: Colors.red,
              //       ),
              //     );
              //   }
              // }
            },
            child: Text(AppText.reset(context)),
          ),
        ],
      ),
    );
  }

  void _deleteCreator(Map<String, dynamic> creator) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.deleteCreator(context)),
        content: Text(
          AppText.confirmDeleteCreator(context, creator['email']),
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
      // Delete all events created by this creator
      DummyData.events.removeWhere(
        (event) => event['createdBy'] == creator['id'],
      );

      setState(() {
        _creators.remove(creator);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppText.creatorDeletedSuccess(context)),
          ),
        );
      }

      // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
      // try {
      //   await userService.deleteUser(creator['id']);
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(AppText.success(context))),
      //     );
      //   }
      // } catch (e) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('Error: $e'),
      //         backgroundColor: Colors.red,
      //       ),
      //     );
      //   }
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<LanguageProvider>(); // rebuild when language changes
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.manageCreators(context),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCreatorDialog,
            tooltip: AppText.addCreator(context),
          ),
        ],
      ),
      body: _creators.isEmpty
          ? Center(
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
                    AppText.tapToAddCreator(context),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _creators.length,
              itemBuilder: (context, index) {
                final creator = _creators[index];
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
                      AppText.creatorId(context, creator['id']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () => Future.delayed(
                            Duration.zero,
                            () => _showEditCreatorDialog(creator),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text(AppText.edit(context)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () => Future.delayed(
                            Duration.zero,
                            () => _showResetPasswordDialog(creator),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_reset, size: 20),
                              const SizedBox(width: 8),
                              Text(AppText.resetPassword(context)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () => Future.delayed(
                            Duration.zero,
                            () => _deleteCreator(creator),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.delete,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: 8),
                              Text(
                                AppText.delete(context),
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCreatorDialog,
        child: const Icon(Icons.add),
      ),
    );

    // 🔥 FIREBASE VERSION (COMMENTED OUT FOR DEMO)
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(AppText.manageCreators(context)),
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.add),
    //         onPressed: _showAddCreatorDialog,
    //         tooltip: 'Add Creator',
    //       ),
    //     ],
    //   ),
    //   body: StreamBuilder<List<Map<String, dynamic>>>(
    //     stream: userService.getAllCreators(),
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
