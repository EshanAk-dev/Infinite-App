import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> login({required String email, required String password}) async {
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
        notifyListeners();
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

  void logout() {
    _user = null;
    notifyListeners();
  }

  bool get isAuthenticated => _user != null;
}
