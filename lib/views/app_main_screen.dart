import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/views/app_home_screen.dart';
import 'package:infinite_app/views/search_screen.dart';
import 'package:infinite_app/views/profile_screen.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  final List<Widget> pages = [
    const AppHomeScreen(),
    const SearchScreen(),
    const Scaffold(), // Orders screen
    const Scaffold(body: Center(child: Text('Please log in to view profile'))),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          if (value == 3) {
            // Profile tab
            if (!authService.isAuthenticated) {
              Navigator.pushNamed(context, '/login',
                  arguments: {'redirect': 'profile'});
              return;
            } else {
              // Replace the profile placeholder with actual ProfileScreen
              pages[3] = const ProfileScreen();
            }
          }
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.search_normal),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.box),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}
