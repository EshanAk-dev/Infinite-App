import 'package:flutter/material.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:infinite_app/services/cart_service.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.initialize();

    // If user is authenticated, fetch their cart
    if (authService.isAuthenticated) {
      final cartService = Provider.of<CartService>(context, listen: false);
      await cartService.fetchCart(context);
    }

    // Give some time for the splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 180,
          height: 180,
          child: Image.asset('assets/infinite_logo.png'),
        ),
      ),
    );
  }
}
