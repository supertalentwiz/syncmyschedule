import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_sizes.dart';
import '../providers/profile_provider.dart';
import '../providers/schedule_provider.dart';
import '../screens/edit_profile_screen.dart';
import '../widgets/common/calendar_selection_dialog.dart';
import '../widgets/profile/info_card.dart';
import '../widgets/profile/profile_avatar.dart';
import '../widgets/profile/gradient_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
      ),
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
                icon: Icons.phone_outlined,
                label: AppStrings.phone,
                value: profile.phone,
              ),
              const SizedBox(height: AppSizes.cardSpacing),
              InfoCard(
                icon: Icons.perm_identity,
                label: AppStrings.schedulerId,
                value: profile.schedulerId,
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
              const Spacer(),
              GradientButton(
                label: AppStrings.editProfile,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditProfileScreen(initialData: profile.toMap()),
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
