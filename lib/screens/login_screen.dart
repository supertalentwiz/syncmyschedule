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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => const ErrorDialog(
            message: 'Please fill in both email and password.',
          ),
        );
      }
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) =>
              const ErrorDialog(message: 'Please enter a valid email address.'),
        );
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final error = await authProvider.signIn(email, password);
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
              height: AppSizes.headerHeightLogin,
              showLogo: true,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.spacingLarge),
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
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
                  const SizedBox(height: AppSizes.spacingLarge),
                  AuthButton(
                    isLoading: authProvider.isLoading,
                    label: AppStrings.signIn,
                    loadingLabel: AppStrings.signingIn,
                    onPressed: _signIn,
                  ),
                  const SizedBox(height: AppSizes.spacingLarge),
                  AuthNavigationText(
                    prompt: AppStrings.noAccount,
                    actionText: AppStrings.signUpHere,
                    onTap: () => Navigator.pushNamed(context, '/register'),
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
