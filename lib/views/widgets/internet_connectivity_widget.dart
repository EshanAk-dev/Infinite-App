// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class InternetConnectivityWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final bool showFullScreen;

  const InternetConnectivityWidget({
    super.key,
    required this.child,
    this.onRetry,
    this.showFullScreen = false,
  });

  @override
  State<InternetConnectivityWidget> createState() =>
      _InternetConnectivityWidgetState();
}

class _InternetConnectivityWidgetState
    extends State<InternetConnectivityWidget> {
  bool _isConnected = true;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 50,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please connect your device to the internet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _checkInternetConnection();
              if (widget.onRetry != null) {
                widget.onRetry!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return widget.showFullScreen
          ? Scaffold(body: _buildNoInternetWidget())
          : _buildNoInternetWidget();
    }
    return widget.child;
  }
}
