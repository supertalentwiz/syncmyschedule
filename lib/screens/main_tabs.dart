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
  String? _errorMessage; // Holds error text to show in schedule screen

  bool _showPassword = false;

  List<Widget> get _pages => [
    MainScreen(shifts: _shifts, errorMessage: _errorMessage),
    SubscriptionScreen(),
    ProfileScreen(),
  ];

  Future<List<Map<String, String>>> fetchScheduleFromFirebase({
    required String username,
    required String password,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'fetchWebFaaSchedule',
    );

    try {
      final result = await callable.call(<String, dynamic>{
        'username': username,
        'password': password,
      });

      final data = result.data as Map<String, dynamic>;

      if (data['schedule'] != null) {
        List scheduleRaw = data['schedule'];
        return scheduleRaw.map<Map<String, String>>((shift) {
          return {
            'day': shift['day'] ?? '',
            'date': shift['date'] ?? '',
            'code': shift['code'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('No schedule returned');
      }
    } catch (e) {
      // Pass the raw error message for display
      throw Exception(e.toString());
    }
  }

  Future<void> _showLoadingModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Fetching schedule...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final creds = await _showLoginDialog();
      if (creds == null) return;

      _showLoadingModal();

      try {
        final fetchedShifts = await fetchScheduleFromFirebase(
          username: creds['username']!,
          password: creds['password']!,
        );

        setState(() {
          _shifts = fetchedShifts;
          _errorMessage = null; // clear previous errors on success
          _selectedIndex = 0; // show schedule screen
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to fetch schedule:\n${e.toString()}';
          _shifts = [];
          _selectedIndex = 0; // show schedule screen with error
        });
      } finally {
        Navigator.of(context).pop(); // close loading modal
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

    const Color orange = Color(0xFFFF9800);

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                          borderSide: BorderSide(
                            color: orange.withOpacity(0.5),
                          ),
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
                          borderSide: BorderSide(
                            color: orange.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: orange,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: !_showPassword,
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
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: Text(
                      'Sync',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pop(context, {
                          'username': username,
                          'password': password,
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          },
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

            Container(
              margin: EdgeInsets.only(bottom: 12),
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
