import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class TermsOfUseDialog extends StatelessWidget {
  final VoidCallback onAccept;

  const TermsOfUseDialog({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Terms of Use', style: TextStyle(color: AppColors.primary)),
      content: const Text(
        'Please read and accept the terms of use to continue.',
        style: TextStyle(color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Decline', style: TextStyle(color: AppColors.accent)),
        ),
        ElevatedButton(
          onPressed: () {
            onAccept();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          child: const Text(
            'Accept',
            style: TextStyle(color: AppColors.background),
          ),
        ),
      ],
    );
  }
}
