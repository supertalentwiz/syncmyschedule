import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> initialData;

  const EditProfileScreen({Key? key, required this.initialData}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _schedulerIdController;

  bool _loading = false;

  final _orangeColor = const Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialData['phone']);
    _usernameController = TextEditingController(text: widget.initialData['username']);
    _emailController = TextEditingController(text: widget.initialData['email']);
    _schedulerIdController = TextEditingController(text: widget.initialData['schedulerId']);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _schedulerIdController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    setState(() => _loading = true);

    // Simulate save delay (replace with actual save logic e.g. Firebase)
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _loading = false);

    // Return to ProfileScreen
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _orangeColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _orangeColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF002B53),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: _inputDecoration('Phone'),
              keyboardType: TextInputType.phone,
              style: TextStyle(color: _orangeColor),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: _inputDecoration('Username'),
              style: TextStyle(color: _orangeColor),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration('Email'),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: _orangeColor),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _schedulerIdController,
              decoration: _inputDecoration('Scheduler ID'),
              style: TextStyle(color: _orangeColor),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_loading ? 'Saving...' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
