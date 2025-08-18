import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:syncmyschedule/widgets/common/calendar_selection_dialog.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_sizes.dart';
import '../providers/profile_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/profile/info_card.dart';
import '../widgets/profile/profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is signed in
    if (auth.FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox();
    }

    final profile = Provider.of<ProfileProvider>(context).profile;
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.profile),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.padding,
            vertical: AppSizes.spacingLarge,
          ),
          child: Column(
            children: [
              ProfileAvatar(username: profile.username),
              const SizedBox(height: AppSizes.spacingSmall),
              Text(
                profile.username,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSizes.cardSpacing),
              InfoCard(
                icon: Icons.email_outlined,
                label: AppStrings.email,
                value: profile.email,
              ),
              const SizedBox(height: AppSizes.cardSpacing),
              InfoCard(
                icon: Icons.calendar_today,
                label: AppStrings.calendarType,
                value: scheduleProvider.calendarType,
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => CalendarSelectionDialog(
                    scheduleProvider: scheduleProvider,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
