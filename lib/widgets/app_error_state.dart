import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/widgets/app_button.dart';
import 'package:flutter/material.dart';

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.message,
    this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AppButton(
                label: AppLocalizations.of(context)?.commonRetry ?? 'Retry',
                onPressed: onRetry,
              ),
            ),
        ],
      ),
    );
  }
}
