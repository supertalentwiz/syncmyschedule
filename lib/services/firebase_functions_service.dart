import 'package:cloud_functions/cloud_functions.dart';

class FirebaseFunctionsService {
  final HttpsCallable fetchScheduleCallable = FirebaseFunctions.instance.httpsCallable('fetchSchedule');

  Future<List<Map<String, dynamic>>> fetchSchedule(String username, String password) async {
    try {
      final result = await fetchScheduleCallable.call({
        'username': username,
        'password': password,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        final List<dynamic> shifts = data['shifts'];
        return shifts.map((shift) => Map<String, dynamic>.from(shift)).toList();
      } else {
        throw Exception('Failed to fetch shifts');
      }
    } catch (e) {
      throw Exception('Cloud Function call failed: $e');
    }
  }
}
