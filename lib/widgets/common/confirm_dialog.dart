import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

class ConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppStrings.useSavedCredentials,
        style: TextStyle(color: AppColors.primary),
      ),
      content: Text(
        AppStrings.savedCredentialsPrompt,
        style: TextStyle(color: AppColors.accent),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            AppStrings.editCredentials,
            style: TextStyle(color: AppColors.accent),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          child: const Text(
            'OK',
            style: TextStyle(color: AppColors.background),
          ),
        ),
      ],
    );
  }
}
