import 'package:flutter/material.dart';
 laudy
import 'features/history/presentation/screens/order_history_screen.dart';

import 'package:galonku_mobile_frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:galonku_mobile_frontend/features/cart/presentation/screens/cart_screen.dart';
import 'package:galonku_mobile_frontend/features/chatbot/presentation/screens/chatbot_screen.dart';
import 'package:galonku_mobile_frontend/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:galonku_mobile_frontend/features/profile/presentation/screens/profile_screen.dart';
> main

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
 laudy
      debugShowCheckedModeBanner: false,
      title: 'GalonKu Mobile',
      theme: ThemeData(
        fontFamily: 'Sans-Serif',
        primarySwatch: Colors.blue,
      ),
      home: const OrderHistoryScreen(),

      title: 'GalonKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0061D5)),
        useMaterial3: true,
      ),
      initialRoute: '/chatbot',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
 main
    );
  }
}