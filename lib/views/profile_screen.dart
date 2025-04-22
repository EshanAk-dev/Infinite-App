import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  DateTime? lastBackPressed;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isAuthenticated) return;

    setState(() {
      _isLoading = true;
    });
    try {
      await authService.fetchUserProfile();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to fetch user profile',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: authService.isAuthenticated
            ? _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProfileContent(context, authService, user)
            : _buildGuestContent(context),
      ),
    );
  }

  Future<bool> _handleBackPress() async {
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

  Widget _buildProfileContent(
      BuildContext context, AuthService authService, dynamic user) {
    return RefreshIndicator(
      onRefresh: _fetchUserProfile,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileCard(user, authService),
              _buildAccountSettings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic user, AuthService authService) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(user),
          _buildProfileDetails(user, authService),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.purple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.user, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.role ?? 'member',
                  style: TextStyle(
                    color: Colors.indigo[100],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(dynamic user, AuthService authService) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Iconsax.sms, color: Colors.grey),
            title: Text(user?.email ?? 'user@example.com'),
          ),
          ListTile(
            leading: const Icon(Iconsax.user_octagon, color: Colors.grey),
            title: Text('User ID: ${user?.id ?? 'Unknown'}'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Iconsax.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red[50],
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacementNamed(context, '/main');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Iconsax.password_check, color: Colors.grey),
            title: const Text('Change Password'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.card, color: Colors.grey),
            title: const Text('Payment Methods'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.user, size: 50, color: Colors.indigo),
            ),
            const SizedBox(height: 24),
            const Text(
              'Guest User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to access your profile, orders, and settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login',
                      arguments: {'redirect': 'profile'});
                },
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Don't have an account? Create one"),
            ),
          ],
        ),
      ),
    );
  }
}
