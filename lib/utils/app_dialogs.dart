import 'package:flutter/material.dart';
import 'app_text.dart';

/// Shared dialog helpers — prevents duplicate dialog code across screens.
class AppDialogs {
  /// Shows a logout confirmation dialog.
  /// Returns true if user confirmed, false/null otherwise.
  static Future<bool> confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppText.logout(context)),
        content: Text(AppText.confirmLogout(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppText.no(context)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppText.yes(context)),
          ),
        ],
      ),
    );
    return result == true;
  }
}
