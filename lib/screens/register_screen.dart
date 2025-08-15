import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth/auth_button.dart';
import '../widgets/auth/auth_header.dart';
import '../widgets/auth/custom_text_field.dart';
import '../widgets/auth/auth_navigation_text.dart';
import '../widgets/common/error_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  bool _showPassword = false;
  bool _showPassword2 = false;

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final password2 = _password2Controller.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        password2.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            message: 'Please fill out all required fields.',
          ),
        );
      }
      return;
    }

    if (password != password2) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(message: 'Passwords do not match.'),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.register(email, password);
    if (error != null && mounted) {
      showDialog(
        context: context,
        builder: (_) => ErrorDialog(message: error),
      );
      return;
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              height: AppSizes.headerHeightRegister,
              showLogo: false,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.spacingLarge),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number (Optional)',
                    hint: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: 'Enter your password',
                    obscure: !_showPassword,
                    onToggleVisibility: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  CustomTextField(
                    controller: _password2Controller,
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    obscure: !_showPassword2,
                    onToggleVisibility: () =>
                        setState(() => _showPassword2 = !_showPassword2),
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),
                  AuthButton(
                    isLoading: authProvider.isLoading,
                    label: AppStrings.signUp,
                    loadingLabel: AppStrings.signingUp,
                    onPressed: _register,
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),
                  AuthNavigationText(
                    prompt: AppStrings.haveAccount,
                    actionText: AppStrings.signInHere,
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
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
