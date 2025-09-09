import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  Widget _buildPlanCard({
    required String title,
    required String description,
    required String price,
    required bool isFree,
    required bool isCurrent,
  }) {
    final bool showButton = !isFree;
    final String buttonText = isCurrent
        ? AppStrings.cancel
        : AppStrings.subscribeButton;
    final Color buttonColor = isCurrent ? Colors.grey : AppColors.accent;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppSizes.cardSpacing,
        horizontal: AppSizes.padding,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Current Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingExtraSmall),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: AppSizes.spacingMiddleSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                if (showButton)
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Handle subscription or cancel logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                      ),
                    ),
                    child: Text(buttonText),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const currentPlan = "Trainee"; // Example current plan

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          AppStrings.subscription,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSizes.spacingSmall),
            child: Center(
              child: Text(
                AppStrings.choosePlan,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          _buildPlanCard(
            title: AppStrings.observerPlan,
            description: AppStrings.observerPlanDesc,
            price: "Free",
            isFree: true,
            isCurrent: currentPlan == AppStrings.observerPlan,
          ),
          _buildPlanCard(
            title: AppStrings.traineePlan,
            description: AppStrings.traineePlanDesc,
            price: "\$3.99 / month",
            isFree: false,
            isCurrent: currentPlan == AppStrings.traineePlan,
          ),
          _buildPlanCard(
            title: AppStrings.cpcPlan,
            description: AppStrings.cpcPlanDesc,
            price: "\$25 / year",
            isFree: false,
            isCurrent: currentPlan == AppStrings.cpcPlan,
          ),
          const SizedBox(height: AppSizes.spacingLarge),
        ],
      ),
    );
  }
}
