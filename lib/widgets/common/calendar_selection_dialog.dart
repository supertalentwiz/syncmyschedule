import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import '../../constants/app_strings.dart';
import '../../providers/schedule_provider.dart';
import './google_account_selection_dialog.dart';

class CalendarSelectionDialog extends StatelessWidget {
  final ScheduleProvider scheduleProvider;

  const CalendarSelectionDialog({super.key, required this.scheduleProvider});

  Future<List<Calendar>> _getGoogleCalendars() async {
    final plugin = DeviceCalendarPlugin();
    final permissions = await plugin.hasPermissions();
    if (!permissions.isSuccess || !permissions.data!) {
      final request = await plugin.requestPermissions();
      if (!request.isSuccess || !request.data!) {
        return [];
      }
    }
    final calendarsResult = await plugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return [];
    }
    // Log all calendars for debugging
    for (var calendar in calendarsResult.data!) {
      debugPrint('Calendar: name=${calendar.name}, accountName=${calendar.accountName}, accountType=${calendar.accountType}, isReadOnly=${calendar.isReadOnly}');
    }
    return calendarsResult.data!
        .where((calendar) =>
            calendar.isReadOnly == false &&
            calendar.accountType?.toLowerCase().contains('google') == true)
        .toList();
  }

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
            onTap: () async {
              // Set calendar type first
              await scheduleProvider.setCalendarType(AppStrings.android);
              // Fetch Google calendars
              final googleCalendars = await _getGoogleCalendars();
              if (googleCalendars.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No Google calendars found. Please add a Google account.'),
                  ),
                );
                Navigator.pop(context); // Close dialog if no calendars
              } else {
                // Close current dialog and show Google account selection
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => GoogleAccountSelectionDialog(
                    scheduleProvider: scheduleProvider,
                    googleCalendars: googleCalendars,
                  ),
                );
              }
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