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

  static const Map<String, int> _suffixDurations = {
    'AWS': 10, // default duration in hours
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
    if (selectedShifts.isEmpty) return 'No shifts selected to sync';
    if (_calendarType == AppStrings.none) return 'No calendar type selected';

    try {
      final tzid = _localTzidOrNull();
      final location = tz.getLocation(tz.local.name);

      if (_calendarType == AppStrings.icsFileExport) {
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

          ics.writeln('BEGIN:VEVENT');
          ics.writeln(
            'UID:${shift.code}-${shift.date.replaceAll('/', '')}-${DateTime.now().millisecondsSinceEpoch}@syncmyschedule.com',
          );
          ics.writeln('DTSTAMP:$dtStamp');

          if (!isAllDay) {
            int startHour = int.parse(numericPart);
            int duration = _suffixDurations[suffix] ?? 8;
            int startMinute = 0;

            if (numericPart.length > 2) {
              startMinute = int.parse(
                numericPart.substring(numericPart.length - 2),
              );
              startHour = int.parse(
                numericPart.substring(0, numericPart.length - 2),
              );
            }

            DateTime startLocal = DateTime(
              baseDate.year,
              baseDate.month,
              baseDate.day,
              startHour,
              startMinute,
            );
            DateTime endLocal = startLocal.add(Duration(hours: duration));

            // If end is on next day, automatically increment
            if (endLocal.isBefore(startLocal))
              endLocal = endLocal.add(const Duration(days: 1));

            if (tzid != null) {
              ics.writeln('DTSTART;TZID=$tzid:${_formatIcsLocal(startLocal)}');
              ics.writeln('DTEND;TZID=$tzid:${_formatIcsLocal(endLocal)}');
            } else {
              ics.writeln('DTSTART:${_formatIcsLocal(startLocal)}');
              ics.writeln('DTEND:${_formatIcsLocal(endLocal)}');
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
          ics.writeln('DESCRIPTION:Imported by SyncMySchedule');
          ics.writeln('END:VEVENT');
        }

        ics.writeln('END:VCALENDAR');
        final dir = await getApplicationDocumentsDirectory();
        final path =
            '${dir.path}/shifts_${DateTime.now().millisecondsSinceEpoch}.ics';
        final file = File(path);
        await file.writeAsString(ics.toString());
        await Share.shareXFiles([XFile(path)]);
        return 'ICS file exported successfully';
      }

      return 'Unknown calendar type';
    } catch (e, st) {
      debugPrint('Error syncing shifts: $e\n$st');
      return 'Error syncing shifts: $e';
    }
  }
}
