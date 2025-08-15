import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncmyschedule/widgets/common/custom_app_bar.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_sizes.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';
import '../widgets/auth/custom_text_field.dart';
import '../widgets/profile/gradient_button.dart';
import '../widgets/common/error_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> initialData;

  const EditProfileScreen({super.key, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schedulerIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.initialData['username'] ?? '';
    _emailController.text = widget.initialData['email'] ?? '';
    _phoneController.text = widget.initialData['phone'] ?? '';
    _schedulerIdController.text = widget.initialData['schedulerId'] ?? '';
  }

  Future<void> _saveProfile() async {
    final profile = ProfileModel(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      schedulerId: _schedulerIdController.text.trim(),
    );

    if (profile.username.isEmpty || profile.email.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) =>
              const ErrorDialog(message: 'Username and email are required.'),
        );
      }
      return;
    }

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    await profileProvider.updateProfile(profile);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.editProfile),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Enter your username',
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              CustomTextField(
                controller: _emailController,
                label: AppStrings.email,
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              CustomTextField(
                controller: _phoneController,
                label: AppStrings.phone,
                hint: 'Enter your phone number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.spacingSmall),
              CustomTextField(
                controller: _schedulerIdController,
                label: AppStrings.schedulerId,
                hint: 'Enter your scheduler ID',
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              GradientButton(label: 'Save Profile', onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }
}
