// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import 'package:infinite_app/views/app_home_screen.dart';
import 'package:infinite_app/views/order_screen.dart';
import 'package:infinite_app/views/notification_screen.dart';
import 'package:infinite_app/views/profile_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:infinite_app/services/auth_service.dart';

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
  int _notificationCount = 0;
  bool _isLoading = false;

  final List<Widget> _pages = [
    const AppHomeScreen(),
    const OrderScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCounts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authService = Provider.of<AuthService>(context, listen: true);

    // Update notification count whenever it changes in AuthService
    _notificationCount = authService.unreadNotificationCount;

    // Listen for auth changes
    if (authService.isAuthenticated) {
      _fetchCounts();
    } else {
      setState(() {
        _activeOrdersCount = 0;
        _notificationCount = 0;
      });
    }
  }

  Future<void> _fetchCounts() async {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) {
      setState(() {
        _activeOrdersCount = 0;
        _notificationCount = 0;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _fetchActiveOrdersCount(),
        _fetchNotificationsCount(),
      ]);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

    try {
      final orders = await authService.fetchOrders();

      // Count only Processing, Shipped, and Out for Delivery orders (Active orders)
      int count = orders
          .where((order) =>
              order['status'] == 'Processing' ||
              order['status'] == 'Shipped' ||
              order['status'] == 'Out_for_Delivery')
          .length;

      if (mounted) {
        setState(() {
          _activeOrdersCount = count;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _activeOrdersCount = 0;
        });
      }
    }
  }

  Future<void> _fetchNotificationsCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated) {
      setState(() {
        _notificationCount = 0;
      });
      return;
    }

    try {
      final count = await authService.fetchUnreadNotificationsCount();
      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _notificationCount = 0;
        });
      }
    }
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

    // Update notification count from AuthService
    if (_notificationCount != authService.unreadNotificationCount) {
      _notificationCount = authService.unreadNotificationCount;
    }

    if (authService.hasNewNotification && _selectedIndex != 2) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && authService.hasNewNotification) {
          authService.resetNewNotificationFlag();
        }
      });
    }

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

    // Get auth service to check if this tab has new notifications
    final authService = Provider.of<AuthService>(context);
    final hasNewItem = index == 2 && authService.hasNewNotification;

    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);

        // Reset notification flag when user navigates to notifications tab
        if (index == 2 && authService.hasNewNotification) {
          authService.resetNewNotificationFlag();
        }
      },
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
                  : (hasNewItem
                      ? Colors.black.withOpacity(0.05)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.black
                      : (hasNewItem
                          ? Colors.black
                          : Colors.black.withOpacity(0.6)),
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
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
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
