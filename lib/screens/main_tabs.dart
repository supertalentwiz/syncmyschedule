import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  String? _errorMessage;
  bool _showPassword = false;
  final _storage = const FlutterSecureStorage();

  List<Widget> get _pages => [
    MainScreen(shifts: _shifts, errorMessage: _errorMessage),
    SubscriptionScreen(),
    ProfileScreen(),
  ];

  Future<List<Map<String, String>>> fetchScheduleFromFirebase({
    required String username,
    required String password,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('fetchFaaShifts');
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
      String message = 'Failed to fetch schedule';
      if (e is FirebaseFunctionsException) {
        message = e.message ?? message;
      } else {
        message = e.toString();
      }
      throw Exception(message);
    }
  }

  Future<void> _showLoadingModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Text(
                'Fetching schedule...',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
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
                    const SizedBox(height: 12),
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
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.pop(context, {
                        'username': username,
                        'password': password,
                      });
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Use saved FAA credentials?'),
            content: const Text(
              'You have saved FAA credentials. Continue with them or edit?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Edit credentials'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('OK'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      Map<String, String>? creds;

      final savedUsername = await _storage.read(key: 'faa_username');
      final savedPassword = await _storage.read(key: 'faa_password');

      if (savedUsername != null && savedPassword != null) {
        final useSaved = await _showConfirmDialog();
        if (useSaved) {
          creds = {'username': savedUsername, 'password': savedPassword};
        } else {
          creds = await _showLoginDialog();
          if (creds != null) {
            await _storage.write(key: 'faa_username', value: creds['username']);
            await _storage.write(key: 'faa_password', value: creds['password']);
          }
        }
      } else {
        creds = await _showLoginDialog();
        if (creds != null) {
          await _storage.write(key: 'faa_username', value: creds['username']);
          await _storage.write(key: 'faa_password', value: creds['password']);
        }
      }

      if (creds == null) return;

      _showLoadingModal();

      try {
        final fetchedShifts = await fetchScheduleFromFirebase(
          username: creds['username']!,
          password: creds['password']!,
        );

        setState(() {
          _shifts = fetchedShifts;
          _errorMessage = null;
          _selectedIndex = 0;
        });
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _shifts = [];
          _selectedIndex = 0;
        });
      } finally {
        if (Navigator.canPop(context)) Navigator.pop(context); // close loading
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 160,
              child: ElevatedButton.icon(
                onPressed: () => _onItemTapped(1),
                icon: const Icon(Icons.refresh, size: 24, color: Colors.white),
                label: const Text(
                  'Sync Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.orange,
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
            ),
          ],
        ),
      ),
    );
  }
}
