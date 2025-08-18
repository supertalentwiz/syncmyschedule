import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  ProfileModel _profile = ProfileModel(
    phone: '',
    username: 'Unknown User',
    email: 'No Email',
    schedulerId: '',
  );

  ProfileModel get profile => _profile;

  ProfileProvider() {
    // Fetch profile data when the provider is initialized
    if (auth.FirebaseAuth.instance.currentUser != null) {
      fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    try {
      _profile = await _profileService.fetchProfile();
      notifyListeners();
    } catch (e) {
      // Handle errors (e.g., no user signed in)
      if (kDebugMode) {
        print('Error fetching profile: $e');
      }
    }
  }

  Future<void> updateProfile(ProfileModel newProfile) async {
    await _profileService.updateProfile(newProfile.toMap());
    _profile = newProfile;
    notifyListeners();
  }
}
