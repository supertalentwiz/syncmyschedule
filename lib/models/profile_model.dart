class ProfileModel {
  final String phone;
  final String username;
  final String email;
  final String schedulerId;

  ProfileModel({
    required this.phone,
    required this.username,
    required this.email,
    required this.schedulerId,
  });

  factory ProfileModel.fromMap(Map<String, String> data) {
    return ProfileModel(
      phone: data['phone'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      schedulerId: data['schedulerId'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'phone': phone,
      'username': username,
      'email': email,
      'schedulerId': schedulerId,
    };
  }
}
