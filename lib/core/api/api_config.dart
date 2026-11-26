import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future saveSession({
    required String token,
    required Map user,
    String? phone,
    String? address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user));
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString('user_phone', phone);
    }
    if (address != null && address.isNotEmpty) {
      await prefs.setString('user_address', address);
    }
  }

  static Future getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  static Future getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone') ?? '';
  }

  static Future getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_address') ?? '';
  }

  static Future clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('user_phone');
    await prefs.remove('user_address');
  }
}