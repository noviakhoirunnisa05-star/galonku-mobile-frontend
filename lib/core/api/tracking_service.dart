import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class TrackingService {
  static Future?> getOrderTracking(String orderId) async {
    final String? token = await ApiConfig.getToken();
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/tracking'),
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic>
          ? (decoded['data'] ?? decoded)
          : null;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }
    return null;
  }

  static Future<void> updateInstruction(
    String orderId,
    String instruction,
  ) async {
    final String? token = await ApiConfig.getToken();
    await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/instruction'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'instruction': instruction}),
    );
  }
}