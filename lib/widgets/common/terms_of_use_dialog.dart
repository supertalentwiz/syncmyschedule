import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class TermsOfUseDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const TermsOfUseDialog({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.dialogBorderRadius),
      ),
      title: Text(
        'Terms of Use',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300, // Fixed height for scrolling content
        child: SingleChildScrollView(
          child: Text(
            '''
Welcome to SyncMySchedule — a personal tool to help you view and sync your FAA schedule.

This app uses your FAA credentials to fetch schedule data. All data is encrypted and stored securely using FlutterSecureStorage. Use of this app is subject to FAA policies and guidelines. By accepting, you agree to these terms.

1. Unofficial Application

This app is not developed, endorsed, or affiliated with the Federal Aviation Administration (FAA) or any related entity.

2. Personal Use Only

This tool is intended for your own schedule management. You may not use it to access, store, or share another person’s schedule or data.

3. User-Provided Credentials

Your FAA Web Scheduler login credentials are stored only on your device using secure encryption. They are never sent to or stored on our servers.

4. Manual Sync Process

Schedule data is fetched only when you choose to sync. The app will not automatically access your FAA account without your action.

5. No Warranty

While we strive for accuracy, we cannot guarantee the correctness or completeness of any data displayed. Always verify schedule information through official FAA systems.

6. Your Responsibility

You are responsible for complying with FAA policies, rules, and terms of service when using this app.

Any automation is limited to user-triggered schedule retrieval within FAA’s allowed usage scope.

7. Limitation of Liability

We are not liable for any loss, delay, or consequence arising from the use of this app, including but not limited to missed shifts, schedule errors, or FAA access restrictions.
            ''',
            style: const TextStyle(
              color: Colors.orange,
              height: 1.4,
              fontSize: 14,
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.padding,
        vertical: AppSizes.spacingSmall,
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              SystemNavigator.pop(); // try graceful exit
              exit(0);
            } else {
              exit(0); // fallback
            }
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          child: const Text(
            'Decline & Exit',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onAccept();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.padding,
              vertical: AppSizes.buttonHeight,
            ),
          ),
          child: const Text(
            'Accept',
            style: TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
