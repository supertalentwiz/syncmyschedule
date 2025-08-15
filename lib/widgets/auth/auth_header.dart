import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class AuthHeader extends StatelessWidget {
  final double height;
  final bool showLogo;

  const AuthHeader({super.key, required this.height, this.showLogo = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.borderRadius),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showLogo) ...[
            Image.asset(
              'assets/logo.png',
              height: AppSizes.logoSize,
              width: AppSizes.logoSize,
            ),
            const SizedBox(height: AppSizes.spacingSmall),
          ],
          RichText(
            text: TextSpan(
              text: 'S',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.accent),
              children: const [
                TextSpan(
                  text: 'ync',
                  style: TextStyle(color: AppColors.background),
                ),
                TextSpan(
                  text: 'M',
                  style: TextStyle(color: AppColors.accent),
                ),
                TextSpan(
                  text: 'y',
                  style: TextStyle(color: AppColors.background),
                ),
                TextSpan(
                  text: 'S',
                  style: TextStyle(color: AppColors.accent),
                ),
                TextSpan(
                  text: 'chedule',
                  style: TextStyle(color: AppColors.background),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
        ],
      ),
    );
  }
}
