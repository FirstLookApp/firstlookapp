import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:flutter/material.dart';

Future<void> showShowcaseComingSoonDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (BuildContext dialogContext) {
      final AppLocalizations l10n = AppLocalizations.of(dialogContext)!;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(dialogContext),
            borderRadius: BorderRadius.circular(26),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 34,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 70,
                      height: 70,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.showcaseComingSoonTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary(dialogContext),
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.showcaseComingSoonMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary(dialogContext),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.softPrimary(dialogContext),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.showcaseComingSoonBadge,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textPrimary(dialogContext),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceAlt(dialogContext),
                    fixedSize: const Size(34, 34),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
