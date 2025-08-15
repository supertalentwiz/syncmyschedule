import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  ProfileModel _profile = ProfileModel(
    phone: '+1 555 123 4567',
    username: 'MykytaS',
    email: 'mykyta@example.com',
    schedulerId: 'user282811',
  );

  ProfileModel get profile => _profile;

  Future<void> fetchProfile() async {
    _profile = await _profileService.fetchProfile();
    notifyListeners();
  }

  Future<void> updateProfile(ProfileModel newProfile) async {
    await _profileService.updateProfile(newProfile.toMap());
    _profile = newProfile;
    notifyListeners();
  }
}
