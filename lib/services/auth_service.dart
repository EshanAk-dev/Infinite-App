import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:infinite_app/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  // New properties for notification tracking
  int _unreadNotificationCount = 0;
  int get unreadNotificationCount => _unreadNotificationCount;

  // List to store notifications locally
  List<Map<String, dynamic>> _notifications = [];

  // Stream controller to broadcast notification events
  bool _hasNewNotification = false;
  bool get hasNewNotification => _hasNewNotification;

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

        // Initialize WebSocket connection
        await _initWebSocket();

        // Fetch unread notification count
        await fetchUnreadNotificationsCount();

        notifyListeners();
      } catch (e) {
        print('Error loading user data: $e');
        await _clearSavedUser();
      }
    }
  }

  WebSocketChannel? _socketChannel;

  Future<void> _initWebSocket() async {
    if (_user == null) return;

    try {
      // Close existing connection if any
      await _closeWebSocket();

      // Create new connection
      final wsUrl = _baseUrl
              .replaceFirst('https://', 'wss://')
              .replaceFirst('http://', 'ws://') +
          '/ws';
      _socketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Add auth token after connection
      _socketChannel!.sink.add(jsonEncode({
        'type': 'auth',
        'token': _user!.token,
      }));

      // Listen for messages
      _socketChannel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'notification') {
            // Process the notification data
            _processNotification(data['data']);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          // Attempt to reconnect after delay
          Future.delayed(Duration(seconds: 5), _initWebSocket);
        },
        onDone: () {
          print('WebSocket closed');
          // Attempt to reconnect
          Future.delayed(Duration(seconds: 5), _initWebSocket);
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }

  Future<void> _closeWebSocket() async {
    await _socketChannel?.sink.close();
    _socketChannel = null;
  }

  // Call after successful login
  Future<void> _afterLogin() async {
    await _initWebSocket();
    await fetchUnreadNotificationsCount();
  }

  // Call on logout
  void _onLogout() {
    _closeWebSocket();
    _unreadNotificationCount = 0;
    _hasNewNotification = false;
    _notifications = [];
  }

  void _processNotification(Map<String, dynamic> notificationData) {
    // Handle different notification types
    switch (notificationData['type']) {
      case 'order_update':
        // Order status update notification
        _hasNewNotification = true;
        _unreadNotificationCount++;
        notifyListeners();
        break;
      case 'notification_read':
        // Single notification marked as read
        if (_unreadNotificationCount > 0) {
          _unreadNotificationCount--;
        }
        notifyListeners();
        break;
      case 'all_notifications_read':
        // All notifications marked as read
        _unreadNotificationCount = 0;
        notifyListeners();
        break;
      case 'notification_deleted':
        // Remove from local list if present
        _notifications
            .removeWhere((n) => n['_id'] == notificationData['notificationId']);
        notifyListeners();
        break;
      // More notification types
      case 'new_product':
      case 'promo':
      case 'system':
        _hasNewNotification = true;
        _unreadNotificationCount++;
        notifyListeners();
        break;
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
        await _afterLogin();

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
    _onLogout();
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
        _notifications = List<Map<String, dynamic>>.from(data);
        return _notifications;
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
        _unreadNotificationCount = data['count'] ?? 0;
        notifyListeners();
        return _unreadNotificationCount;
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

      if (response.statusCode == 200) {
        // Decrement notification count locally for immediate UI update
        if (_unreadNotificationCount > 0) {
          _unreadNotificationCount--;
          notifyListeners();
        }
        return true;
      }
      return false;
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

      if (response.statusCode == 200) {
        // Reset notification count locally for immediate UI update
        _unreadNotificationCount = 0;
        _hasNewNotification = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    if (_user == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_user!.token}',
        },
      );

      if (response.statusCode == 200) {
        // Check if the notification was unread before deleting
        final wasUnread = _notifications.any((notification) =>
            notification['_id'] == notificationId &&
            !(notification['isRead'] ?? false));

        // Update unread count if needed
        if (wasUnread && _unreadNotificationCount > 0) {
          _unreadNotificationCount--;
        }

        // Remove from local list
        _notifications.removeWhere(
            (notification) => notification['_id'] == notificationId);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Method to reset the new notification flag
  void resetNewNotificationFlag() {
    _hasNewNotification = false;
    notifyListeners();
  }
}
