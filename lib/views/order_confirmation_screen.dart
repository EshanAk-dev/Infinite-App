// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_app/services/auth_service.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

const String BASE_URL = 'https://infinite-clothing.onrender.com';

class OrderConfirmationScreen extends StatefulWidget {
  final String checkoutId;
  final String paymentMethod;
  final double totalAmount;

  const OrderConfirmationScreen({
    Key? key,
    required this.checkoutId,
    required this.paymentMethod,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _OrderConfirmationScreenState createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  Map<String, dynamic>? _checkoutDetails;
  bool _isLoading = true;
  double _subtotal = 0.0;
  double _shippingCost = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCheckoutDetails();
  }

  Future<void> _fetchCheckoutDetails() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.user == null || authService.user!.token.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User is not authenticated. Please log in.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}/api/checkout/${widget.checkoutId}'),
        headers: {
          'Authorization': 'Bearer ${authService.user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _checkoutDetails = data;
          _isLoading = false;

          // Calculate subtotal from checkout items
          _subtotal = 0.0;
          if (data['checkoutItems'] != null) {
            for (var item in data['checkoutItems']) {
              _subtotal += (item['price'] * item['quantity']);
            }
          }

          // Get shipping cost
          _shippingCost = 0.0;

          // Calculate total
          _total = data['totalPrice'] != null
              ? data['totalPrice'].toDouble()
              : _subtotal + _shippingCost;
        });
      } else {
        throw Exception(
            'Failed to load checkout details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading checkout details: $e')),
      );
    }
  }

  String _calculateEstimatedDelivery(String createdAt) {
    final orderDate = DateTime.parse(createdAt).add(const Duration(days: 10));
    return DateFormat('MMMM d, y').format(orderDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Order Confirmation',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success message
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Order Confirmed!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.paymentMethod == 'COD'
                              ? 'Your order has been placed successfully. Please prepare the payment upon delivery.'
                              : 'Thank you for your purchase!',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Order summary
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order Summary',
                                style: theme.textTheme.headlineSmall,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_shipping,
                                        size: 16, color: Colors.green[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Est. Delivery: ${_calculateEstimatedDelivery(_checkoutDetails!['createdAt'])}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.green[700]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_checkoutDetails?['checkoutItems'] != null)
                            ..._checkoutDetails!['checkoutItems']
                                .map<Widget>((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(item['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item['name'],
                                              style:
                                                  theme.textTheme.bodyMedium),
                                          const SizedBox(height: 4),
                                          Text(
                                              '${item['size'] ?? ''} ${item['size'] != null && item['color'] != null ? '·' : ''} ${item['color'] ?? ''}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: theme
                                                          .colorScheme.onSurface
                                                          .withOpacity(0.6))),
                                          const SizedBox(height: 4),
                                          Text('Qty: ${item['quantity']}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: theme
                                                          .colorScheme.onSurface
                                                          .withOpacity(0.6))),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\Rs.${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          const Divider(height: 32),
                          _buildOrderTotalRow('Subtotal', _subtotal, theme),
                          const SizedBox(height: 8),
                          _buildOrderTotalRow('Shipping', _shippingCost, theme),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildOrderTotalRow('Total', _total, theme,
                              isTotal: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment and Shipping info
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Details',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Payment Information (Left side)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Information',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Method: ${widget.paymentMethod}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Status: ${_checkoutDetails?['paymentStatus'] ?? (widget.paymentMethod == 'COD' ? 'Pending COD' : 'Paid')}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Total: \Rs.${_total.toStringAsFixed(2)}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),

                              // Vertical divider
                              Container(
                                height: 150,
                                width: 1,
                                color: Colors.grey.withOpacity(0.3),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),

                              // Shipping Information (Right side)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Shipping Information',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (_checkoutDetails?['shippingAddress'] !=
                                        null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_checkoutDetails!['shippingAddress']['firstName']} ${_checkoutDetails!['shippingAddress']['lastName']}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            _checkoutDetails!['shippingAddress']
                                                ['address'],
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            '${_checkoutDetails!['shippingAddress']['city']}, ${_checkoutDetails!['shippingAddress']['postalCode']}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            _checkoutDetails!['shippingAddress']
                                                ['country'],
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          Text(
                                            'Phone: ${_checkoutDetails!['shippingAddress']['phone']}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.black, width: 2),
                            foregroundColor: Colors.black,
                            elevation: 0,
                          ),
                          child: Text(
                            'Continue Shopping',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to order history
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'View Order History',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderTotalRow(String label, double amount, ThemeData theme,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal
                ? theme.textTheme.bodyLarge
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
        Text('\Rs.${amount.toStringAsFixed(2)}',
            style: isTotal
                ? theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }
}
