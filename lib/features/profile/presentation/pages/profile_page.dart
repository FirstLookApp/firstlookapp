import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/shared/widgets/feature_placeholder_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return FeaturePlaceholderView(
      title: l10n.profileTitle,
      message: l10n.screenArchitectureReady,
      trailing: TextButton(
        onPressed: () => ref.read(authControllerProvider.notifier).logout(),
        child: Text(l10n.logoutButton),
      ),
    );
  }
}
