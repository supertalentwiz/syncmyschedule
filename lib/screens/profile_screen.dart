import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, String> profileData = {
    'phone': '+1 555 123 4567',
    'username': 'MykytaS',
    'email': 'mykyta@example.com',
    'schedulerId': 'user282811',
  };

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF002B53),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 54,
                backgroundColor: orange.withOpacity(0.2),
                child: Text(
                  profileData['username'] != null && profileData['username']!.isNotEmpty
                      ? profileData['username']![0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: orange,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Username
              Text(
                profileData['username'] ?? '',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Email & Phone cards
              _InfoCard(
                icon: Icons.email_outlined,
                label: 'Email',
                value: profileData['email'] ?? '',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: profileData['phone'] ?? '',
              ),
              const SizedBox(height: 12),

              // Scheduler ID smaller card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Scheduler ID: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: orange,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: profileData['schedulerId'] ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Edit Profile button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(initialData: profileData),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: orange, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: orange,
                      fontSize: 14,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
