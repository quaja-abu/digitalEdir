import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:digitaledir/presentation/screens/discovery_screen.dart';
import 'package:digitaledir/presentation/screens/contributions_screen.dart';
import 'package:digitaledir/presentation/screens/profile_screen.dart';
import 'package:digitaledir/presentation/screens/notifications_screen.dart';
import 'package:digitaledir/core/theme/app_theme.dart';
import 'package:digitaledir/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:digitaledir/core/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  late List<String> _appBarTitles;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;

    if (isAdmin) {
      // Admin navigation
      _screens = [
        const DiscoveryScreen(),
        const ContributionsScreen(),
        const AdminDashboardScreen(), // Admin dashboard as third tab
        const ProfileScreen(),
      ];

      _appBarTitles = [
        'Discover Edir',
        'My Contributions',
        'Admin Dashboard',
        'Profile',
      ];

      _navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Discover',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.payments_outlined),
          activeIcon: Icon(Icons.payments),
          label: 'Contributions',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // Regular user navigation
      _screens = [
        const DiscoveryScreen(),
        const ContributionsScreen(),
        const ProfileScreen(),
      ];

      _appBarTitles = [
        'Discover Edir',
        'My Contributions',
        'Profile',
      ];

      _navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Discover',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.payments_outlined),
          activeIcon: Icon(Icons.payments),
          label: 'Contributions',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.greyColor,
        type: BottomNavigationBarType.fixed,
        items: _navItems,
      ),
    );
  }
}
