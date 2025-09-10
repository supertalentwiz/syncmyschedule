import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import '../../constants/app_strings.dart';
import '../../providers/schedule_provider.dart';

class GoogleAccountSelectionDialog extends StatelessWidget {
  final ScheduleProvider scheduleProvider;
  final List<Calendar> googleCalendars;

  const GoogleAccountSelectionDialog({
    super.key,
    required this.scheduleProvider,
    required this.googleCalendars,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Google Calendar'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: googleCalendars.isNotEmpty
              ? googleCalendars.map((calendar) {
                  return ListTile(
                    title: Text(
                      calendar.name ?? 'Unknown Calendar',
                      style: TextStyle(
                        fontWeight: scheduleProvider.selectedGoogleCalendarId == calendar.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(calendar.accountName ?? 'Unknown Account'),
                    onTap: () {
                      scheduleProvider.setSelectedGoogleCalendar(
                        calendar.id!,
                        calendar.name ?? 'Unknown',
                      );
                      Navigator.pop(context);
                    },
                  );
                }).toList()
              : [
                  const ListTile(
                    title: Text('No Google calendars found.'),
                  ),
                ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }
}