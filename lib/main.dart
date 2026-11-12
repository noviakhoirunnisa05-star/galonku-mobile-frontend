import 'package:flutter/material.dart';
import 'features/history/presentation/screens/order_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GalonKu Mobile',
      theme: ThemeData(
        fontFamily: 'Sans-Serif',
        primarySwatch: Colors.blue,
      ),
      home: const OrderHistoryScreen(),
    );
  }
}