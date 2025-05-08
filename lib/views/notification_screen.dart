import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import 'package:infinite_app/views/order_details_screen.dart';

const String BASE_URL = 'https://infinite-clothing.onrender.com';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isAuthenticated) {
        setState(() {
          _isLoading = false;
          _notifications = [];
        });
        return;
      }

      // For demo purposes, we'll create mock data
      // In production, you would fetch this from an API
      await Future.delayed(const Duration(seconds: 1));
      final List<Map<String, dynamic>> mockNotifications = [
        {
          'id': '1',
          'type': 'order_placed',
          'title': 'Order Placed Successfully',
          'message': 'Your order #ORD3892 has been placed successfully.',
          'orderId': 'ORD3892',
          'orderStatus': 'Processing',
          'timestamp': DateTime.now()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
          'isRead': false,
        },
        {
          'id': '2',
          'type': 'order_shipped',
          'title': 'Order Shipped',
          'message': 'Your order #ORD3891 has been shipped and is on its way.',
          'orderId': 'ORD3891',
          'orderStatus': 'Shipped',
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'isRead': true,
        },
        {
          'id': '3',
          'type': 'order_delivered',
          'title': 'Order Delivered',
          'message':
              'Your order #ORD3890 has been delivered. Enjoy your new clothing!',
          'orderId': 'ORD3890',
          'orderStatus': 'Delivered',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'isRead': true,
        },
        {
          'id': '4',
          'type': 'order_out_for_delivery',
          'title': 'Out for Delivery',
          'message': 'Your order #ORD3889 is out for delivery.',
          'orderId': 'ORD3889',
          'orderStatus': 'Out for Delivery',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 1, hours: 5))
              .toIso8601String(),
          'isRead': false,
        },
        {
          'id': '5',
          'type': 'order_cancelled',
          'title': 'Order Cancelled',
          'message': 'Your order #ORD3888 has been cancelled as requested.',
          'orderId': 'ORD3888',
          'orderStatus': 'Cancelled',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'isRead': true,
        },
        {
          'id': '6',
          'type': 'promo',
          'title': 'Limited Time Offer',
          'message': 'Enjoy 25% off on all summer collection items!',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 3))
              .toIso8601String(),
          'isRead': false,
        },
        {
          'id': '7',
          'type': 'order_processing',
          'title': 'Order Processing',
          'message': 'Your order #ORD3887 is being processed.',
          'orderId': 'ORD3887',
          'orderStatus': 'Processing',
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 3, hours: 12))
              .toIso8601String(),
          'isRead': true,
        },
      ];

      setState(() {
        _notifications = mockNotifications;
        _isLoading = false;
      });

      // Real API call would look like this:
      /*
      final response = await http.get(
        Uri.parse('${BASE_URL}/api/notifications'),
        headers: {
          'Authorization': 'Bearer ${authService.user!.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
      */
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    // In production you would call the API
    /*
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      await http.post(
        Uri.parse('${BASE_URL}/api/notifications/$notificationId/read'),
        headers: {
          'Authorization': 'Bearer ${authService.user!.token}',
        },
      );
      
      // Update local state
      setState(() {
        _notifications = _notifications.map((notification) {
          if (notification['id'] == notificationId) {
            return {...notification, 'isRead': true};
          }
          return notification;
        }).toList();
      });
    } catch (e) {
      // Handle error
    }
    */

    // For demo, we'll just update the local state
    setState(() {
      _notifications = _notifications.map((notification) {
        if (notification['id'] == notificationId) {
          return {...notification, 'isRead': true};
        }
        return notification;
      }).toList();
    });
  }

  Future<void> _markAllAsRead() async {
    // In production you would call the API
    /*
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      await http.post(
        Uri.parse('${BASE_URL}/api/notifications/mark-all-read'),
        headers: {
          'Authorization': 'Bearer ${authService.user!.token}',
        },
      );
      
      // Update local state
      setState(() {
        _notifications = _notifications.map((notification) {
          return {...notification, 'isRead': true};
        }).toList();
      });
    } catch (e) {
      // Handle error
    }
    */

    // For demo, we'll just update the local state
    setState(() {
      _notifications = _notifications.map((notification) {
        return {...notification, 'isRead': true};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final isRead = notification['isRead'] ?? false;

    final IconData iconData = _getNotificationIcon(notification['type']);
    final Color statusColor = _getStatusColor(notification['type']);
    final DateTime timestamp = DateTime.parse(notification['timestamp']);
    final String timeAgo = timeago.format(timestamp);

    return InkWell(
      onTap: () {
        // Mark as read
        if (!isRead) {
          _markAsRead(notification['id']);
        }

        // Handle notification tap - for order notifications, navigate to order details
        if (notification['orderId'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsScreen(orderId: notification['orderId']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isRead
              ? theme.cardColor
              : theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    if (notification['orderStatus'] != null) ...[
                      const SizedBox(height: 12),
                      _buildOrderStatusChip(notification['orderStatus']),
                    ],
                    if (!isRead) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusChip(String status) {
    late Color color;
    late IconData icon;

    switch (status.toLowerCase()) {
      case 'processing':
        color = Colors.blue;
        icon = Iconsax.refresh;
        break;
      case 'shipped':
        color = Colors.orange;
        icon = Iconsax.truck;
        break;
      case 'out for delivery':
        color = Colors.purple;
        icon = Iconsax.truck_time;
        break;
      case 'delivered':
        color = Colors.green;
        icon = Iconsax.tick_circle;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Iconsax.close_circle;
        break;
      default:
        color = Colors.grey;
        icon = Iconsax.clipboard_text;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order_placed':
        return Iconsax.shopping_bag;
      case 'order_processing':
        return Iconsax.refresh;
      case 'order_shipped':
        return Iconsax.truck;
      case 'order_out_for_delivery':
        return Iconsax.truck_time;
      case 'order_delivered':
        return Iconsax.tick_circle;
      case 'order_cancelled':
        return Iconsax.close_circle;
      case 'promo':
        return Iconsax.gift;
      default:
        return Iconsax.notification;
    }
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'order_placed':
        return Colors.blue;
      case 'order_processing':
        return Colors.blue;
      case 'order_shipped':
        return Colors.orange;
      case 'order_out_for_delivery':
        return Colors.purple;
      case 'order_delivered':
        return Colors.green;
      case 'order_cancelled':
        return Colors.red;
      case 'promo':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to try again',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when something arrives!',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
