import 'package:cloud_functions/cloud_functions.dart';

class FunctionsService {
  final functions = FirebaseFunctions.instance;
  Future<List<dynamic>> fetchMockSchedule() async {
    final callable = functions.httpsCallable('fetchScheduleMock');
    final result = await callable.call();
    if (result.data['success'] == true) {
      return result.data['schedule'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch schedule');
    }
  }
}
