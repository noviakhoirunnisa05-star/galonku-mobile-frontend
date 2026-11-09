import 'package:flutter/material.dart';
import 'package:galonku_mobile_frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:galonku_mobile_frontend/features/cart/presentation/screens/cart_screen.dart';
import 'package:galonku_mobile_frontend/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:galonku_mobile_frontend/features/profile/presentation/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GalonKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0061D5)),
        useMaterial3: true,
      ),
      initialRoute: '/cart',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}