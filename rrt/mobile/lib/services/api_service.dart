import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080/api";

  static Future<void> register({
    required String name,
    required String phoneNumber,
    required String district,
    required String fcmToken,
    required String address,
  }) async {
    final uri = Uri.parse("$baseUrl/register");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "phoneNumber": phoneNumber,
        "district": district,
        "fcmToken": fcmToken,
        "address": address,
      }),
    );

    if (res.statusCode >= 400) {
      throw Exception("Register failed: ${res.body}");
    }
  }

  static Future<Map<String, dynamic>> sosStart({
    required String phoneNumber,
    required String district,
    required String name,
    required String address,
    required double lat,
    required double lng,
    String comment = "",
  }) async {
    final uri = Uri.parse("$baseUrl/sos/start");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phoneNumber": phoneNumber,
        "district": district,
        "name": name,
        "address": address,
        "lat": lat,
        "lng": lng,
        "comment": comment,
      }),
    );

    if (res.statusCode >= 400) {
      throw Exception("SOS start failed: ${res.body}");
    }

    return jsonDecode(res.body);
  }

  static Future<void> sosStop({
    required String sosId,
    required String district,
  }) async {
    final uri = Uri.parse("$baseUrl/sos/stop");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sosId": sosId,
        "district": district,
      }),
    );

    if (res.statusCode >= 400) {
      throw Exception("SOS stop failed: ${res.body}");
    }
  }

  static Future<void> sosUpdate({
    required String sosId,
    required String district,
    required String message,
  }) async {
    final uri = Uri.parse("$baseUrl/sos/update");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sosId": sosId,
        "district": district,
        "message": message,
      }),
    );

    if (res.statusCode >= 400) {
      throw Exception("SOS update failed: ${res.body}");
    }
  }
}
