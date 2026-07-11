import 'package:firstlook/core/routing/route_names.dart';
import 'package:firstlook/core/providers/app_providers.dart';
import 'package:firstlook/features/auth/presentation/controllers/auth_controller.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_header.dart';
import 'package:firstlook/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:firstlook/localization/app_localizations.dart';
import 'package:firstlook/theme/app_colors.dart';
import 'package:firstlook/theme/app_spacing.dart';
import 'package:firstlook/widgets/firstlook_app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({required this.email, super.key});

  final String email;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final TextEditingController _otp = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otp.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<AuthState> authState = ref.watch(authControllerProvider);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    ref.listen<AsyncValue<AuthState>>(authControllerProvider, (
      _,
      AsyncValue<AuthState> next,
    ) {
      if (next.valueOrNull?.status == AuthStatus.authenticated) {
        context.go(RouteNames.discoverPath);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 390,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      18,
                      AppSpacing.large,
                      AppSpacing.large,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const AuthHeader(),
                        const SizedBox(height: 28),
                        const Center(child: FirstLookAppIcon(size: 96)),
                        const SizedBox(height: 28),
                        Text(
                          l10n.otpTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.otpSubtitle,
                          style: const TextStyle(
                            color: Color(0xFF7C7C84),
                            fontSize: 12,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 34),
                        _OtpCodeField(
                          controller: _otp,
                          focusNode: _otpFocusNode,
                        ),
                        const SizedBox(height: 24),
                        AuthPrimaryButton(
                          label: l10n.otpButton,
                          isLoading: authState.isLoading,
                          onPressed: () {
                            ref
                                .read(authControllerProvider.notifier)
                                .verifyEmail(
                                  email: widget.email,
                                  otp: _otp.text.trim(),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OtpCodeField extends StatelessWidget {
  const _OtpCodeField({required this.controller, required this.focusNode});

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            children: List<Widget>.generate(
              6,
              (int index) => Expanded(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, _) {
                    final String value = controller.text;
                    final String digit =
                        index < value.length ? value[index] : '';

                    return Container(
                      height: 50,
                      margin: EdgeInsets.only(right: index == 5 ? 0 : 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: digit.isEmpty
                              ? AppColors.outline(context)
                              : const Color(0xFFFF1F2D),
                        ),
                      ),
                      child: Text(
                        digit,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              maxLength: 6,
              showCursor: false,
              style: const TextStyle(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
