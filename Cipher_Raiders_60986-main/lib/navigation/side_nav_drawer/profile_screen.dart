import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color darkGreenPrimary = Color(0xFF1E5128); // Primary
  static const Color mediumGreen = Color(0xFF2D6A4F);      // Medium Accent
  static const Color softGreenBackground = Color(0xFFF0F9F0); // Background
  static const Color veryLightGreen = Color(0xFFE8F5E9);     // Lighter area background
  static const Color mutedGreenText = Color(0xFF558B5F);    // Text color
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dummy data for demonstration
  final String _userName = '';
  final String _userEmail = '';
  final String _userPhone = '';

  // Custom AppBar Widget
  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      // Dark Green Primary App Bar
      backgroundColor: AppColors.darkGreenPrimary,
      title: const Text(
        'My Profile',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      elevation: 0, // App Bar के नीचे shadow हटा दिया
    );
  }

  // Helper Widget for detail tiles
  Widget _buildProfileTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.mutedGreenText,
        size: 28,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.mutedGreenText,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: AppColors.darkGreenPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Action
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion का उपयोग Status Bar को App Bar से match करने के लिए
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.darkGreenPrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: _buildCustomAppBar(context),
        backgroundColor: AppColors.softGreenBackground,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // --- 📸 Profile Photo (Edit) Section ---
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // Circular Profile Image Placeholder
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.veryLightGreen,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: AppColors.mediumGreen,
                    ),
                  ),
                  // Edit Icon on the photo
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Change Profile Picture'),
                            backgroundColor: AppColors.darkGreenPrimary,
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.mediumGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // --- 📝 Profile Details Section (Name, Email, Phone) ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mutedGreenText.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProfileTile(
                      icon: Icons.person_outline,
                      label: 'Name',
                      value: _userName,
                    ),
                    const Divider(color: Color(0xFFE0E0E0), height: 25, thickness: 0.8),
                    _buildProfileTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _userEmail,
                    ),
                    const Divider(color: Color(0xFFE0E0E0), height: 25, thickness: 0.8),
                    _buildProfileTile(
                      icon: Icons.phone_android_outlined,
                      label: 'Phone',
                      value: _userPhone,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // --- ✏️ Edit Profile Button with Pencil Icon ---
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit Profile Pressed!'),
                      backgroundColor: AppColors.darkGreenPrimary,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4CAF50),
                        AppColors.darkGreenPrimary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkGreenPrimary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}