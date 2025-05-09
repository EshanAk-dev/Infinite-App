import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:infinite_app/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, String token) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      token: token,
    );
  }
}

class AuthService with ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool _loading = false;
  bool get loading => _loading;
  String? _error;
  String? get error => _error;

  final String _baseUrl = 'https://infinite-clothing.onrender.com/api';
  static const String _userKey = 'user_data';

  // Method to initialize from shared preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        _user = User(
          id: userMap['id'] ?? '',
          name: userMap['name'] ?? '',
          email: userMap['email'] ?? '',
          role: userMap['role'] ?? 'customer',
          token: userMap['token'] ?? '',
        );

        // Verify token is still valid by fetching profile
        await fetchUserProfile();
        notifyListeners();
      } catch (e) {
        print('Error loading user data: $e');
        await _clearSavedUser();
      }
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      _loading = false;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user'], data['token']);
        _user = user;
        await _saveUserToPrefs(user);
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loading = false;
      _error = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required BuildContext context,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _loading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user'], data['token']);
        _user = user;
        await _saveUserToPrefs(user);
        notifyListeners();

        // Merge guest cart with user cart if guest cart exists
        final cartService = Provider.of<CartService>(context, listen: false);
        if (cartService.guestId != null) {
          await cartService.mergeCarts(
            context: context,
            guestId: cartService.guestId!,
          );
        }

        return true;
      } else {
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
          _error = data['message'] ?? 'Login failed';
        } catch (e) {
          _error = 'Login failed. Please try again.';
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loading = false;
      _error = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _userKey,
        jsonEncode({
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'role': user.role,
          'token': user.token,
        }));
  }

  Future<void> _clearSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  void logout(BuildContext context) async {
    _user = null;
    await _clearSavedUser();
    notifyListeners();

    // Clear the cart when logging out
    final cartService = Provider.of<CartService>(context, listen: false);
    cartService.clearCart();
  }

  Future<void> fetchUserProfile() async {
    if (_user == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User(
          id: data['_id'] ?? _user!.id,
          name: data['name'] ?? _user!.name,
          email: data['email'] ?? _user!.email,
          role: data['role'] ?? _user!.role,
          token: _user!.token,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  bool get isAuthenticated => _user != null;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    if (_user == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/my-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    if (_user == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<int> fetchUnreadNotificationsCount() async {
    if (_user == null) return 0;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/unread'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching unread notifications count: $e');
      return 0;
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    if (_user == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    if (_user == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/notifications/mark-all-read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
}
