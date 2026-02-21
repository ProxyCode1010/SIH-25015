import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color darkGreenPrimary = Color(0xFF1E5128);
  static const Color mediumGreen = Color(0xFF2D6A4F);
  static const Color softGreenBackground = Color(0xFFF0F9F0);
  static const Color veryLightGreen = Color(0xFFE8F5E9);
  static const Color mutedGreenText = Color(0xFF558B5F);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light'; // 'Light' or 'Dark'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = _prefs.getString('app_language') ?? 'English';
      _selectedTheme = _prefs.getString('app_theme') ?? 'Light';
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    await _prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _changeLanguage(String language) async {
    await _prefs.setString('app_language', language);
    setState(() => _selectedLanguage = language);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $language'),
        backgroundColor: AppColors.darkGreenPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _changeTheme(String theme) async {
    await _prefs.setString('app_theme', theme);
    setState(() => _selectedTheme = theme);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to $theme mode'),
        backgroundColor: AppColors.darkGreenPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Language',
          style: TextStyle(color: AppColors.darkGreenPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'English'),
            const SizedBox(height: 12),
            _buildLanguageOption('Hindi', 'हिंदी'),
            const SizedBox(height: 12),
            _buildLanguageOption('Punjabi', 'ਪੰਜਾਬੀ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mediumGreen)),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Theme',
          style: TextStyle(color: AppColors.darkGreenPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Light', Icons.light_mode),
            const SizedBox(height: 12),
            _buildThemeOption('Dark', Icons.dark_mode),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mediumGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, String nativeName) {
    bool isSelected = _selectedLanguage == language;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _changeLanguage(language),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.veryLightGreen : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.darkGreenPrimary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) => _changeLanguage(value!),
                activeColor: AppColors.darkGreenPrimary,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.darkGreenPrimary : Colors.black87,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon) {
    bool isSelected = _selectedTheme == theme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _changeTheme(theme),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.veryLightGreen : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.darkGreenPrimary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: theme,
                groupValue: _selectedTheme,
                onChanged: (value) => _changeTheme(value!),
                activeColor: AppColors.darkGreenPrimary,
              ),
              const SizedBox(width: 8),
              Icon(icon, color: AppColors.mediumGreen, size: 20),
              const SizedBox(width: 12),
              Text(
                theme,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.darkGreenPrimary : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkGreenPrimary,
      title: const Text(
        'Settings',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.darkGreenPrimary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGreenPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: AppColors.veryLightGreen,
            highlightColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.veryLightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: AppColors.mediumGreen, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreenPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedGreenText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.mediumGreen, size: 22),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: AppColors.mediumGreen.withOpacity(0.2),
              height: 1,
              thickness: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.veryLightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.mediumGreen, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreenPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedGreenText,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppColors.darkGreenPrimary,
                  inactiveThumbColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: AppColors.mediumGreen.withOpacity(0.2),
              height: 1,
              thickness: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFC8E6C9),
            Color(0xFFE8F5E9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreenPrimary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.darkGreenPrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: _buildCustomAppBar(context),
        backgroundColor: AppColors.softGreenBackground,
        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.darkGreenPrimary),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === APP SETTINGS SECTION ===
              _buildSectionHeader('App Settings'),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'Change app language',
                    onTap: _showLanguageDialog,
                  ),
                  _buildToggleItem(
                    icon: Icons.notifications_active,
                    title: 'Notifications',
                    subtitle: 'Receive app notifications',
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                  _buildSettingsItem(
                    icon: Icons.palette,
                    title: 'Theme',
                    subtitle: '$_selectedTheme mode',
                    onTap: _showThemeDialog,
                    isLast: true,
                  ),
                ],
              ),

              // === ACCOUNT SECTION ===
              _buildSectionHeader('Account'),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Change password coming soon!'),
                          backgroundColor: AppColors.darkGreenPrimary,
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out from your account',
                    onTap: () => _showLogoutDialog(),
                  ),
                  _buildSettingsItem(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: () => _showDeleteAccountDialog(),
                    isLast: true,
                  ),
                ],
              ),

              // === ABOUT SECTION ===
              _buildSectionHeader('About'),
              _buildSectionContainer(
                children: [
                  _buildSettingsItem(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: 'v1.0.0',
                    onTap: () {},
                  ),
                  _buildSettingsItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Read our terms',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms & Conditions'),
                          backgroundColor: AppColors.darkGreenPrimary,
                        ),
                      );
                    },
                  ),
                  _buildSettingsItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy Policy'),
                          backgroundColor: AppColors.darkGreenPrimary,
                        ),
                      );
                    },
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.darkGreenPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mediumGreen)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.darkGreenPrimary,
                ),
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppColors.darkGreenPrimary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mediumGreen)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}