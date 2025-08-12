import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();

  bool _showPassword = false;
  bool _showPassword2 = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Color(0xFF002B53),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final password2 = _password2Controller.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || password2.isEmpty) {
      _showDialog('Please fill out all required fields.');
      return;
    }

    if (password != password2) {
      _showDialog('Passwords do not match.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      _showDialog(e.message ?? 'Registration failed.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Registration Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.orange),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.orange.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.orange),
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, hint: hint),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xFF002B53),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'S',
                      style: TextStyle(color: Colors.orange, fontSize: 32, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'ync', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'M', style: TextStyle(color: Colors.orange)),
                        TextSpan(text: 'y', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'S', style: TextStyle(color: Colors.orange)),
                        TextSpan(text: 'chedule', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  _textField(controller: _nameController, label: 'Full Name', hint: 'Enter your full name'),
                  SizedBox(height: 15),
                  _textField(controller: _emailController, label: 'Email', hint: 'Enter your email', keyboardType: TextInputType.emailAddress),
                  SizedBox(height: 15),
                  _textField(controller: _phoneController, label: 'Phone Number (Optional)', hint: 'Enter your phone number', keyboardType: TextInputType.phone),
                  SizedBox(height: 15),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      _textField(controller: _passwordController, label: 'Password', hint: 'Enter your password', obscure: !_showPassword),
                      IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.orange,
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      _textField(controller: _password2Controller, label: 'Confirm Password', hint: 'Re-enter your password', obscure: !_showPassword2),
                      IconButton(
                        icon: Icon(
                          _showPassword2 ? Icons.visibility_off : Icons.visibility,
                          color: Colors.orange,
                        ),
                        onPressed: () => setState(() => _showPassword2 = !_showPassword2),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: Text(
                        _loading ? 'Signing up...' : 'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF002B53),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Color(0xFF002B53)),
                        children: [TextSpan(text: 'Sign in here', style: TextStyle(color: Colors.orange))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
