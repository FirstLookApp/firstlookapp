import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/core/network/api_envelope.dart';
import 'package:firstlook/core/network/url_resolver.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/features/apps/domain/entities/firstlook_models.dart';
import 'package:firstlook/features/apps/presentation/controllers/firstlook_controllers.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/app_error_state.dart';
import 'package:firstlook/widgets/app_loading_indicator.dart';
import 'package:firstlook/widgets/app_snackbar.dart';
import 'package:firstlook/widgets/firstlook_app_header.dart';
import 'package:firstlook/widgets/firstlook_design_system.dart';
import 'package:firstlook/widgets/showcase_coming_soon_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _showApplications = true;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: profile.when(
          data: (UserProfile user) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(profileProvider);
              ref.invalidate(myApplicationsProvider);
              ref.invalidate(profileCommentsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                12,
                AppSpacing.screenHorizontal,
                92,
              ),
              children: <Widget>[
                const FirstLookAppHeader(),
                const SizedBox(height: 28),
                _ProfileIdentity(
                  user: user,
                  onAvatarTap: () => _showProfileEditor(context, user),
                ),
                const SizedBox(height: 20),
                _StatsCard(user: user),
                const SizedBox(height: 20),
                FirstLookPrimaryButton(
                  label: l10n.profilePromoteApp,
                  icon: Icons.rocket_launch_rounded,
                  onPressed: () => showShowcaseComingSoonDialog(context),
                ),
                const SizedBox(height: 20),
                _ProfileTabs(
                  showApplications: _showApplications,
                  onChanged: (bool value) =>
                      setState(() => _showApplications = value),
                ),
                const SizedBox(height: 16),
                if (_showApplications)
                  const _MyApplicationsList()
                else
                  const _ProfileCommentsList(),
              ],
            ),
          ),
          error: (Object error, StackTrace stackTrace) => AppErrorState(
            message: error is AppException
                ? error.message
                : l10n.commonUnexpectedError,
            onRetry: () => ref.invalidate(profileProvider),
          ),
          loading: () => const AppLoadingIndicator(),
        ),
      ),
    );
  }

  Future<void> _showProfileEditor(
      BuildContext context, UserProfile user) async {
    final TextEditingController firstName =
        TextEditingController(text: user.firstName);
    final TextEditingController lastName =
        TextEditingController(text: user.lastName);
    final TextEditingController biography =
        TextEditingController(text: user.biography);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.viewInsetsOf(sheetContext).bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Profili düzenle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            TextField(
                controller: firstName,
                decoration: const InputDecoration(labelText: 'Ad')),
            const SizedBox(height: 18),
            TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: 'Soyad')),
            const SizedBox(height: 18),
            TextField(
              controller: biography,
              maxLength: 140,
              minLines: 3,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: 'Biyografi',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _showAvatarPicker(sheetContext),
              child: const Text('Avatarı değiştir'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                await ref.read(firstLookRepositoryProvider).updateProfile(
                      firstName: firstName.text.trim(),
                      lastName: lastName.text.trim(),
                      biography: biography.text.trim(),
                    );
                ref.invalidate(profileProvider);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
    firstName.dispose();
    lastName.dispose();
    biography.dispose();
  }

  Future<void> _showAvatarPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AvatarPickerSheet(),
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity({
    required this.user,
    required this.onAvatarTap,
  });

  final UserProfile user;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final String displayName = '${user.firstName} ${user.lastName}'.trim();

    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: onAvatarTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _ProfileAvatar(user: user, radius: 42),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          displayName.isEmpty ? user.username : displayName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.biography.isEmpty ? '@${user.username}' : user.biography,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.user,
    required this.radius,
  });

  final UserProfile user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = user.avatarUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: avatarUrl == null || avatarUrl.isEmpty
          ? null
          : NetworkImage(UrlResolver.media(avatarUrl)),
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(
              user.firstName.isEmpty
                  ? '?'
                  : user.firstName.characters.first.toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: radius * 0.62,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }
}

class _AvatarPickerSheet extends ConsumerStatefulWidget {
  const _AvatarPickerSheet();

  @override
  ConsumerState<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends ConsumerState<_AvatarPickerSheet> {
  String? _selectedAvatarId;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<List<AvatarOption>> avatars =
        ref.watch(profileAvatarsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        18,
        20,
        MediaQuery.of(context).padding.bottom + 22,
      ),
      child: SafeArea(
        top: false,
        child: avatars.when(
          data: (List<AvatarOption> items) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.profileAvatarTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  l10n.profileAvatarSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  _AvatarEmpty(message: l10n.profileAvatarEmpty)
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final AvatarOption avatar = items[index];
                      final bool selected = avatar.id == _selectedAvatarId;
                      return _AvatarOptionTile(
                        avatar: avatar,
                        selected: selected,
                        onTap: () => setState(
                          () => _selectedAvatarId = avatar.id,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                FirstLookPrimaryButton(
                  label: _isSaving
                      ? l10n.profileAvatarSaving
                      : l10n.profileAvatarSave,
                  onPressed: _selectedAvatarId == null || _isSaving
                      ? null
                      : () => _saveAvatar(context),
                ),
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _AvatarEmpty(message: l10n.profileAvatarLoadError),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => ref.invalidate(profileAvatarsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: AppLoadingIndicator()),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAvatar(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String? avatarId = _selectedAvatarId;
    if (avatarId == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(firstLookRepositoryProvider).selectAvatar(avatarId);
      ref.invalidate(profileProvider);
      if (context.mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.profileAvatarSaved)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.show(context, message: l10n.commonUnexpectedError);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _AvatarOptionTile extends StatelessWidget {
  const _AvatarOptionTile({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final AvatarOption avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    selected ? AppColors.primary : AppColors.outline(context),
                width: selected ? 3 : 1,
              ),
            ),
            child: CircleAvatar(
              radius: 27,
              backgroundColor: AppColors.primarySoft,
              backgroundImage: avatar.filePath.isEmpty
                  ? null
                  : NetworkImage(UrlResolver.media(avatar.filePath)),
              child: avatar.filePath.isEmpty
                  ? const Icon(Icons.person_rounded, color: AppColors.primary)
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            avatar.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarEmpty extends StatelessWidget {
  const _AvatarEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.user,
  });

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.adaptiveShadow(context),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _Stat(label: l10n.profileStatsLikes, value: user.totalReceivedLikes),
          _Stat(
              label: l10n.profileStatsComments,
              value: user.totalReceivedComments),
          _Stat(label: l10n.profileStatsApps, value: user.totalApplications),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            _compactCount(value),
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    required this.showApplications,
    required this.onChanged,
  });

  final bool showApplications;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt(context),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          _TabButton(
            label: l10n.profileMyApps,
            selected: showApplications,
            onTap: () => onChanged(true),
          ),
          _TabButton(
            label: l10n.profileMyComments,
            selected: !showApplications,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppColors.secondary
                  : AppColors.textSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MyApplicationsList extends ConsumerWidget {
  const _MyApplicationsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PagedResult<ApplicationListItem>> applications =
        ref.watch(myApplicationsProvider);

    return applications.when(
      data: (PagedResult<ApplicationListItem> result) {
        if (result.items.isEmpty) {
          return const _CommentsPlaceholder(message: '');
        }

        return Column(
          children: result.items
              .map<Widget>(
                (ApplicationListItem item) => _ProfileApplicationCard(
                  item: item,
                  onTap: () => context.push(
                    RouteNames.applicationDetailLocation(
                      id: item.id,
                      platform: item.platform,
                      currentPath: RouteNames.profilePath,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
      error: (Object error, StackTrace stackTrace) => AppErrorState(
        message: error is AppException
            ? error.message
            : AppLocalizations.of(context)?.commonUnexpectedError ??
                'Something went wrong. Please try again.',
        onRetry: () => ref.invalidate(myApplicationsProvider),
      ),
      loading: () => const AppLoadingIndicator(),
    );
  }
}

class _ProfileApplicationCard extends StatelessWidget {
  const _ProfileApplicationCard({
    required this.item,
    required this.onTap,
  });

  final ApplicationListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String imagePath = item.applicationIconPath?.isNotEmpty ?? false
        ? item.applicationIconPath!
        : item.mainScreenshot;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border.all(color: AppColors.outline(context)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.adaptiveShadow(context),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: imagePath.isEmpty
                    ? const ColoredBox(
                        color: AppColors.primarySoft,
                        child:
                            Icon(Icons.apps_rounded, color: AppColors.primary),
                      )
                    : Image.network(
                        UrlResolver.media(imagePath),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCommentsList extends ConsumerWidget {
  const _ProfileCommentsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PagedResult<ProfileCommentItem>> comments =
        ref.watch(profileCommentsProvider);

    return comments.when(
      data: (PagedResult<ProfileCommentItem> result) {
        if (result.items.isEmpty) {
          return const _CommentsPlaceholder(message: '');
        }

        return Column(
          children: result.items
              .map<Widget>(
                (ProfileCommentItem item) => _ProfileCommentCard(
                  item: item,
                  onTap: () => context.push(
                    RouteNames.applicationDetailLocation(
                      id: item.applicationId,
                      platform: PlatformType.both.apiValue,
                      currentPath: RouteNames.profilePath,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
      error: (Object error, StackTrace stackTrace) => AppErrorState(
        message: error is AppException
            ? error.message
            : AppLocalizations.of(context)?.commonUnexpectedError ??
                'Something went wrong. Please try again.',
        onRetry: () => ref.invalidate(profileCommentsProvider),
      ),
      loading: () => const AppLoadingIndicator(),
    );
  }
}

class _ProfileCommentCard extends StatelessWidget {
  const _ProfileCommentCard({
    required this.item,
    required this.onTap,
  });

  final ProfileCommentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String badgeLabel = _profileCommentBadgeLabel(l10n, item);
    final bool receivedComment = item.isOnOwnApplication && !item.isOwnComment;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border.all(color: AppColors.outline(context)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.adaptiveShadow(context),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: item.applicationMainScreenshot.isEmpty
                    ? const ColoredBox(
                        color: AppColors.primarySoft,
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          color: AppColors.primary,
                        ),
                      )
                    : Image.network(
                        UrlResolver.media(item.applicationMainScreenshot),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.applicationName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatProfileCommentDate(item.createdAt),
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: receivedComment
                              ? AppColors.primarySoft
                              : AppColors.chipFill,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            color: receivedComment
                                ? AppColors.primary
                                : AppColors.textPrimary(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (item.commenterUsername.isNotEmpty)
                        Text(
                          '@${item.commenterUsername}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsPlaceholder extends StatelessWidget {
  const _CommentsPlaceholder({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Text(
        message.isEmpty ? l10n.commonNoData : message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary(context),
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

String _compactCount(int value) {
  if (value >= 1000) {
    final double compact = value / 1000;
    return '${compact.toStringAsFixed(compact >= 10 ? 0 : 1)}B';
  }
  return value.toString();
}

String _formatProfileCommentDate(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) {
    return '';
  }

  final DateTime local = value.toLocal();
  final String day = local.day.toString().padLeft(2, '0');
  final String month = local.month.toString().padLeft(2, '0');
  return '$day.$month.${local.year}';
}

String _profileCommentBadgeLabel(
  AppLocalizations l10n,
  ProfileCommentItem item,
) {
  if (item.isOwnComment && item.isOnOwnApplication) {
    return l10n.profileCommentOwnApp;
  }

  if (item.isOnOwnApplication) {
    return l10n.profileCommentReceived;
  }

  return l10n.profileCommentOwn;
}
