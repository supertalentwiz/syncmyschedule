import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/shift_model.dart';
import '../services/schedule_service.dart';
import '../constants/app_strings.dart';
import '../constants/shift_legend.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<ShiftModel> _shifts = [];
  String? _errorMessage;
  bool _isLoading = false;
  Map<String, bool> _shiftCheckedStates = {};
  String _calendarType = AppStrings.none;

  List<ShiftModel> get shifts => _shifts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Map<String, bool> get shiftCheckedStates => _shiftCheckedStates;
  String get calendarType => _calendarType;

  // Shift legend mapping for titles (aligned with ShiftLegend)
  static const Map<String, String> _shiftLegend = {
    r'\$': 'Overtime Shift',
    r'\^': 'Credit Time Shift - XTE',
    r'\!': 'Comp Time Shift - CTE',
    'A': 'Annual Leave',
    'ADMIN': 'Administrative Leave',
    'AWOL': 'Absent Without Leave',
    'AWS': '10 Hour Shift',
    'TRNG': 'Class Room Training',
    'BL': 'Blood Leave',
    'CL': 'Court Leave',
    'COS': 'Change of Station',
    'CTU': 'Comp Time Used',
    'XTU': 'Credit Time Used',
    'FL': 'Funeral Leave',
    'FRLO': 'Furlough',
    'FSL': 'Family Sick Leave',
    'HL': 'Holiday Leave',
    'JURY': 'Jury Duty',
    'LWOP': 'Leave Without Pay',
    'MIL': 'Military Leave',
    'SL': 'Sick Leave',
    'TOA': 'Time Off Award',
    'WX': 'Hazardous Weather Leave',
    'X': 'Regular Day Off',
  };

  // Leave types are all-day events
  static const List<String> _leaveTypes = [
    'A',
    'ADMIN',
    'AWOL',
    'BL',
    'CL',
    'COS',
    'CTU',
    'XTU',
    'FL',
    'FRLO',
    'FSL',
    'HL',
    'JURY',
    'LWOP',
    'MIL',
    'SL',
    'TOA',
    'WX',
    'X',
  ];

  // Suffix durations in hours (default 8)
  static const Map<String, int> _suffixDurations = {
    'AWS': 10,
    // Add other suffixes with specific durations if needed
  };

  Future<void> loadCalendarType() async {
    final prefs = await SharedPreferences.getInstance();
    _calendarType = prefs.getString('calendarType') ?? AppStrings.none;
    notifyListeners();
  }

  Future<void> setCalendarType(String type) async {
    _calendarType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendarType', type);
    notifyListeners();
  }

  Future<bool> checkTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('termsAccepted') ?? false;
  }

  Future<void> acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAccepted', true);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final username = await _storage.read(key: 'faa_username');
    final password = await _storage.read(key: 'faa_password');
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'faa_username', value: username);
    await _storage.write(key: 'faa_password', value: password);
  }

  Future<void> fetchSchedule(String username, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      _shifts = await _scheduleService.fetchSchedule(
        username: username,
        password: password,
      );
      // Initialize checked states for new shifts
      _shiftCheckedStates = {for (var shift in _shifts) shift.date: false};
    } catch (e) {
      _errorMessage = e.toString();
      _shifts = [];
      _shiftCheckedStates = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleShiftChecked(String date, bool isChecked) {
    _shiftCheckedStates[date] = isChecked;
    notifyListeners();
  }

  void toggleAllShiftsChecked() {
    final now = DateTime.now();
    final allFutureChecked = _shifts
        .asMap()
        .entries
        .where(
          (entry) =>
              DateFormat('MM/dd/yyyy').parse(entry.value.date).isAfter(now),
        )
        .every((entry) => _shiftCheckedStates[entry.value.date] ?? false);
    _shiftCheckedStates = {
      for (var shift in _shifts)
        shift.date: DateFormat('MM/dd/yyyy').parse(shift.date).isAfter(now)
            ? !allFutureChecked
            : _shiftCheckedStates[shift.date] ?? false,
    };
    notifyListeners();
  }

  Future<String> syncToCalendar() async {
    final selectedShifts = _shifts
        .asMap()
        .entries
        .where((entry) => _shiftCheckedStates[entry.value.date] ?? false)
        .map((entry) => entry.value)
        .toList();

    if (selectedShifts.isEmpty) {
      return 'No shifts selected to sync';
    }

    if (_calendarType == AppStrings.none) {
      return 'No calendar type selected';
    }

    try {
      if (_calendarType == AppStrings.android ||
          _calendarType == AppStrings.iOSCalendar) {
        final plugin = DeviceCalendarPlugin();
        final permissions = await plugin.requestPermissions();
        if (!permissions.isSuccess || !permissions.data!) {
          return 'Calendar permissions denied';
        }

        final calendars = await plugin.retrieveCalendars();
        final calendar = calendars.data?.first;
        if (calendar == null) {
          return 'No calendar found';
        }

        final location = tz.getLocation(tz.local.name); // Use local timezone
        final timeFormat = DateFormat('H:mm');
        for (var shift in selectedShifts) {
          final event = Event(calendar.id);
          // Parse shift code dynamically
          RegExp numericReg = RegExp(r'^\d+');
          String numericPart = '';
          String suffix = shift.code;
          if (numericReg.hasMatch(shift.code)) {
            numericPart = numericReg.firstMatch(shift.code)?.group(0) ?? '';
            suffix = shift.code.substring(numericPart.length);
          }

          // Handle special suffixes: $, ^, !
          String specialSuffix = '';
          RegExp specialReg = RegExp(r'[\$\^!]+$');
          if (specialReg.hasMatch(suffix)) {
            specialSuffix = specialReg.firstMatch(suffix)?.group(0) ?? '';
            suffix = suffix.substring(0, suffix.length - specialSuffix.length);
          }

          // Title with emoji
          String title = _shiftLegend[suffix] ?? suffix;
          if (specialSuffix.isNotEmpty) {
            title = _shiftLegend[specialSuffix] ?? title;
          }
          // Append emoji based on suffix or specialSuffix
          String emojiKey = specialSuffix.isNotEmpty ? specialSuffix : suffix;
          String emoji = ShiftLegend.shiftEmojiLegend[emojiKey] ?? '';
          title = '$title $emoji'.trim();

          bool isAllDay = _leaveTypes.contains(suffix) || numericPart.isEmpty;
          final baseDate = DateFormat('MM/dd/yyyy').parse(shift.date);
          if (!isAllDay) {
            // Parse start time from numericPart
            String startStr = '';
            if (numericPart.length == 1 || numericPart.length == 2) {
              startStr = '$numericPart:00';
            } else if (numericPart.length == 3) {
              startStr = numericPart[0] + ':' + numericPart.substring(1);
            } else if (numericPart.length == 4) {
              startStr =
                  numericPart.substring(0, 2) + ':' + numericPart.substring(2);
            }

            // Validate start time
            try {
              final startTime = timeFormat.parseStrict(startStr);
              int hour = startTime.hour;
              int minute = startTime.minute;
              if (hour > 23 || minute > 59) {
                throw FormatException('Invalid time: $startStr');
              }
              int duration = _suffixDurations[suffix] ?? 8;
              // Calculate end time
              var startDateTime = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                startTime.hour,
                startTime.minute,
              );
              var endDateTime = startDateTime.add(Duration(hours: duration));
              event.start = tz.TZDateTime.from(startDateTime, location);
              event.end = tz.TZDateTime.from(endDateTime, location);
              event.allDay = false;
            } catch (e) {
              // Invalid time, fallback to all-day
              event.start = tz.TZDateTime(
                location,
                baseDate.year,
                baseDate.month,
                baseDate.day,
              );
              event.end = event.start!.add(const Duration(days: 1));
              event.allDay = true;
            }
          } else {
            event.start = tz.TZDateTime(
              location,
              baseDate.year,
              baseDate.month,
              baseDate.day,
            );
            event.end = event.start!.add(const Duration(days: 1));
            event.allDay = true;
          }
          event.title = title;
          final result = await plugin.createOrUpdateEvent(event);
          if (result?.isSuccess == false) {
            return 'Failed to sync shift on ${shift.date}: ${result?.errors.join(", ")}';
          }
        }

        return 'Successfully synced ${selectedShifts.length} shifts to calendar';
      } else if (_calendarType == AppStrings.icsFileExport) {
        StringBuffer ics = StringBuffer();
        ics.writeln('BEGIN:VCALENDAR');
        ics.writeln('VERSION:2.0');
        ics.writeln('PRODID:-//SyncMySchedule//EN');
        final timeFormat = DateFormat('H:mm');
        for (var shift in selectedShifts) {
          RegExp numericReg = RegExp(r'^\d+');
          String numericPart = '';
          String suffix = shift.code;
          if (numericReg.hasMatch(shift.code)) {
            numericPart = numericReg.firstMatch(shift.code)?.group(0) ?? '';
            suffix = shift.code.substring(numericPart.length);
          }

          // Handle special suffixes: $, ^, !
          String specialSuffix = '';
          RegExp specialReg = RegExp(r'[\$\^!]+$');
          if (specialReg.hasMatch(suffix)) {
            specialSuffix = specialReg.firstMatch(suffix)?.group(0) ?? '';
            suffix = suffix.substring(0, suffix.length - specialSuffix.length);
          }

          // Title with emoji
          String title = _shiftLegend[suffix] ?? suffix;
          if (specialSuffix.isNotEmpty) {
            title = _shiftLegend[specialSuffix] ?? title;
          }
          // Append emoji based on suffix or specialSuffix
          String emojiKey = specialSuffix.isNotEmpty ? specialSuffix : suffix;
          String emoji = ShiftLegend.shiftEmojiLegend[emojiKey] ?? '';
          title = '$title $emoji'.trim();

          bool isAllDay = _leaveTypes.contains(suffix) || numericPart.isEmpty;
          final baseDate = DateFormat('MM/dd/yyyy').parse(shift.date);
          ics.writeln('BEGIN:VEVENT');
          ics.writeln(
            'UID:${shift.code}-${shift.date.replaceAll('/', '')}@syncmyschedule.com',
          );
          if (!isAllDay) {
            // Parse start time from numericPart
            String startStr = '';
            if (numericPart.length == 1 || numericPart.length == 2) {
              startStr = '$numericPart:00';
            } else if (numericPart.length == 3) {
              startStr = numericPart[0] + ':' + numericPart.substring(1);
            } else if (numericPart.length == 4) {
              startStr =
                  numericPart.substring(0, 2) + ':' + numericPart.substring(2);
            }

            // Validate start time
            try {
              final startTime = timeFormat.parseStrict(startStr);
              int hour = startTime.hour;
              int minute = startTime.minute;
              if (hour > 23 || minute > 59) {
                throw FormatException('Invalid time: $startStr');
              }
              int duration = _suffixDurations[suffix] ?? 8;
              // Calculate end time with midnight adjustment
              var startDateTime = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                startTime.hour,
                startTime.minute,
              );
              var endDateTime = startDateTime.add(Duration(hours: duration));
              // Adjust end time if it crosses midnight to next day
              if (endDateTime.hour < startTime.hour) {
                endDateTime = endDateTime.add(const Duration(days: 1));
              }
              ics.writeln(
                'DTSTART:${DateFormat('yyyyMMdd\'T\'HHmmss').format(startDateTime)}Z',
              );
              ics.writeln(
                'DTEND:${DateFormat('yyyyMMdd\'T\'HHmmss').format(endDateTime)}Z',
              );
            } catch (e) {
              // Invalid time, fallback to all-day
              ics.writeln(
                'DTSTART;VALUE=DATE:${DateFormat('yyyyMMdd').format(baseDate)}',
              );
              ics.writeln(
                'DTEND;VALUE=DATE:${DateFormat('yyyyMMdd').format(baseDate.add(const Duration(days: 1)))}',
              );
            }
          } else {
            ics.writeln(
              'DTSTART;VALUE=DATE:${DateFormat('yyyyMMdd').format(baseDate)}',
            );
            ics.writeln(
              'DTEND;VALUE=DATE:${DateFormat('yyyyMMdd').format(baseDate.add(const Duration(days: 1)))}',
            );
          }
          ics.writeln('SUMMARY:$title');
          ics.writeln('END:VEVENT');
        }
        ics.writeln('END:VCALENDAR');

        final dir = await getApplicationDocumentsDirectory();
        if (dir == null) {
          return 'Unable to access application documents directory';
        }
        // Ensure the directory exists
        final directory = Directory(dir.path);
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final path =
            '${dir.path}/shifts_${DateTime.now().millisecondsSinceEpoch}.ics';
        final file = File(path);
        await file.writeAsString(ics.toString());
        await Share.shareXFiles([
          XFile(path),
        ], text: null); // Remove text to avoid extra file

        return 'ICS file exported successfully';
      }

      return 'Unknown calendar type';
    } catch (e) {
      return 'Error syncing shifts: $e';
    }
  }
}
