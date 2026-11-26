import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ProductService {
  static Future<bool> checkServerStatus() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/products'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  static Future<List> getProducts() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/products'))
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final listData = decoded is List ? decoded : (decoded['data'] ?? []);
      return listData;
    }
    return [];
  }

  static Future<void> syncCart(Map cartPayload) async {
    final String? token = await ApiConfig.getToken();
    await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/cart'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode(cartPayload),
        )
        .timeout(const Duration(seconds: 3));
  }
}