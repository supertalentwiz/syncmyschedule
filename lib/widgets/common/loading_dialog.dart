import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          SizedBox(
            width: AppSizes.smallIconSize,
            height: AppSizes.smallIconSize,
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
          Expanded(
            child: Text(
              AppStrings.fetchingSchedule,
              style: TextStyle(fontSize: 16, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
