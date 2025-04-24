import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final String size;
  final String color;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.size,
    required this.color,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: double.parse(json['price'].toString()),
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'image': image,
        'price': price,
        'size': size,
        'color': color,
        'quantity': quantity,
      };
}

class CartService with ChangeNotifier {
  List<CartItem> _items = [];
  double _totalPrice = 0.0;
  String? _guestId;
  String? get guestId => _guestId;

  List<CartItem> get items => _items;
  double get totalPrice => _totalPrice;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  final String _baseUrl = 'https://infinite-clothing.onrender.com/api/cart';

  Future<void> fetchCart(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        if (authService.isAuthenticated) 'userId': authService.user!.id,
        if (!authService.isAuthenticated && _guestId != null)
          'guestId': _guestId!,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (authService.isAuthenticated)
            'Authorization': 'Bearer ${authService.user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _items = (data['products'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList();
        _totalPrice = data['totalPrice']?.toDouble() ?? 0.0;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  Future<void> addToCart({
    required BuildContext context,
    required String productId,
    required String name,
    required String image,
    required double price,
    required String size,
    required String color,
    int quantity = 1,
  }) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // If this is the first cart operation, generate a guest ID
      if (!authService.isAuthenticated && _guestId == null) {
        _guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authService.isAuthenticated)
            'Authorization': 'Bearer ${authService.user!.token}',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
          'size': size,
          'color': color,
          'userId': authService.isAuthenticated ? authService.user!.id : null,
          'guestId': _guestId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart(context);
      }
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> updateQuantity({
    required BuildContext context,
    required String productId,
    required String size,
    required String color,
    required int quantity,
  }) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authService.isAuthenticated)
            'Authorization': 'Bearer ${authService.user!.token}',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
          'size': size,
          'color': color,
          'userId': authService.isAuthenticated ? authService.user!.id : null,
          'guestId': _guestId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(context);
      }
    } catch (e) {
      print('Error updating cart: $e');
    }
  }

  Future<void> removeFromCart({
    required BuildContext context,
    required String productId,
    required String size,
    required String color,
  }) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final response = await http.delete(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          if (authService.isAuthenticated)
            'Authorization': 'Bearer ${authService.user!.token}',
        },
        body: jsonEncode({
          'productId': productId,
          'size': size,
          'color': color,
          'userId': authService.isAuthenticated ? authService.user!.id : null,
          'guestId': _guestId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(context);
      }
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  Future<void> mergeCarts({
    required BuildContext context,
    required String guestId,
  }) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final response = await http.post(
        Uri.parse('$_baseUrl/merge'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.user!.token}',
        },
        body: jsonEncode({
          'guestId': guestId,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(context);
        _guestId = null;
      }
    } catch (e) {
      print('Error merging carts: $e');
    }
  }

  void clearCart() {
    _items = [];
    _totalPrice = 0.0;
    notifyListeners();
  }
}
