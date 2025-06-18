// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

const String BASE_URL = 'https://infinite-clothing.onrender.com';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse('${BASE_URL}/api/orders/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer ${authService.user!.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _orderDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading order details: $e';
      });
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  void _contactSupport() async {
    // Create order-specific message
    final orderNumber =
        'Order #${_orderDetails!['_id'].substring(_orderDetails!['_id'].length - 8)}';
    final message =
        Uri.encodeComponent('$orderNumber\nHi, I need help with my order.');
    final phone = '94710701158';
    final url = 'https://wa.me/$phone?text=$message';

    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                const Icon(Iconsax.arrow_left, color: Colors.black, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[100]!],
            stops: const [0.0, 1.0],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.warning_2,
                          size: 48,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchOrderDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order status and summary
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Iconsax.box_1,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order #${_orderDetails!['_id'].substring(_orderDetails!['_id'].length - 8)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Placed on ${_formatDate(_orderDetails!['createdAt'])}',
                                              style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                                _orderDetails!['status'])
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        _orderDetails!['status'],
                                        style: TextStyle(
                                          color: _getStatusColor(
                                              _orderDetails!['status']),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 30),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Payment Method',
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _orderDetails!['paymentMethod'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total Amount',
                                          style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\Rs.${_orderDetails!['totalPrice'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Order items
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Iconsax.box_1,
                                        color: Colors.black,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Order Items (${_orderDetails!['orderItems'].length})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ..._orderDetails!['orderItems'].map<Widget>(
                                  (item) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              item['image'],
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      fontSize: 13,
                                                    ),
                                                    children: [
                                                      if (item['size'] != null)
                                                        TextSpan(
                                                            text:
                                                                'Size: ${item['size']}'),
                                                      if (item['size'] !=
                                                              null &&
                                                          item['color'] != null)
                                                        const TextSpan(
                                                            text: ' · '),
                                                      if (item['color'] != null)
                                                        TextSpan(
                                                            text:
                                                                'Color: ${item['color']}'),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Qty: ${item['quantity']}',
                                                      style: TextStyle(
                                                        color: Colors.black
                                                            .withOpacity(0.6),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      '\Rs.${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ).toList(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Shipping information
                          if (_orderDetails?['shippingAddress'] != null)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.03),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Iconsax.truck,
                                          color: Colors.black,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Shipping Information',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoItem(
                                        'Recipient',
                                        '${_orderDetails!['shippingAddress']['firstName']} ${_orderDetails!['shippingAddress']['lastName']}',
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoItem(
                                        'Address',
                                        _orderDetails!['shippingAddress']
                                            ['address'],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoItem(
                                        'City & Postal Code',
                                        '${_orderDetails!['shippingAddress']['city']}, ${_orderDetails!['shippingAddress']['postalCode']}',
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoItem(
                                        'Country',
                                        _orderDetails!['shippingAddress']
                                            ['country'],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoItem(
                                        'Phone',
                                        _orderDetails!['shippingAddress']
                                            ['phone'],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Order Timeline
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Iconsax.timer_1,
                                        color: Colors.black,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Order Timeline',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildTimelineItem(
                                  'Order Placed',
                                  _formatDate(_orderDetails!['createdAt']),
                                  true,
                                  Colors.green,
                                ),
                                _buildTimelineItem(
                                  'Processing',
                                  _orderDetails!['status'] == 'Processing' ||
                                          _orderDetails!['status'] ==
                                              'Shipped' ||
                                          _orderDetails!['status'] ==
                                              'Delivered'
                                      ? 'Order is being processed'
                                      : 'Pending',
                                  _orderDetails!['status'] == 'Processing' ||
                                      _orderDetails!['status'] == 'Shipped' ||
                                      _orderDetails!['status'] == 'Delivered',
                                  Colors.blue,
                                ),
                                _buildTimelineItem(
                                  'Shipped',
                                  _orderDetails!['status'] == 'Shipped' ||
                                          _orderDetails!['status'] ==
                                              'Delivered'
                                      ? 'Your order is on the way'
                                      : 'Pending',
                                  _orderDetails!['status'] == 'Shipped' ||
                                      _orderDetails!['status'] == 'Delivered',
                                  Colors.purple,
                                ),
                                _buildTimelineItem(
                                  'Delivered',
                                  _orderDetails!['status'] == 'Delivered'
                                      ? 'Order has been delivered'
                                      : 'Pending',
                                  _orderDetails!['status'] == 'Delivered',
                                  Colors.green,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Support button
                          GestureDetector(
                            onTap: _contactSupport,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Contact Support',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
      String title, String subtitle, bool isCompleted, Color color,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isCompleted ? Icons.check : Iconsax.timer_1,
                  color: isCompleted ? Colors.white : Colors.grey[500],
                  size: 14,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color.withOpacity(0.3) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isCompleted ? Colors.black : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted
                        ? Colors.black.withOpacity(0.6)
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Out_for_Delivery':
        return Colors.teal;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
