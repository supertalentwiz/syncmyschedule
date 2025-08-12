import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schedulerIdController = TextEditingController();
  final _schedulerPwdController = TextEditingController();

  void _saveChanges() {
    // Implement save logic here (e.g. save to Firebase or local storage)
    Navigator.pushNamed(context, '/subscription');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _schedulerIdController.dispose();
    _schedulerPwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF002B53),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone', filled: true, fillColor: Colors.grey[200]),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username', filled: true, fillColor: Colors.grey[200]),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.grey[200]),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.grey[200]),
              obscureText: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _schedulerIdController,
              decoration: InputDecoration(labelText: 'Scheduler ID', filled: true, fillColor: Colors.grey[200]),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _schedulerPwdController,
              decoration: InputDecoration(labelText: 'Scheduler Password', filled: true, fillColor: Colors.grey[200]),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
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
