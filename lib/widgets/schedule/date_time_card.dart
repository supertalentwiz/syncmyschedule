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
    // Button styling constants
    const double borderRadius = 20.0;
    const double borderWidth = 1.0;
    const double buttonHeight = 40.0;
    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 12,
    );
    final TextStyle buttonTextStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, Color(0xFFFFC107)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      constraints: const BoxConstraints(minHeight: AppSizes.dateTimeCardHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            date,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Calendar View Button
              Expanded(
                child: SizedBox(
                  height: buttonHeight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white,
                        width: borderWidth,
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      textStyle: buttonTextStyle,
                      padding: buttonPadding,
                    ),
                    onPressed: () {
                      // TODO: Implement calendar view navigation
                    },
                    child: const Text(
                      'Calendar View',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Dropdown Button
              Expanded(
                child: SizedBox(
                  height: buttonHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedPayPeriod?.isNotEmpty == true
                            ? selectedPayPeriod
                            : null,
                        hint: Text(
                          "Pay Period",
                          style: buttonTextStyle.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        items: payPeriods.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Center(
                              child: Text(
                                period,
                                style: buttonTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: onPayPeriodChanged,
                        dropdownColor: AppColors.accent.withOpacity(0.9),
                        iconEnabledColor: Colors.white,
                        style: buttonTextStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
