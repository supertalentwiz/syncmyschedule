import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_strings.dart';
import '../constants/app_sizes.dart';
import '../providers/subscription_provider.dart';
import '../widgets/profile/gradient_button.dart';
import '../widgets/profile/subscription_card.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.subscription),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            Text(
              AppStrings.choosePlan,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.spacingLarge),
            ...List.generate(
              subscriptionProvider.plans.length,
              (index) => SubscriptionCard(
                plan: subscriptionProvider.plans[index],
                isSelected: subscriptionProvider.selectedPlan == index,
                onTap: () => subscriptionProvider.selectPlan(index),
              ),
            ),
            const SizedBox(height: AppSizes.spacingLarge * 1.5),
            GradientButton(
              label: AppStrings.subscribeButton,
              onPressed: subscriptionProvider.selectedPlan == -1
                  ? null
                  : () async {
                      final message = await subscriptionProvider.subscribe();
                      if (message != null && context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
