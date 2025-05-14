// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:infinite_app/views/order_details_screen.dart';
import 'package:infinite_app/views/widgets/whatsapp_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';

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

      final notifications = await authService.fetchNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.markNotificationAsRead(notificationId);

    if (success) {
      setState(() {
        _notifications = _notifications.map((notification) {
          if (notification['_id'] == notificationId) {
            return {...notification, 'isRead': true};
          }
          return notification;
        }).toList();
      });
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.deleteNotification(notificationId);

    if (success) {
      setState(() {
        _notifications = _notifications
            .where((notification) => notification['_id'] != notificationId)
            .toList();
      });

      // Show success toast
      _showToast('Notification deleted');
    } else {
      // Show error toast
      _showToast('Failed to delete notification', isError: true);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.markAllNotificationsAsRead();

    if (success) {
      setState(() {
        _notifications = _notifications.map((notification) {
          return {...notification, 'isRead': true};
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onBackground,
          ),
        ),
        titleSpacing: 30,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Row(
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Mark all read',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchNotifications,
            color: Colors.black,
            child: _buildBody(),
          ),
          const WhatsAppButton(),
        ],
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

    // Safely access fields with default values
    final String title = notification['title'] ?? 'No Title';
    final String message = notification['message'] ?? 'No Message';
    final String type = notification['type'] ?? 'unknown';
    final bool isRead = notification['isRead'] ?? false;
    final String notificationId = notification['_id'] ?? '';

    // Parse timestamp safely - handle both String and DateTime formats
    DateTime timestamp;
    try {
      if (notification['createdAt'] is String) {
        timestamp = DateTime.parse(notification['createdAt']);
      } else if (notification['createdAt'] is int) {
        timestamp =
            DateTime.fromMillisecondsSinceEpoch(notification['createdAt']);
      } else {
        timestamp = DateTime.now(); // Fallback to current time
      }
    } catch (e) {
      timestamp = DateTime.now(); // Fallback to current time if parsing fails
    }

    // Format the timestamp to a human-readable string
    String _formatTimeAgo(DateTime date) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    }

    // Format the time ago string
    final String timeAgo = _formatTimeAgo(timestamp);

    final IconData iconData = _getNotificationIcon(type);
    final Color statusColor = _getStatusColor(type);

    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: Icon(
          Iconsax.trash,
          color: Colors.red.shade400,
          size: 26,
        ),
      ),
      confirmDismiss: (direction) async {
        return true; // Could add confirmation dialog here if needed
      },
      onDismissed: (direction) {
        _deleteNotification(notificationId);
      },
      child: GestureDetector(
        onTap: () {
          // Mark as read
          if (!isRead) {
            _markAsRead(notificationId);
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
        onLongPress: () {
          Fluttertoast.showToast(
            msg: "Slide notification to delete",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
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
                              title,
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
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
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
        color = Colors.purple;
        icon = Iconsax.truck;
        break;
      case 'out_for_delivery':
        color = Colors.teal;
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
        return Colors.purple;
      case 'order_out_for_delivery':
        return Colors.teal;
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
