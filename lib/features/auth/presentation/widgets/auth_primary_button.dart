import 'package:firstlook/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(Size.fromHeight(56)),
      elevation: WidgetStatePropertyAll<double>(outlined ? 0 : 8),
      shadowColor: const WidgetStatePropertyAll<Color>(Color(0x33FF315F)),
      backgroundColor: WidgetStatePropertyAll<Color>(
        outlined ? Colors.white : AppColors.primary,
      ),
      foregroundColor: WidgetStatePropertyAll<Color>(
        outlined ? AppColors.primary : Colors.white,
      ),
      side: WidgetStatePropertyAll<BorderSide>(
        outlined ? const BorderSide(color: AppColors.primary) : BorderSide.none,
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textStyle: const WidgetStatePropertyAll<TextStyle>(
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
    );

    return outlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: _ButtonChild(label: label, isLoading: isLoading),
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: _ButtonChild(label: label, isLoading: isLoading),
          );
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({
    required this.label,
    required this.isLoading,
  });

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);
  }
}
