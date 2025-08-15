import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.navBarHeight,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              size: AppSizes.largeIconSize,
              color: selectedIndex == 0 ? AppColors.accent : Colors.grey[400],
            ),
            onPressed: () => onItemTapped(0),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: 160,
            child: ElevatedButton.icon(
              onPressed: () => onItemTapped(1),
              icon: const Icon(
                Icons.refresh,
                size: AppSizes.smallIconSize,
                color: AppColors.background,
              ),
              label: Text(
                AppStrings.syncNow,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.buttonFontSize,
                  color: AppColors.background,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              size: AppSizes.largeIconSize,
              color: selectedIndex == 2 ? AppColors.accent : Colors.grey[400],
            ),
            onPressed: () => onItemTapped(2),
          ),
        ],
      ),
    );
  }
}
