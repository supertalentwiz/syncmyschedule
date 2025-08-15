import 'package:flutter/material.dart';
import '../../constants/app_sizes.dart';

class AuthButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final String loadingLabel;
  final VoidCallback? onPressed;

  const AuthButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.loadingLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: Text(
          isLoading ? loadingLabel : label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppSizes.buttonFontSize,
          ),
        ),
      ),
    );
  }
}
