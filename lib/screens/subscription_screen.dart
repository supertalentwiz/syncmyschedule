import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = -1;

  final List<String> plans = [
  '1 Month / \$14.99',
  '3 Months / \$29.99',
  '6 Months / \$49.99',
];

  void _selectPlan(int index) {
    setState(() {
      _selectedPlan = index;
    });
  }

  void _subscribe() {
    if (_selectedPlan == -1) return;
    // Implement subscription logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Subscribed to ${plans[_selectedPlan]}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription'),
        backgroundColor: Color(0xFF002B53),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Choose your subscription plan:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ...List.generate(plans.length, (index) {
              final selected = _selectedPlan == index;
              return GestureDetector(
                onTap: () => _selectPlan(index),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? Colors.orange : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selected ? Colors.orange : Colors.transparent),
                  ),
                  child: Row(
                    children: [
                      Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: selected ? Colors.white : Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        plans[index],
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _selectedPlan == -1 ? null : _subscribe,
              child: Text('Subscribe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
