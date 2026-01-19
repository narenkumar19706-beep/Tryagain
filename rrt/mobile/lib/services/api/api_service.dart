import '../../core/constants/api_routes.dart';
import '../../features/alerts/models/alert_item.dart';
import '../../features/auth/models/volunteer.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _client;

  ApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<List<AlertItem>> fetchAlerts() async {
    final uri = Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.alerts}');
    final response = await _client.getJson(uri);
    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => AlertItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> registerVolunteer(Volunteer volunteer) async {
    final uri = Uri.parse('${ApiRoutes.baseUrl}${ApiRoutes.registerVolunteer}');
    await _client.postJson(uri, volunteer.toJson());
    return true;
  }
}
