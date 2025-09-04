import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class DateTimeCard extends StatelessWidget {
  final String date;
  final List<String> payPeriods;
  final String? selectedPayPeriod;
  final ValueChanged<String?>? onPayPeriodChanged;

  const DateTimeCard({
    super.key,
    required this.date,
    required this.payPeriods,
    this.selectedPayPeriod,
    this.onPayPeriodChanged,
  });

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(date, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Calendar View'),
              ),
              DropdownButton<String>(
                value: selectedPayPeriod,
                hint: const Text('Select Pay Period'),
                items: payPeriods
                    .map(
                      (period) => DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      ),
                    )
                    .toList(),
                onChanged: onPayPeriodChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
