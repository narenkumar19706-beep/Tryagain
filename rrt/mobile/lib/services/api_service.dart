import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  static Future<void> register({
    required String name,
    required String phoneNumber,
    required String district,
    required String fcmToken,
  }) async {
    final uri = Uri.parse('$baseUrl/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phoneNumber': phoneNumber,
        'district': district,
        'fcmToken': fcmToken,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Register failed: ${response.body}');
    }
  }

  static Future<void> sosStart({
    required String phoneNumber,
    required String district,
    required double lat,
    required double lng,
    String comment = '',
  }) async {
    final uri = Uri.parse('$baseUrl/sos/start');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneNumber,
        'district': district,
        'lat': lat,
        'lng': lng,
        'comment': comment,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('SOS start failed: ${response.body}');
    }
  }
}
