import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../providers/schedule_provider.dart';

class ShiftToolbar extends StatelessWidget {
  final ScheduleProvider scheduleProvider;

  const ShiftToolbar({super.key, required this.scheduleProvider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final allFutureShiftsChecked = scheduleProvider.shifts
        .asMap()
        .entries
        .where(
          (entry) =>
              DateFormat('MM/dd/yyyy').parse(entry.value.date).isAfter(now),
        )
        .every(
          (entry) =>
              scheduleProvider.shiftCheckedStates[entry.value.date] ?? false,
        );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.spacingExtraSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              scheduleProvider.toggleAllShiftsChecked();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.padding,
                vertical: AppSizes.toolbarButtonHeight,
              ),
            ),
            child: Text(
              allFutureShiftsChecked ? 'Unselect All' : 'Select All',
              style: const TextStyle(
                fontSize: AppSizes.buttonFontSize * 0.8, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = await scheduleProvider.syncToCalendar();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.padding,
                vertical: AppSizes.toolbarButtonHeight,
              ),
            ),
            child: const Text(
              'Sync to Calendar',
              style: TextStyle(
                fontSize: AppSizes.buttonFontSize * 0.8, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
