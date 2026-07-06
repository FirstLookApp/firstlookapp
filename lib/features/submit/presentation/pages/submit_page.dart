import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/widgets/app_snackbar.dart';
import 'package:firstlook/widgets/firstlook_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitPage extends ConsumerStatefulWidget {
  const SubmitPage({super.key});

  @override
  ConsumerState<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends ConsumerState<SubmitPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _videoUrl = TextEditingController();
  final TextEditingController _appStoreUrl = TextEditingController();
  final TextEditingController _googlePlayUrl = TextEditingController();

  int _selectedCategoryIndex = 1;
  PlatformType _selectedPlatform = PlatformType.android;
  SubmitDestination _selectedDestination = SubmitDestination.drop;
  List<PlatformFile> _screenshots = <PlatformFile>[];

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _videoUrl.dispose();
    _appStoreUrl.dispose();
    _googlePlayUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final List<String> categories = <String>[
      l10n.submitCategoryGame,
      l10n.submitCategoryFinance,
      l10n.submitCategoryEducation,
    ];
    final AsyncValue<String?> submitState =
        ref.watch(submitApplicationControllerProvider);

    ref.listen<AsyncValue<String?>>(
      submitApplicationControllerProvider,
      (AsyncValue<String?>? previous, AsyncValue<String?> next) {
        next.whenOrNull(
          data: (String? applicationId) {
            if (applicationId == null || applicationId.isEmpty) {
              return;
            }

            _clearForm();
            AppSnackbar.show(context, message: l10n.submitSuccess);
          },
          error: (Object error, StackTrace stackTrace) {
            AppSnackbar.show(context, message: error.toString());
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 92),
              children: <Widget>[
                const FirstLookAppHeader(),
                const SizedBox(height: 22),
                Text(
                  l10n.submitTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.submitSubtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  controller: _name,
                  label: l10n.submitNameLabel,
                  hint: l10n.submitNameHint,
                ),
                const SizedBox(height: 16),
                _Label(text: l10n.submitCategory),
                const SizedBox(height: 8),
                _ChipRow(
                  values: categories,
                  selected: categories[_selectedCategoryIndex],
                  onChanged: (String value) => setState(
                    () => _selectedCategoryIndex = categories.indexOf(value),
                  ),
                ),
                const SizedBox(height: 16),
                _Label(text: l10n.submitScreenshotsLabel),
                const SizedBox(height: 8),
                _ScreenshotPickerPreview(
                  files: _screenshots,
                  pickLabel: l10n.submitPickScreenshots,
                  onPick: _pickScreenshots,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _videoUrl,
                  label: l10n.submitVideoUrl,
                  hint: l10n.submitVideoUrlHint,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _description,
                  label: l10n.submitDescription,
                  hint: l10n.submitDescriptionHint,
                ),
                const SizedBox(height: 16),
                _Label(text: l10n.submitPlatform),
                const SizedBox(height: 8),
                _SegmentedControl<PlatformType>(
                  values: const <PlatformType>[
                    PlatformType.android,
                    PlatformType.ios,
                    PlatformType.both,
                  ],
                  selected: _selectedPlatform,
                  labelBuilder: (PlatformType platform) => switch (platform) {
                    PlatformType.android => l10n.androidTab,
                    PlatformType.ios => l10n.iosTab,
                    PlatformType.both => l10n.submitBothPlatforms,
                  },
                  onChanged: (PlatformType value) =>
                      setState(() => _selectedPlatform = value),
                ),
                const SizedBox(height: 16),
                _Label(text: l10n.submitStoreLinks),
                const SizedBox(height: 8),
                AuthTextField(
                  controller: _googlePlayUrl,
                  label: l10n.submitGooglePlayUrl,
                  hint: l10n.submitGooglePlayUrl,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _appStoreUrl,
                  label: l10n.submitAppStoreUrl,
                  hint: l10n.submitAppStoreUrl,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                _SegmentedControl<SubmitDestination>(
                  values: const <SubmitDestination>[
                    SubmitDestination.drop,
                    SubmitDestination.test,
                  ],
                  selected: _selectedDestination,
                  labelBuilder: (SubmitDestination destination) =>
                      switch (destination) {
                    SubmitDestination.drop => l10n.submitApplyDrop,
                    SubmitDestination.test => l10n.submitAddTest,
                  },
                  onChanged: (SubmitDestination value) =>
                      setState(() => _selectedDestination = value),
                ),
                const SizedBox(height: 16),
                AuthPrimaryButton(
                  label: l10n.submitButton,
                  isLoading: submitState.isLoading,
                  onPressed: () => _submit(l10n, categories),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickScreenshots() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _screenshots = result.files
          .where((PlatformFile file) => file.path != null)
          .take(5)
          .toList(growable: false);
    });
  }

  void _submit(AppLocalizations l10n, List<String> categories) {
    final String name = _name.text.trim();
    final String description = _description.text.trim();

    if (name.isEmpty || description.isEmpty) {
      AppSnackbar.show(context, message: l10n.submitRequiredFields);
      return;
    }

    ref.read(submitApplicationControllerProvider.notifier).submit(
          SubmitApplicationPayload(
            name: name,
            category: categories[_selectedCategoryIndex],
            description: description,
            videoUrl: _videoUrl.text.trim(),
            platform: _selectedPlatform,
            appStoreUrl: _appStoreUrl.text.trim(),
            googlePlayUrl: _googlePlayUrl.text.trim(),
            destination: _selectedDestination,
            screenshotPaths: _screenshots
                .map((PlatformFile file) => file.path)
                .whereType<String>()
                .toList(growable: false),
          ),
        );
  }

  void _clearForm() {
    _name.clear();
    _description.clear();
    _videoUrl.clear();
    _appStoreUrl.clear();
    _googlePlayUrl.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedCategoryIndex = 1;
      _selectedPlatform = PlatformType.android;
      _selectedDestination = SubmitDestination.drop;
      _screenshots = <PlatformFile>[];
    });
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF62626A),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: values.map((String value) {
        final bool isSelected = value == selected;

        return ChoiceChip(
          selected: isSelected,
          label: Text(value),
          selectedColor: Colors.black,
          backgroundColor: const Color(0xFFF4F4F6),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onSelected: (_) => onChanged(value),
        );
      }).toList(),
    );
  }
}

class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: values.map((T value) {
          final bool isSelected = value == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  labelBuilder(value),
                  style: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScreenshotPickerPreview extends StatelessWidget {
  const _ScreenshotPickerPreview({
    required this.files,
    required this.pickLabel,
    required this.onPick,
  });

  final List<PlatformFile> files;
  final String pickLabel;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ScreenshotSlot(
              file: files.isEmpty ? null : files.first,
              onPick: onPick,
              pickLabel: pickLabel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ScreenshotSlot(
              file: files.length < 2 ? null : files[1],
              onPick: onPick,
              pickLabel: files.isEmpty ? pickLabel : '${files.length}/5',
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenshotSlot extends StatelessWidget {
  const _ScreenshotSlot({
    required this.file,
    required this.onPick,
    required this.pickLabel,
  });

  final PlatformFile? file;
  final VoidCallback onPick;
  final String pickLabel;

  @override
  Widget build(BuildContext context) {
    final String? path = file?.path;

    return GestureDetector(
      onTap: onPick,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FA),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: path == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pickLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }
}
