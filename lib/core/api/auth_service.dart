import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  static Future register({
    required String name,
    required String phone,
    required String password,
    required String address,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'phone': phone,
            'password': password,
            'address': address,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {
        'success': true,
        'message': data['message'] ?? 'Registrasi berhasil',
      };
    }

    return {
      'success': false,
      'message': data['message'] ?? 'Registrasi gagal',
    };
  }

  static Future login({
    required String phone,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone': phone,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final userMap = Map.from(data['user'] ?? {});
      await ApiConfig.saveSession(
        token: data['token']?.toString() ?? '',
        user: userMap,
        phone: userMap['phone']?.toString() ?? phone,
        address: userMap['address']?.toString() ?? '',
      );
      return {
        'success': true,
        'message': data['message'] ?? 'Login berhasil',
      };
    }

    return {
      'success': false,
      'message': data['message'] ?? 'Nomor HP atau password salah',
    };
  }
}