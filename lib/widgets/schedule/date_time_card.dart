import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import 'package:provider/provider.dart';
import '../../constants/app_strings.dart';
import '../../providers/schedule_provider.dart';
import '../common/calendar_selection_dialog.dart';

class DateTimeCard extends StatelessWidget {
  final String date;
  final List<String> payPeriods;
  final String? selectedPayPeriod;
  final ValueChanged<String?>? onPayPeriodChanged;

  const DateTimeCard({
    super.key,
    required this.date,
    required this.payPeriods,
    this.selectedPayPeriod,
    this.onPayPeriodChanged,
  });

  Future<void> _resetCalendarId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedGoogleCalendarId');
    await prefs.remove('selectedGoogleCalendarName');
    debugPrint('Cleared selectedGoogleCalendarId from SharedPreferences');
  }

  Future<bool> _launchCalendarIntent(int timestamp, String? calendarId) async {
    const platform = MethodChannel('app.channel/calendar');
    try {
      await platform.invokeMethod('launchCalendar', {
        'timestamp': timestamp.toString(), // send ms since epoch
        'calendarId': calendarId,
      });
      debugPrint(
          'Successfully launched calendar intent with timestamp=$timestamp, calendarId=$calendarId');
      return true;
    } catch (e) {
      debugPrint('Failed to launch calendar intent: $e');
      return false;
    }
  }

  Future<void> _openSystemCalendar(BuildContext context) async {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final calendarType = scheduleProvider.calendarType;
    String? selectedGoogleCalendarId = scheduleProvider.selectedGoogleCalendarId;

    // First day of current month
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final timestamp = firstDayOfMonth.millisecondsSinceEpoch; // ✅ FIXED

    debugPrint('Input date: $date');
    debugPrint('Selected calendar ID: $selectedGoogleCalendarId');
    debugPrint(
        'Opening calendar to month: ${DateFormat('MMMM yyyy').format(firstDayOfMonth)}');

    if (calendarType == AppStrings.android) {
      final plugin = DeviceCalendarPlugin();
      final permissions = await plugin.hasPermissions();
      if (!permissions.isSuccess || !permissions.data!) {
        final request = await plugin.requestPermissions();
        if (!request.isSuccess || !request.data!) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Calendar permissions denied'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () async {},
              ),
            ),
          );
          return;
        }
      }

      if (selectedGoogleCalendarId != null) {
        final calendarsResult = await plugin.retrieveCalendars();
        if (calendarsResult.isSuccess && calendarsResult.data != null) {
          final validCalendar = calendarsResult.data!.any(
            (c) => c.id == selectedGoogleCalendarId && c.isReadOnly == false,
          );
          if (!validCalendar) {
            await _resetCalendarId();
            await scheduleProvider.setSelectedGoogleCalendar('', '');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Selected calendar is invalid. Please choose a new calendar.'),
                action: SnackBarAction(
                  label: 'Select',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) =>
                        CalendarSelectionDialog(scheduleProvider: scheduleProvider),
                  ),
                ),
              ),
            );
            selectedGoogleCalendarId = null;
          }
        }
      }

      bool launched = false;
      if (selectedGoogleCalendarId != null) {
        launched = await _launchCalendarIntent(timestamp, selectedGoogleCalendarId);
      }
      if (!launched) {
        launched = await _launchCalendarIntent(timestamp, null);
      }

      if (!launched) {
        final webUri = Uri.parse(
          'https://calendar.google.com/calendar/u/0/r/month/${DateFormat('yyyy/MM').format(firstDayOfMonth)}',
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Opened calendar to ${DateFormat('MMMM yyyy').format(firstDayOfMonth)}'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not open calendar. Please ensure Google Calendar or a browser is installed.'),
            ),
          );
        }
      }
    } else if (calendarType == AppStrings.iOSCalendar) {
      final url = Uri.parse('calshow:$timestamp'); // works with ms on iOS
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        final webUri = Uri.parse(
          'https://calendar.google.com/calendar/u/0/r/month/${DateFormat('yyyy/MM').format(firstDayOfMonth)}',
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => CalendarSelectionDialog(
          scheduleProvider: scheduleProvider,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 20.0;
    const double borderWidth = 1.0;
    const double buttonHeight = 40.0;
    const EdgeInsets buttonPadding =
        EdgeInsets.symmetric(vertical: 6, horizontal: 12);
    final TextStyle buttonTextStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      constraints: const BoxConstraints(minHeight: AppSizes.dateTimeCardHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            date,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: buttonHeight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white,
                        width: borderWidth,
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      textStyle: buttonTextStyle,
                      padding: buttonPadding,
                    ),
                    onPressed: () => _openSystemCalendar(context),
                    child: const Text('Calendar View'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: buttonHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedPayPeriod?.isNotEmpty == true
                            ? selectedPayPeriod
                            : null,
                        hint: Text(
                          "Pay Period",
                          style: buttonTextStyle.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        items: payPeriods.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Center(
                              child: Text(
                                period,
                                style: buttonTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: onPayPeriodChanged,
                        dropdownColor: AppColors.accent.withOpacity(0.9),
                        iconEnabledColor: Colors.white,
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
