// custom_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:vrikshanova/navigation/side_nav_drawer/profile_screen.dart'; // Profile Screen import

//  BOTTOM NAVIGATION WITH NAVIGATION
class CustomNavscreen extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;
  final BuildContext screenContext;

  const CustomNavscreen({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.screenContext,
  });

  void _navigateTo(int index) {
    onItemSelected(index);

    switch (index) {
      case 0:
      // Home Screen पर navigate करें
        Navigator.pushNamed(screenContext, '/home');
        break;
      case 1:
      // DiseaseCheck Screen पर navigate करें
        Navigator.pushNamed(screenContext, '/disease');
        break;
      case 2:
      // Analysis Screen पर navigate करें
      //   Navigator.pushNamed(screenContext, '/analysis');
      //   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _navigateTo,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.coronavirus),
          label: 'Disease',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.analytics_outlined),
        //   label: 'Analysis',
        // ),
      ],
    );
  }
}


//  SIDE NAVIGATION DRAWER WITH NAVIGATION
class CustomSideDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const CustomSideDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  void _navigateTo(BuildContext context, int index) {
    onItemSelected(index);
    Navigator.pop(context);

    switch (index) {
      case 0:
      // Profile - Using Navigator.push instead of pushNamed
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
      case 1:
      // Control
        Navigator.of(context).pushNamed('/control');
        break;
      case 2:
      // Search
        Navigator.of(context).pushNamed('/search');
        break;



    }
  }

  void _navigateToExtra(BuildContext context, String route) {
    Navigator.pop(context);

    switch (route) {
      case 'profile':
        Navigator.pushNamed(context, '/profile');
        break;

      case 'control':
        Navigator.pushNamed(context, '/control');
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'help':
        Navigator.pushNamed(context, '/help');
        break;
      // case 'video':
      //   Navigator.pushNamed(context, '/video');
      //   break;
    }
  }

  //  Custom ListTile without hover effect
  Widget _buildCustomListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2d6a4f)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1e5128),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2d6a4f),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFF1e5128),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'वृक्षनोवा',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'user@vrikshanova.com',
                  style: TextStyle(
                    color: Color(0xFFa8d5ba),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // //  Menu Items with Custom ListTile (No Hover)
          // _buildCustomListTile(
          //   icon: Icons.person,
          //   title: 'Profile','
          //   isSelected: currentIndex == 0,
          //   // onTap: () => _navigateTo(context, 0),
          //   onTap: () => null,
          // ),
          _buildCustomListTile(
            icon: Icons.gamepad_outlined,
            title: 'Control',
            isSelected: currentIndex == 1,
            onTap: () => _navigateTo(context, 1),
            // onTap: () => null
          ),
          const Divider(color: Color(0xFF558b5f), height: 20),

          //  Additional Items with Custom ListTile (No Hover)
         //  _buildCustomListTile(
         //    icon: Icons.settings,
         //    title: 'Settings',
         //    isSelected: false,
         // //   onTap: () => _navigateToExtra(context, 'settings'),
         //    onTap: () => null
         //  ),
          _buildCustomListTile(
            icon: Icons.help,
            title: 'Help & Support',
            isSelected: false,
            onTap: () => _navigateToExtra(context, 'help'),
            // onTap: () => null
          ),
        ],
      ),
    );
  }
}