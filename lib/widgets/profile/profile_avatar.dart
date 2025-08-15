import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class ProfileAvatar extends StatelessWidget {
  final String username;

  const ProfileAvatar({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: AppSizes.avatarRadius,
      backgroundColor: AppColors.accent.withOpacity(0.2),
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
