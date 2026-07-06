import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/shared/widgets/feature_placeholder_view.dart';
import 'package:flutter/material.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return FeaturePlaceholderView(
      title: l10n.homeTitle,
      message: l10n.screenArchitectureReady,
    );
  }
}
