import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncmyschedule/constants/app_colors.dart';
import 'package:syncmyschedule/constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../providers/schedule_provider.dart';
import '../screens/main_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/common/loading_dialog.dart';
import '../widgets/common/terms_of_use_dialog.dart';
import '../widgets/schedule/bottom_navigation.dart';
import '../widgets/auth/custom_text_field.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAndShowTerms();
  }

  Future<void> _checkAndShowTerms() async {
    final scheduleProvider = Provider.of<ScheduleProvider>(
      context,
      listen: false,
    );
    final accepted = await scheduleProvider.checkTermsAccepted();
    print(accepted);
    if (!accepted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              TermsOfUseDialog(onAccept: scheduleProvider.acceptTerms),
        );
      });
    }
  }

  Future<Map<String, String>?> _showLoginDialog() async {
    final _formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    bool showPassword = false;

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppStrings.faaCredentials,
                style: TextStyle(color: AppColors.primary),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: usernameController,
                      label: AppStrings.usernameOrEmail,
                      hint: 'Enter username',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter username'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: passwordController,
                      label: AppStrings.password,
                      hint: 'Enter password',
                      obscure: !showPassword,
                      onToggleVisibility: () =>
                          setState(() => showPassword = !showPassword),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter password'
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, null),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context, {
                        'username': usernameController.text.trim(),
                        'password': passwordController.text.trim(),
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.padding,
                      vertical: AppSizes.buttonHeight,
                    ),
                  ),
                  child: const Text(
                    'Sync',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      final scheduleProvider = Provider.of<ScheduleProvider>(
        context,
        listen: false,
      );
      final accepted = await scheduleProvider.checkTermsAccepted();
      if (!accepted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              TermsOfUseDialog(onAccept: scheduleProvider.acceptTerms),
        );
        return;
      }

      Map<String, String>? creds = await scheduleProvider.getSavedCredentials();
      if (creds != null) {
        final useSaved =
            await showDialog<bool>(
              context: context,
              builder: (_) => ConfirmDialog(
                onConfirm: () => Navigator.pop(context, true),
                onCancel: () => Navigator.pop(context, false),
              ),
            ) ??
            false;
        if (!useSaved) {
          creds = await _showLoginDialog();
          if (creds != null) {
            await scheduleProvider.saveCredentials(
              creds['username']!,
              creds['password']!,
            );
          }
        }
      } else {
        creds = await _showLoginDialog();
        if (creds != null) {
          await scheduleProvider.saveCredentials(
            creds['username']!,
            creds['password']!,
          );
        }
      }

      if (creds == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const LoadingDialog(),
      );

      await scheduleProvider.fetchSchedule(
        creds['username']!,
        creds['password']!,
      );
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() => _selectedIndex = 0);
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const MainScreen(),
        const SubscriptionScreen(),
        const ProfileScreen(),
      ][_selectedIndex],
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
