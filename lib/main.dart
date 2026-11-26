import 'package:flutter/material.dart';

import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/product/presentation/screens/product_list_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart'
    hide CheckoutScreen, DeliveryMethodScreen;

import 'features/checkout/presentation/screens/checkout_screen.dart'
    hide QrisPaymentScreen;
import 'features/delivery/presentation/screens/delivery_method_screen.dart';
import 'features/payment/presentation/screens/qris_payment_screen.dart';

import 'features/order_tracking/presentation/screens/order_tracking_screen.dart';
import 'features/history/presentation/screens/order_history_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/chatbot/presentation/screens/chatbot_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ==========================================
      // APP CONFIGURATION
      // ==========================================
      title: 'GalonKu',
      debugShowCheckedModeBanner: false,

      // ==========================================
      // THEME
      // ==========================================
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0756C9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // ==========================================
      // ROUTING ALUR APLIKASI
      // ==========================================
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/products': (context) => const ProductListScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/delivery': (context) => const DeliveryMethodScreen(),
        '/payment': (context) => const QrisPaymentScreen(),
        '/tracking': (context) => const OrderTrackingScreen(),
        '/history': (context) => const OrderHistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
      },
    );
  }
}