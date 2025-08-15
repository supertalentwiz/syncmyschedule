import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel> fetchProfile() async {
    return ProfileModel(
      phone: '+1 555 123 4567',
      username: 'MykytaS',
      email: 'mykyta@example.com',
      schedulerId: 'user282811',
    );
  }

  Future<void> updateProfile(Map<String, String> data) async {
    // Placeholder: Implement Firebase update logic
  }
}
