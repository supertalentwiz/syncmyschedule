import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final Future<void> Function()? onPressed;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.gradientButtonDecoration,
      child: ElevatedButton(
        onPressed: onPressed != null ? () async => await onPressed!() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.buttonHeight + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.buttonFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
      ),
    );
  }
}
