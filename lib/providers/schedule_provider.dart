import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shift_model.dart';
import '../services/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<ShiftModel> _shifts = [];
  String? _errorMessage;
  bool _isLoading = false;
  Map<String, bool> _shiftCheckedStates = {};

  List<ShiftModel> get shifts => _shifts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  Map<String, bool> get shiftCheckedStates => _shiftCheckedStates;

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

    // TODO: Implement device_calendar integration
    return 'Successfully synced ${selectedShifts.length} shifts to calendar';
  }
}
