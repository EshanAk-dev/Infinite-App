// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/views/app_home_screen.dart';
import 'package:infinite_app/views/order_screen.dart';
import 'package:infinite_app/views/notification_screen.dart';
import 'package:infinite_app/views/profile_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String BASE_URL = 'https://infinite-clothing.onrender.com';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int _selectedIndex = 0;
  DateTime? lastBackPressed;
  int _activeOrdersCount = 0;
  int _notificationCount = 0; // Add notification count
  bool _isLoading = false;

  final List<Widget> _pages = [
    const AppHomeScreen(),
    const OrderScreen(),
    const NotificationScreen(), // Add this screen
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActiveOrdersCount();
      _fetchNotificationsCount(); // Add this method call
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = Provider.of<AuthService>(context, listen: true);
    if (authService.isAuthenticated) {
      _fetchActiveOrdersCount();
      _fetchNotificationsCount(); // Add this method call
    } else {
      setState(() {
        _activeOrdersCount = 0;
        _notificationCount = 0; // Reset notification count
      });
    }
  }

  Future<void> _fetchActiveOrdersCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated) {
      setState(() {
        _activeOrdersCount = 0;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}/api/orders/my-orders'),
        headers: {
          'Authorization': 'Bearer ${authService.user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final orders = jsonDecode(response.body);

        // Count only Processing and Shipped orders (Active orders)
        int count = 0;
        for (var order in orders) {
          if (order['status'] == 'Processing' ||
              order['status'] == 'Shipped' ||
              order['status'] == 'Out for Delivery') {
            count++;
          }
        }

        setState(() {
          _activeOrdersCount = count;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  // Add method to fetch notifications count
  Future<void> _fetchNotificationsCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated) {
      setState(() {
        _notificationCount = 0;
      });
      return;
    }

    // For demonstration purposes, we'll just set a dummy value
    // In a real app, you would fetch this from an API
    setState(() {
      _notificationCount = 3;
    });

    // Actual implementation would be similar to:
    /*
    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}/api/notifications/unread'),
        headers: {
          'Authorization': 'Bearer ${authService.user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notificationCount = data['count'];
        });
      }
    } catch (e) {
      // Handle error
    }
    */
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;
      Fluttertoast.showToast(
        msg: 'Press back again to exit',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 14,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Iconsax.home_24, 'Home'),
                  _buildNavItem(1, Iconsax.box_1, 'Orders', _activeOrdersCount),
                  _buildNavItem(
                      2, Iconsax.notification, 'Alerts', _notificationCount),
                  _buildNavItem(3, Iconsax.profile_circle, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label,
      [int badgeCount = 0]) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.black.withOpacity(0.09)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? Colors.black : Colors.black.withOpacity(0.6),
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
