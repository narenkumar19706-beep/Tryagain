import 'dart:convert';
import 'dart:io';

class ApiClient {
  final HttpClient _httpClient;

  ApiClient({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();
    final body = await utf8.decodeStream(response);
    if (response.statusCode >= 400) {
      throw HttpException('Request failed: ${response.statusCode}');
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final request = await _httpClient.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close();
    final responseBody = await utf8.decodeStream(response);
    if (response.statusCode >= 400) {
      throw HttpException('Request failed: ${response.statusCode}');
    }
    if (responseBody.isEmpty) {
      return {};
    }
    return jsonDecode(responseBody) as Map<String, dynamic>;
  }
}
