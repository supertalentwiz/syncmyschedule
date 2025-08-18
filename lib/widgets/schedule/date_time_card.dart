import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class DateTimeCard extends StatelessWidget {
  final String date;
  final String time;

  const DateTimeCard({super.key, required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSizes.borderRadius),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      constraints: const BoxConstraints(minHeight: AppSizes.dateTimeCardHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            time,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.background.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
