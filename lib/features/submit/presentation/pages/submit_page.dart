import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_snackbar.dart';
import 'package:firstlook/widgets/firstlook_app_header.dart';
import 'package:firstlook/widgets/firstlook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SubmitPage extends ConsumerStatefulWidget {
  const SubmitPage({this.applicationToEdit, super.key});

  final ApplicationDetail? applicationToEdit;

  @override
  ConsumerState<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends ConsumerState<SubmitPage> {
  static const int _minScreenshotCount = 3;
  static const int _maxScreenshotCount = 5;
  static const int _maxScreenshotSizeBytes = 2 * 1024 * 1024;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _videoUrl = TextEditingController();
  final TextEditingController _appStoreUrl = TextEditingController();
  final TextEditingController _googlePlayUrl = TextEditingController();

  String? _selectedCategory;
  PlatformType _selectedPlatform = PlatformType.android;
  List<PlatformFile> _screenshots = <PlatformFile>[];
  List<String> _existingScreenshots = <String>[];
  bool _hasAttemptedSubmit = false;

  bool get _isEditing => widget.applicationToEdit != null;

  bool get _showsAndroidField {
    return _selectedPlatform == PlatformType.android ||
        _selectedPlatform == PlatformType.both;
  }

  bool get _showsIosField {
    return _selectedPlatform == PlatformType.ios ||
        _selectedPlatform == PlatformType.both;
  }

  @override
  void initState() {
    super.initState();
    final ApplicationDetail? application = widget.applicationToEdit;
    if (application != null) {
      _name.text = application.name;
      _description.text = application.description;
      _videoUrl.text = application.videoUrl;
      _appStoreUrl.text = application.appStoreUrl ?? '';
      _googlePlayUrl.text = application.googlePlayUrl ?? '';
      _selectedCategory = application.category;
      _selectedPlatform = PlatformType.fromApiValue(application.platform);
      _existingScreenshots = List<String>.of(application.screenshots);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(dropCategoriesProvider);
      }
    });
  }

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
    final AsyncValue<List<String>> categoriesState =
        ref.watch(dropCategoriesProvider);
    final List<String> categories =
        categoriesState.valueOrNull ?? const <String>[];
    final String? selectedCategory = categories.isEmpty
        ? null
        : categories.contains(_selectedCategory)
            ? _selectedCategory
            : categories.first;
    final AsyncValue<String?> submitState =
        ref.watch(submitApplicationControllerProvider);
    final AsyncValue<bool> updateState = _isEditing
        ? ref.watch(
            updateApplicationControllerProvider(widget.applicationToEdit!.id),
          )
        : const AsyncData<bool>(false);

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
            AppSnackbar.show(
              context,
              message: error is AppException
                  ? error.message
                  : l10n.commonUnexpectedError,
            );
          },
        );
      },
    );

    if (_isEditing) {
      ref.listen<AsyncValue<bool>>(
        updateApplicationControllerProvider(widget.applicationToEdit!.id),
        (AsyncValue<bool>? previous, AsyncValue<bool> next) {
          next.whenOrNull(
            data: (bool updated) {
              if (updated && mounted) {
                context.pop(true);
              }
            },
            error: (Object error, StackTrace stackTrace) {
              AppSnackbar.show(
                context,
                message: error is AppException
                    ? error.message
                    : l10n.commonUnexpectedError,
              );
            },
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                12,
                AppSpacing.screenHorizontal,
                92,
              ),
              children: <Widget>[
                const FirstLookAppHeader(),
                const SizedBox(height: 22),
                Text(
                  _isEditing ? l10n.editApplicationTitle : l10n.submitTitle,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEditing
                      ? l10n.editApplicationSubtitle
                      : l10n.submitSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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
                if (categoriesState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (categories.isEmpty)
                  Text(
                    l10n.commonUnexpectedError,
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  )
                else
                  DropdownButtonFormField<String>(
                    key: ValueKey<String>(selectedCategory!),
                    initialValue: selectedCategory,
                    isExpanded: true,
                    items: categories
                        .map(
                          (String category) => DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    dropdownColor: AppColors.surfaceAlt(context),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceAlt(context),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            BorderSide(color: AppColors.outline(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            BorderSide(color: AppColors.outline(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                _Label(text: l10n.submitScreenshotsLabel),
                const SizedBox(height: 8),
                _ScreenshotPickerPreview(
                  files: _screenshots,
                  existingPaths: _existingScreenshots,
                  minimumCount: _minScreenshotCount,
                  maximumCount: _maxScreenshotCount,
                  pickLabel: _isEditing && _screenshots.isEmpty
                      ? l10n.editReplaceScreenshots
                      : l10n.submitPickScreenshots,
                  onPick: _pickScreenshots,
                  onRemove: _removeScreenshot,
                ),
                const SizedBox(height: 6),
                Text(
                  _isEditing && _screenshots.isEmpty
                      ? l10n.editScreenshotRequirements
                      : l10n.submitScreenshotRequirements,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_hasAttemptedSubmit &&
                    !_hasValidScreenshotCount) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    l10n.submitScreenshotCountError,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
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
                FirstLookSegmentedControl<PlatformType>(
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
                if (_showsAndroidField) ...<Widget>[
                  AuthTextField(
                    controller: _googlePlayUrl,
                    label: l10n.submitGooglePlayUrl,
                    hint: l10n.submitGooglePlayUrl,
                    keyboardType: TextInputType.url,
                  ),
                ],
                if (_showsAndroidField && _showsIosField)
                  const SizedBox(height: 12),
                if (_showsIosField) ...<Widget>[
                  AuthTextField(
                    controller: _appStoreUrl,
                    label: l10n.submitAppStoreUrl,
                    hint: l10n.submitAppStoreUrl,
                    keyboardType: TextInputType.url,
                  ),
                ],
                const SizedBox(height: 16),
                AuthPrimaryButton(
                  label: _isEditing
                      ? l10n.editApplicationButton
                      : l10n.submitButton,
                  isLoading: _isEditing
                      ? updateState.isLoading
                      : submitState.isLoading,
                  onPressed: selectedCategory == null
                      ? null
                      : () => _submit(l10n, selectedCategory),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickScreenshots() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    if (_screenshots.length >= _maxScreenshotCount) {
      AppSnackbar.show(
        context,
        message: '${l10n.submitScreenshotLimitPrefix} $_maxScreenshotCount',
      );
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result == null) {
      return;
    }

    final List<PlatformFile> pickedFiles = result.files
        .where((PlatformFile file) => file.path != null)
        .toList(growable: false);

    final List<PlatformFile> acceptedFiles = pickedFiles
        .where((PlatformFile file) => file.size <= _maxScreenshotSizeBytes)
        .toList(growable: false);

    if (!mounted) {
      return;
    }

    if (acceptedFiles.length != pickedFiles.length) {
      AppSnackbar.show(context, message: l10n.submitScreenshotSizeError);
    }

    if (acceptedFiles.isEmpty) {
      return;
    }

    setState(() {
      final Map<String, PlatformFile> mergedFiles = <String, PlatformFile>{
        for (final PlatformFile file in _screenshots)
          if (file.path != null) file.path!: file,
      };

      for (final PlatformFile file in acceptedFiles) {
        if (file.path != null) {
          mergedFiles[file.path!] = file;
        }
      }

      _screenshots =
          mergedFiles.values.take(_maxScreenshotCount).toList(growable: false);
    });
  }

  void _removeScreenshot(PlatformFile file) {
    setState(() {
      _screenshots = _screenshots
          .where((PlatformFile current) => current.path != file.path)
          .toList(growable: false);
    });
  }

  bool get _hasValidScreenshotCount {
    if (_isEditing && _screenshots.isEmpty) {
      return true;
    }

    return _screenshots.length >= _minScreenshotCount &&
        _screenshots.length <= _maxScreenshotCount;
  }

  void _submit(AppLocalizations l10n, String category) {
    final bool isAuthenticated =
        ref.read(authControllerProvider).valueOrNull?.status ==
            AuthStatus.authenticated;
    if (!isAuthenticated) {
      context.push(RouteNames.loginPath);
      return;
    }

    final String name = _name.text.trim();
    final String description = _description.text.trim();
    final String videoUrl = _videoUrl.text.trim();
    final String googlePlayUrl = _googlePlayUrl.text.trim();
    final String appStoreUrl = _appStoreUrl.text.trim();

    if (!_hasAttemptedSubmit) {
      setState(() => _hasAttemptedSubmit = true);
    }

    if (!_hasValidScreenshotCount) {
      AppSnackbar.show(
        context,
        message: l10n.submitScreenshotCountError,
      );
      return;
    }

    if (name.isEmpty || description.isEmpty) {
      AppSnackbar.show(context, message: l10n.submitRequiredFields);
      return;
    }

    if (videoUrl.isNotEmpty && !_isValidStoreUrl(videoUrl)) {
      AppSnackbar.show(
        context,
        message: '${l10n.submitVideoUrl} ${l10n.submitInvalidUrlSuffix}',
      );
      return;
    }

    if (_showsAndroidField && googlePlayUrl.isEmpty) {
      AppSnackbar.show(
        context,
        message:
            '${l10n.submitGooglePlayUrl} ${l10n.submitFieldIsRequiredSuffix}',
      );
      return;
    }

    if (_showsIosField && appStoreUrl.isEmpty) {
      AppSnackbar.show(
        context,
        message:
            '${l10n.submitAppStoreUrl} ${l10n.submitFieldIsRequiredSuffix}',
      );
      return;
    }

    if (_showsAndroidField && !_isValidStoreUrl(googlePlayUrl)) {
      AppSnackbar.show(
        context,
        message: '${l10n.submitGooglePlayUrl} ${l10n.submitInvalidUrlSuffix}',
      );
      return;
    }

    if (_showsIosField && !_isValidStoreUrl(appStoreUrl)) {
      AppSnackbar.show(
        context,
        message: '${l10n.submitAppStoreUrl} ${l10n.submitInvalidUrlSuffix}',
      );
      return;
    }

    final SubmitApplicationPayload payload = SubmitApplicationPayload(
      name: name,
      category: category,
      description: description,
      videoUrl: videoUrl,
      platform: _selectedPlatform,
      appStoreUrl: _showsIosField ? appStoreUrl : '',
      googlePlayUrl: _showsAndroidField ? googlePlayUrl : '',
      destination: SubmitDestination.drop,
      screenshotPaths: _screenshots
          .map((PlatformFile file) => file.path)
          .whereType<String>()
          .toList(growable: false),
    );

    if (_isEditing) {
      ref
          .read(
            updateApplicationControllerProvider(
              widget.applicationToEdit!.id,
            ).notifier,
          )
          .update(payload);
    } else {
      ref.read(submitApplicationControllerProvider.notifier).submit(payload);
    }
  }

  bool _isValidStoreUrl(String value) {
    final Uri? uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        (uri.host.isNotEmpty);
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
      _selectedCategory = null;
      _selectedPlatform = PlatformType.android;
      _screenshots = <PlatformFile>[];
      _existingScreenshots = <String>[];
      _hasAttemptedSubmit = false;
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
      style: TextStyle(
        color: AppColors.textSecondary(context),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _ScreenshotPickerPreview extends StatelessWidget {
  const _ScreenshotPickerPreview({
    required this.files,
    required this.existingPaths,
    required this.minimumCount,
    required this.maximumCount,
    required this.pickLabel,
    required this.onPick,
    required this.onRemove,
  });

  final List<PlatformFile> files;
  final List<String> existingPaths;
  final int minimumCount;
  final int maximumCount;
  final String pickLabel;
  final VoidCallback onPick;
  final ValueChanged<PlatformFile> onRemove;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty && existingPaths.isNotEmpty) {
      return SizedBox(
        height: 118,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: existingPaths.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (BuildContext context, int index) {
            if (index == existingPaths.length) {
              return _AddScreenshotSlot(
                onPick: onPick,
                pickLabel: pickLabel,
              );
            }

            return _RemoteScreenshotSlot(path: existingPaths[index]);
          },
        ),
      );
    }

    final int itemCount = files.length < minimumCount
        ? minimumCount
        : files.length < maximumCount
            ? files.length + 1
            : files.length;

    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          if (index >= files.length) {
            return _AddScreenshotSlot(
              onPick: onPick,
              pickLabel: index == files.length ? pickLabel : '',
            );
          }

          return _ScreenshotSlot(
            file: files[index],
            onRemove: () => onRemove(files[index]),
          );
        },
      ),
    );
  }
}

class _RemoteScreenshotSlot extends StatelessWidget {
  const _RemoteScreenshotSlot({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt(context),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.network(
        UrlResolver.media(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.broken_image_outlined,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _AddScreenshotSlot extends StatelessWidget {
  const _AddScreenshotSlot({
    required this.onPick,
    required this.pickLabel,
  });

  final VoidCallback onPick;
  final String pickLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: 132,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt(context),
          border: Border.all(color: AppColors.outline(context)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
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
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenshotSlot extends StatelessWidget {
  const _ScreenshotSlot({
    required this.file,
    required this.onRemove,
  });

  final PlatformFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String? path = file.path;

    return Stack(
      children: <Widget>[
        Container(
          width: 132,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt(context),
            border: Border.all(color: AppColors.outline(context)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: path == null
              ? const SizedBox.shrink()
              : Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
