import 'package:cloud_functions/cloud_functions.dart';
import '../models/shift_model.dart';

class ScheduleService {
  Future<Map<String, dynamic>> fetchSchedule({
    required String username,
    required String password,
    String? periodId, // optional for subsequent calls
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('fetchFaaShifts');

    try {
      final result = await callable.call(<String, dynamic>{
        'username': username,
        'password': password,
        if (periodId != null) 'periodId': periodId,
      });

      final data = Map<String, dynamic>.from(result.data as Map);

      // Parse schedule
      List<ShiftModel> schedule = [];
      if (data['schedule'] != null) {
        schedule = (data['schedule'] as List)
            .map((shift) => ShiftModel.fromJson(Map<String, dynamic>.from(shift)))
            .toList();
      }

      // Parse payPeriods (optional, only returned on initial call)
      List<String> payPeriods = [];
      if (data['payPeriods'] != null) {
        payPeriods = (data['payPeriods'] as List)
            .map((p) => (p['value'] ?? '').toString())
            .where((p) => p.isNotEmpty)
            .toList();
      }

      // Return both schedule and payPeriods
      return {
        'schedule': schedule,
        'payPeriods': payPeriods,
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
