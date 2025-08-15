import 'package:flutter/material.dart';
import '../../constants/app_strings.dart';
import '../../providers/schedule_provider.dart';

class CalendarSelectionDialog extends StatelessWidget {
  final ScheduleProvider scheduleProvider;

  const CalendarSelectionDialog({super.key, required this.scheduleProvider});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.selectCalendarType),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              AppStrings.android,
              style: TextStyle(
                fontWeight: scheduleProvider.calendarType == AppStrings.android
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              scheduleProvider.setCalendarType(AppStrings.android);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(
              AppStrings.iOSCalendar,
              style: TextStyle(
                fontWeight:
                    scheduleProvider.calendarType == AppStrings.iOSCalendar
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              scheduleProvider.setCalendarType(AppStrings.iOSCalendar);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(
              AppStrings.icsFileExport,
              style: TextStyle(
                fontWeight:
                    scheduleProvider.calendarType == AppStrings.icsFileExport
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              scheduleProvider.setCalendarType(AppStrings.icsFileExport);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
