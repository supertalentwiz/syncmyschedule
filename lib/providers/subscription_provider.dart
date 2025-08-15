import 'package:flutter/foundation.dart';

class SubscriptionProvider with ChangeNotifier {
  int _selectedPlan = -1;
  final List<String> _plans = [
    '1 Month / \$14.99',
    '3 Months / \$29.99',
    '6 Months / \$49.99',
  ];

  int get selectedPlan => _selectedPlan;
  List<String> get plans => _plans;

  void selectPlan(int index) {
    _selectedPlan = index;
    notifyListeners();
  }

  Future<String?> subscribe() async {
    if (_selectedPlan == -1) return 'Please select a plan';
    return 'Subscribed to ${_plans[_selectedPlan]}';
  }
}
