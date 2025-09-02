import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // Shift legend mapping for titles
  static const Map<String, String> _shiftLegend = {
    r'$': 'Overtime Shift',
    r'^': 'Credit Time Shift - XTE',
    r'!': 'Comp Time Shift - CTE',
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
  static const Map<String, int> _suffixDurations = {'AWS': 10};

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
      final newShifts = await _scheduleService.fetchSchedule(
        username: username,
        password: password,
      );
      _shifts = newShifts;
      _shiftCheckedStates = {
        for (var shift in _shifts)
          shift.date: _shiftCheckedStates[shift.date] ?? false,
      };
    } catch (e, st) {
      debugPrint('Error fetching schedule: $e\n$st');
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
        .where((s) => DateFormat('MM/dd/yyyy').parse(s.date).isAfter(now))
        .every((s) => _shiftCheckedStates[s.date] ?? false);
    _shiftCheckedStates = {
      for (var shift in _shifts)
        shift.date: DateFormat('MM/dd/yyyy').parse(shift.date).isAfter(now)
            ? !allFutureChecked
            : _shiftCheckedStates[shift.date] ?? false,
    };
    notifyListeners();
  }

  String? _localTzidOrNull() {
    try {
      final name = tz.local.name;
      if (name.isNotEmpty && name != 'UTC' && name.contains('/')) return name;
    } catch (_) {}
    return null;
  }

  String _formatIcsLocal(DateTime dt) {
    return DateFormat("yyyyMMdd'T'HHmmss").format(dt);
  }

  Future<String> syncToCalendar() async {
    final selectedShifts = _shifts
        .where((s) => _shiftCheckedStates[s.date] ?? false)
        .toList();

    if (selectedShifts.isEmpty) {
      return 'No shifts selected to sync';
    }

    if (_calendarType == AppStrings.none) {
      return 'No calendar type selected. Go to profile to select it';
    }

    try {
      if (_calendarType == AppStrings.android ||
          _calendarType == AppStrings.iOSCalendar) {
        final plugin = DeviceCalendarPlugin();
        final permissions = await plugin.requestPermissions();
        if (!permissions.isSuccess || !permissions.data!) {
          return 'Calendar permissions denied';
        }

        final calendarsResult = await plugin.retrieveCalendars();
        if (!calendarsResult.isSuccess || calendarsResult.data == null) {
          return 'Failed to retrieve calendars: ${calendarsResult.errors?.join(", ")}';
        }

        // Try to find a Google Calendar (or fallback to first writable calendar)
        Calendar? selectedCalendar;
        for (var calendar in calendarsResult.data!) {
          if (calendar.isReadOnly == false &&
              calendar.accountType?.toLowerCase().contains('google') == true) {
            selectedCalendar = calendar;
            break;
          }
        }

        if (calendarsResult.data!.isEmpty) {
          return 'No calendars available on device';
        }

        selectedCalendar ??= calendarsResult.data!.firstWhere(
          (c) => c.isReadOnly == false,
          orElse: () => calendarsResult.data!.first,
        );

        if (selectedCalendar == null) {
          return 'No writable calendar found';
        }

        final location = tz.getLocation(tz.local.name);
        final timeFormat = DateFormat('H:mm');
        for (var shift in selectedShifts) {
          final event = Event(selectedCalendar.id);

          // Parse shift code dynamically
          final numericReg = RegExp(r'^\d+');
          String numericPart = '';
          String suffix = shift.code;
          if (numericReg.hasMatch(shift.code)) {
            numericPart = numericReg.firstMatch(shift.code)?.group(0) ?? '';
            suffix = shift.code.substring(numericPart.length);
          }

          // Handle special suffixes: $, ^, !
          String specialSuffix = '';
          final specialReg = RegExp(r'[\$\^!]+$');
          if (specialReg.hasMatch(suffix)) {
            specialSuffix = specialReg.firstMatch(suffix)?.group(0) ?? '';
            suffix = suffix.substring(0, suffix.length - specialSuffix.length);
          }

          // Title with emoji
          String title = _shiftLegend[suffix] ?? suffix;
          if (specialSuffix.isNotEmpty) {
            title = _shiftLegend[specialSuffix] ?? title;
          }
          final emojiKey = specialSuffix.isNotEmpty ? specialSuffix : suffix;
          final emoji = ShiftLegend.shiftEmojiLegend[emojiKey] ?? '';
          title = '$title $emoji'.trim();

          final isAllDay = _leaveTypes.contains(suffix) || numericPart.isEmpty;
          final baseDate = DateFormat('MM/dd/yyyy').parse(shift.date);

          if (!isAllDay) {
            try {
              String startStr = '';
              if (numericPart.length == 1 || numericPart.length == 2) {
                startStr = '$numericPart:00';
              } else if (numericPart.length == 3) {
                startStr = numericPart[0] + ':' + numericPart.substring(1);
              } else if (numericPart.length == 4) {
                startStr =
                    numericPart.substring(0, 2) +
                    ':' +
                    numericPart.substring(2);
              }

              final startTime = timeFormat.parseStrict(startStr);
              int duration = _suffixDurations[suffix] ?? 8;
              var startDateTime = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                startTime.hour,
                startTime.minute,
              );
              var endDateTime = startDateTime.add(Duration(hours: duration));

              // Overnight → shift one day back
              if (endDateTime.day != baseDate.day) {
                startDateTime = startDateTime.subtract(const Duration(days: 1));
                endDateTime = endDateTime.subtract(const Duration(days: 1));
              }

              event.start = tz.TZDateTime.from(startDateTime, location);
              event.end = tz.TZDateTime.from(endDateTime, location);
              event.allDay = false;
            } catch (e) {
              // Fallback to full-day shift
              event.start = tz.TZDateTime.from(
                DateTime(baseDate.year, baseDate.month, baseDate.day, 0, 0, 0),
                tz.local,
              );
              event.end = tz.TZDateTime.from(
                DateTime(
                  baseDate.year,
                  baseDate.month,
                  baseDate.day,
                  23,
                  59,
                  59,
                ),
                tz.local,
              );
              event.allDay = false;
            }
          } else {
            event.start = tz.TZDateTime.from(
              DateTime(baseDate.year, baseDate.month, baseDate.day, 0, 0, 0),
              tz.local,
            );
            event.end = tz.TZDateTime.from(
              DateTime(baseDate.year, baseDate.month, baseDate.day, 23, 59, 59),
              tz.local,
            );
            event.allDay = false;
          }

          event.title = title;
          event.description = 'Imported by SyncMySchedule';
          final result = await plugin.createOrUpdateEvent(event);
          if (result?.isSuccess == false) {
            debugPrint(
              'Failed to sync shift on ${shift.date}: ${result?.errors.join(", ")}',
            );
            return 'Failed to sync shift on ${shift.date}: ${result?.errors.join(", ")}';
          }
        }

        return 'Successfully synced ${selectedShifts.length} shifts to ${selectedCalendar.name}';
      } else if (_calendarType == AppStrings.icsFileExport) {
        // Generate ICS file content
        final ics = StringBuffer();
        ics.writeln('BEGIN:VCALENDAR');
        ics.writeln('VERSION:2.0');
        ics.writeln('PRODID:-//SyncMySchedule//EN');
        final dtStamp = DateFormat(
          "yyyyMMdd'T'HHmmss'Z'",
        ).format(DateTime.now().toUtc());

        for (var shift in selectedShifts) {
          final numericReg = RegExp(r'^\d+');
          String numericPart = '';
          String suffix = shift.code;
          if (numericReg.hasMatch(shift.code)) {
            numericPart = numericReg.firstMatch(shift.code)?.group(0) ?? '';
            suffix = shift.code.substring(numericPart.length);
          }

          String specialSuffix = '';
          final specialReg = RegExp(r'[\$\^!]+$');
          if (specialReg.hasMatch(suffix)) {
            specialSuffix = specialReg.firstMatch(suffix)?.group(0) ?? '';
            suffix = suffix.substring(0, suffix.length - specialSuffix.length);
          }

          String title = _shiftLegend[suffix] ?? suffix;
          if (specialSuffix.isNotEmpty)
            title = _shiftLegend[specialSuffix] ?? title;
          final emojiKey = specialSuffix.isNotEmpty ? specialSuffix : suffix;
          final emoji = ShiftLegend.shiftEmojiLegend[emojiKey] ?? '';
          title = '$title $emoji'.trim();

          final baseDate = DateFormat('MM/dd/yyyy').parse(shift.date);
          final isAllDay = _leaveTypes.contains(suffix) || numericPart.isEmpty;

          DateTime startLocal;
          DateTime endLocal;

          if (!isAllDay) {
            try {
              int startMinute = 0;
              int startHour = int.parse(numericPart);
              if (numericPart.length > 2) {
                startMinute = int.parse(
                  numericPart.substring(numericPart.length - 2),
                );
                startHour = int.parse(
                  numericPart.substring(0, numericPart.length - 2),
                );
              }
              if (startHour < 0 ||
                  startHour > 23 ||
                  startMinute < 0 ||
                  startMinute > 59) {
                throw FormatException('Invalid time');
              }
              int duration = _suffixDurations[suffix] ?? 8;
              startLocal = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                startHour,
                startMinute,
              );
              endLocal = startLocal.add(Duration(hours: duration));

              // Overnight → shift one day back
              if (endLocal.day != baseDate.day) {
                startLocal = startLocal.subtract(const Duration(days: 1));
                endLocal = endLocal.subtract(const Duration(days: 1));
              }
            } catch (e) {
              startLocal = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                0,
              );
              endLocal = DateTime(
                baseDate.year,
                baseDate.month,
                baseDate.day,
                23,
                59,
                59,
              );
            }
          } else {
            // All-day shift
            startLocal = DateTime(
              baseDate.year,
              baseDate.month,
              baseDate.day,
              0,
              0,
              0,
            );
            endLocal = DateTime(
              baseDate.year,
              baseDate.month,
              baseDate.day,
              23,
              59,
              59,
            );
          }

          final tzid = _localTzidOrNull();
          ics.writeln('BEGIN:VEVENT');
          ics.writeln(
            'UID:${shift.code}-${shift.date.replaceAll('/', '')}-${DateTime.now().millisecondsSinceEpoch}@syncmyschedule.com',
          );
          ics.writeln('DTSTAMP:$dtStamp');

          if (tzid != null) {
            ics.writeln('DTSTART;TZID=$tzid:${_formatIcsLocal(startLocal)}');
            ics.writeln('DTEND;TZID=$tzid:${_formatIcsLocal(endLocal)}');
          } else {
            ics.writeln('DTSTART:${_formatIcsLocal(startLocal)}');
            ics.writeln('DTEND:${_formatIcsLocal(endLocal)}');
          }

          ics.writeln('SUMMARY:$title');
          ics.writeln('DESCRIPTION:Imported by SyncMySchedule');
          ics.writeln('END:VEVENT');
        }

        ics.writeln('END:VCALENDAR');

        // Handle platform-specific ICS export
        final dir = await getApplicationDocumentsDirectory();
        final filename = 'shifts_${DateTime.now().millisecondsSinceEpoch}.ics';
        final path = '${dir.path}/$filename';
        final file = File(path);
        await file.writeAsString(ics.toString());
        debugPrint('ICS file saved to: $path');

        if (Platform.isIOS) {
          await Share.shareXFiles([XFile(path, mimeType: 'text/calendar')]);
          return 'ICS file exported successfully';
        } else if (Platform.isAndroid) {
          try {
            // Try saving directly to Downloads
            final downloadsDir = Directory('/storage/emulated/0/Download');
            if (!downloadsDir.existsSync()) {
              return 'Downloads folder not found';
            }

            final newPath = '${downloadsDir.path}/$filename';
            final newFile = File(newPath);
            await file.copy(newFile.path);

            debugPrint('ICS file saved to: $newPath');
            return 'ICS file saved successfully to $newPath';
          } catch (e) {
            debugPrint('Error saving ICS on Android: $e');
            return 'Error saving ICS file: $e';
          }

        }

        return 'Unsupported platform';
      }

      return 'Unknown calendar type';
    } catch (e, st) {
      debugPrint('Error syncing shifts: $e\n$st');
      return 'Error syncing shifts: $e';
    }
  }
}
