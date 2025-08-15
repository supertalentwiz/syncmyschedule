import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/shift_model.dart';
import '../services/schedule_service.dart';
import '../constants/app_strings.dart';

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

      final location = tz.getLocation('UTC'); // Use UTC for consistency
      for (var shift in selectedShifts) {
        final event = Event(calendar.id);
        event.title = 'Shift: ${shift.code}';
        event.start = tz.TZDateTime.from(
          DateFormat('MM/dd/yyyy').parse(shift.date),
          location,
        );
        event.end = tz.TZDateTime.from(
          event.start!.add(const Duration(days: 1)),
          location,
        );
        event.allDay = true;
        await plugin.createOrUpdateEvent(event);
      }

      return 'Successfully synced ${selectedShifts.length} shifts to calendar';
    } else if (_calendarType == AppStrings.icsFileExport) {
      StringBuffer ics = StringBuffer();
      ics.writeln('BEGIN:VCALENDAR');
      ics.writeln('VERSION:2.0');
      for (var shift in selectedShifts) {
        final start = DateFormat('MM/dd/yyyy').parse(shift.date);
        final end = start.add(const Duration(days: 1));
        ics.writeln('BEGIN:VEVENT');
        ics.writeln(
          'DTSTART;VALUE=DATE:${DateFormat('yyyyMMdd').format(start)}',
        );
        ics.writeln('DTEND;VALUE=DATE:${DateFormat('yyyyMMdd').format(end)}');
        ics.writeln('SUMMARY:Shift: ${shift.code}');
        ics.writeln('END:VEVENT');
      }
      ics.writeln('END:VCALENDAR');

      final dir = await getDownloadsDirectory();
      final path = '${dir?.path}/shifts.ics';
      final file = File(path!);
      await file.writeAsString(ics.toString());

      return 'ICS file exported to $path';
    }

    return 'Unknown calendar type';
  }
}
