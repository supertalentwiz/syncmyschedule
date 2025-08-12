import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final List<Map<String, String>> shifts;

  const MainScreen({Key? key, required this.shifts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        backgroundColor: const Color(0xFF002B53),
        foregroundColor: Colors.white,
      ),
      body: shifts.isEmpty
          ? Center(
              child: Text(
                'No schedule loaded. Tap "Sync Now" to fetch your shifts.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: shifts.length,
              itemBuilder: (context, index) {
                final shift = shifts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.event_note, color: Colors.orange),
                    title: Text(
                      'Shift Code: ${shift['code']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Date: ${shift['date']}'),
                  ),
                );
              },
            ),
    );
  }
}
