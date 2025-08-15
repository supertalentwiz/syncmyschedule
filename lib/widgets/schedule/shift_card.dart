import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/shift_legend.dart';

class ShiftCard extends StatelessWidget {
  final String code;
  final String date;
  final bool isChecked;
  final ValueChanged<bool>? onChecked;

  const ShiftCard({
    super.key,
    required this.code,
    required this.date,
    this.isChecked = false,
    this.onChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.cardHorizontalPadding,
          vertical: AppSizes.cardVerticalPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ShiftLegend.formatShiftWithEmoji(code),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingExtraSmall),
                  Text(
                    date,
                    style: TextStyle(fontSize: 14, color: AppColors.accent),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isChecked,
              activeColor: AppColors.accent,
              checkColor: AppColors.background,
              fillColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.accent;
                }
                return Colors.transparent;
              }),
              side: onChecked == null
                  ? const BorderSide(color: Colors.grey, width: 1.5)
                  : const BorderSide(color: AppColors.accent, width: 1.5),
              onChanged: onChecked != null
                  ? (value) => onChecked!(value ?? false)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
