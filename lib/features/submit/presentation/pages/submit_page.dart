import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_button.dart';
import 'package:firstlook/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _videoUrl = TextEditingController();
  final TextEditingController _appStoreUrl = TextEditingController();
  final TextEditingController _googlePlayUrl = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _description.dispose();
    _videoUrl.dispose();
    _appStoreUrl.dispose();
    _googlePlayUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.large),
          children: <Widget>[
            Text(
              l10n.submitTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            AppTextField(controller: _name, label: l10n.submitName),
            const SizedBox(height: 12),
            AppTextField(controller: _category, label: l10n.submitCategory),
            const SizedBox(height: 12),
            AppTextField(
              controller: _description,
              label: l10n.submitDescription,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _videoUrl, label: l10n.submitVideoUrl),
            const SizedBox(height: 12),
            AppTextField(
                controller: _appStoreUrl, label: l10n.submitAppStoreUrl),
            const SizedBox(height: 12),
            AppTextField(
                controller: _googlePlayUrl, label: l10n.submitGooglePlayUrl),
            const SizedBox(height: 18),
            Text(l10n.submitScreenshotsTodo),
            const SizedBox(height: 18),
            AppButton(
              label: l10n.submitButton,
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}
