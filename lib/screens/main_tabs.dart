import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'main_screen.dart';
import 'subscription_screen.dart';
import 'profile_screen.dart';

class MainTabs extends StatefulWidget {
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _selectedIndex = 0;
  List<Map<String, String>> _shifts = [];

  List<Widget> get _pages => [
        MainScreen(shifts: _shifts),
        SubscriptionScreen(),
        ProfileScreen(),
      ];

  Future<List<Map<String, String>>> fetchScheduleFromFirebase({
    required String username,
    required String password,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('fetchFaaSchedule');

    try {
      final result = await callable.call({
        'username': username,
        'password': password,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['schedule'] != null) {
        List scheduleRaw = data['schedule'];
        return scheduleRaw.map<Map<String, String>>((shift) {
          return {
            'date': shift['date'] ?? '',
            'code': shift['code'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('No schedule returned');
      }
    } catch (e) {
      throw Exception('Error fetching schedule: $e');
    }
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final creds = await _showLoginDialog();
      if (creds == null) return; // user cancelled

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fetching schedule...')),
      );

      try {
        final fetchedShifts = await fetchScheduleFromFirebase(
          username: creds['username']!,
          password: creds['password']!,
        );

        setState(() {
          _shifts = fetchedShifts;
          _selectedIndex = 0; // switch to schedule screen
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Schedule fetched!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch schedule: $e')),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<Map<String, String>?> _showLoginDialog() async {
    final _formKey = GlobalKey<FormState>();
    String username = '';
    String password = '';

    // Orange color used in theme
    const Color orange = Color(0xFFFF9800);

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true, // allow dismiss by tapping outside
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Enter FAA Credentials',
            style: TextStyle(color: orange, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username or Email',
                    labelStyle: TextStyle(color: orange),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: orange, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: orange.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (val) => username = val!.trim(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter username' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: orange),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: orange, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: orange.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  onSaved: (val) => password = val!.trim(),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter password' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: orange)),
              onPressed: () => Navigator.pop(context, null),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('Sync', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {'username': username, 'password': password});
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Color(0xFF002B53),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                size: 32,
                color: _selectedIndex == 0 ? Colors.orange : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(0),
              tooltip: 'Schedule',
            ),

            // Sync Now Button with gradient & margin for vertical positioning
            Container(
              margin: EdgeInsets.only(bottom: 12), // lift button above bottom bar edge
              width: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _onItemTapped(1),
                icon: Icon(Icons.refresh, size: 24, color: Colors.white),
                label: Text(
                  'Sync Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            IconButton(
              icon: Icon(
                Icons.person,
                size: 32,
                color: _selectedIndex == 2 ? Colors.orange : Colors.grey[400],
              ),
              onPressed: () => _onItemTapped(2),
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
