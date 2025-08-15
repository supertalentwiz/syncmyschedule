import 'package:cloud_functions/cloud_functions.dart';
import '../models/shift_model.dart';

class ScheduleService {
  Future<List<ShiftModel>> fetchSchedule({
    required String username,
    required String password,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('fetchFaaShifts');
    try {
      final result = await callable.call(<String, dynamic>{
        'username': username,
        'password': password,
      });
      // Convert result.data to Map<String, dynamic> safely
      final data = Map<String, dynamic>.from(result.data as Map);
      if (data['schedule'] != null) {
        return (data['schedule'] as List)
            .map(
              (shift) => ShiftModel.fromJson(Map<String, dynamic>.from(shift)),
            )
            .toList();
      } else {
        throw Exception('No schedule returned');
      }
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
