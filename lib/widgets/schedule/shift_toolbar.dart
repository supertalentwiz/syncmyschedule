import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../providers/schedule_provider.dart';
import '../common/loading_dialog.dart';

class ShiftToolbar extends StatelessWidget {
  final ScheduleProvider scheduleProvider;

  const ShiftToolbar({super.key, required this.scheduleProvider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hasShifts = scheduleProvider.shifts.isNotEmpty;
    final allFutureShiftsChecked =
        hasShifts &&
        scheduleProvider.shifts
            .asMap()
            .entries
            .where(
              (entry) =>
                  DateFormat('MM/dd/yyyy').parse(entry.value.date).isAfter(now),
            )
            .every(
              (entry) =>
                  scheduleProvider.shiftCheckedStates[entry.value.date] ??
                  false,
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
            onPressed: hasShifts
                ? () {
                    scheduleProvider.toggleAllShiftsChecked();
                  }
                : null,
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
                fontSize: AppSizes.buttonFontSize * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: hasShifts
                ? () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const LoadingDialog(),
                    );
                    final message = await scheduleProvider.syncToCalendar();
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Sync Result'),
                          content: Text(message),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppStrings.ok,
                                style: TextStyle(color: AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                : null,
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
                fontSize: AppSizes.buttonFontSize * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
