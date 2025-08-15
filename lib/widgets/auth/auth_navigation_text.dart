import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AuthNavigationText extends StatelessWidget {
  final String prompt;
  final String actionText;
  final VoidCallback onTap;

  const AuthNavigationText({
    super.key,
    required this.prompt,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: RichText(
        text: TextSpan(
          text: prompt,
          style: TextStyle(color: AppColors.primary),
          children: [
            TextSpan(
              text: actionText,
              style: TextStyle(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
