import 'package:flutter/material.dart';

class TermsOfUseDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const TermsOfUseDialog({Key? key, required this.onAccept}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF002B53);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Terms of Use',
        style: TextStyle(fontWeight: FontWeight.bold, color: brandBlue),
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to SyncMySchedule.\n\n'
              'By tapping Accept, you agree that:\n'
              '• This app is NOT affiliated with or endorsed by the FAA.\n'
              '• Automation is user-initiated only (you must tap Sync).\n'
              '• Your FAA credentials are stored locally on your device via secure storage and are never uploaded.\n'
              '• The app only accesses your own Web Scheduler data.\n'
              '• No FAA branding or impersonation is used.\n\n'
              'If you do not agree, please close the app.',
              style: TextStyle(fontSize: 14, height: 1.4, color: Colors.orange),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            onAccept();
            Navigator.of(context).pop();
          },
          child: const Text('Accept', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
