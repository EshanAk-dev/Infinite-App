import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_app/views/checkout_screen.dart';
import 'package:infinite_app/views/register_screen.dart';
import 'package:infinite_app/views/splash_screen.dart';
import 'package:infinite_app/views/login_screen.dart';
import 'package:infinite_app/views/app_main_screen.dart';
import 'package:infinite_app/services/auth_service.dart';
import 'package:infinite_app/services/cart_service.dart';
import 'package:provider/provider.dart';

void main() {
  // Lock orientation to portrait mode only
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AuthService()),
          ChangeNotifierProvider(create: (context) => CartService()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const AppMainScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
    );
  }
}
