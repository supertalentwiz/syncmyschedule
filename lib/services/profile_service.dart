import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel> fetchProfile() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    return ProfileModel(
      phone: '', // Placeholder, as phone is not stored in Firebase Auth
      username: user.displayName ?? 'Unknown User',
      email: user.email ?? 'No Email',
      schedulerId:
          '', // Placeholder, as schedulerId is not stored in Firebase Auth
    );
  }

  Future<void> updateProfile(Map<String, String> data) async {
    // final user = auth.FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   await user.updateDisplayName(data['username']);
    //   await user.updateEmail(data['email'] ?? '');
    //   // Note: Phone and schedulerId would require Firestore or another storage solution
    // }
  }
}
