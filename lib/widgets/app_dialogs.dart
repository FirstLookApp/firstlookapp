import 'package:firstlook/localization/app_localizations.dart';
import 'package:flutter/material.dart';

abstract final class AppDialogs {
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final AppLocalizations? l10n = AppLocalizations.of(context);

        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n?.commonCancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n?.commonConfirm ?? 'Confirm'),
            ),
          ],
        );
      },
    );
  }
}
