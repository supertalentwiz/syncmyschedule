import 'package:cloud_functions/cloud_functions.dart';
import '../models/shift_model.dart';

/// Recursively converts a Map with arbitrary keys to Map<String, dynamic>
Map<String, dynamic> deepMapStringDynamic(Map input) {
  final result = <String, dynamic>{};
  input.forEach((key, value) {
    final k = key.toString();
    if (value is Map) {
      result[k] = deepMapStringDynamic(value);
    } else if (value is List) {
      result[k] = value.map((e) {
        if (e is Map) return deepMapStringDynamic(e);
        return e;
      }).toList();
    } else {
      result[k] = value;
    }
  });
  return result;
}

class ScheduleService {
  Future<Map<String, dynamic>> fetchSchedule({
    required String username,
    required String password,
    String? periodId,
    List<dynamic>? cookies,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'fetchWebFaaShifts',
    );

    try {
      final result = await callable.call(<String, dynamic>{
        'username': username,
        'password': password,
        if (periodId != null) 'periodId': periodId,
        if (cookies != null) 'cookies': cookies,
      });

      // Deep conversion to Map<String, dynamic>
      final rawData = result.data;
      if (rawData == null || rawData is! Map) {
        throw Exception("Invalid response from server");
      }
      final data = deepMapStringDynamic(rawData);

      // Parse schedule
      List<ShiftModel> schedule = [];
      if (data['schedule'] != null) {
        schedule = (data['schedule'] as List)
            .map(
              (shift) => ShiftModel.fromJson(Map<String, dynamic>.from(shift)),
            )
            .toList();
      }

      // Parse payPeriods
      List<String> payPeriods = [];
      if (data['payPeriods'] != null) {
        payPeriods = (data['payPeriods'] as List)
            .map((p) => (p['value'] ?? '').toString())
            .where((p) => p.isNotEmpty)
            .toList();
      }

      // Grab cookies
      List<dynamic>? newCookies;
      if (data['cookies'] != null && data['cookies'] is List) {
        newCookies = List<Map<String, dynamic>>.from(data['cookies']);
      }

      return {
        'schedule': schedule,
        'payPeriods': payPeriods,
        'cookies': newCookies,
      };
    } catch (e) {
      String message = 'Failed to fetch schedule';
      if (e is FirebaseFunctionsException) {
        message = e.message ?? message;
      } else {
        message = e.toString();
      }
      throw Exception(message);
    }
  }
}
