import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_address');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('user_phone');
    await prefs.remove('user_address');
  }
}