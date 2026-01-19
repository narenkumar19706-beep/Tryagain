import 'package:flutter/foundation.dart';

import '../models/alert_item.dart';

class AlertsController extends ChangeNotifier {
  final List<AlertItem> _alerts = [];
  List<AlertItem> get alerts => List.unmodifiable(_alerts);

  AlertsController() {
    loadSampleAlerts();
  }

  void loadSampleAlerts() {
    _alerts
      ..clear()
      ..addAll([
        AlertItem(
          id: '1',
          title: 'Weather Warning',
          message: 'Heavy storms expected near your area.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          severity: AlertSeverity.medium,
        ),
        AlertItem(
          id: '2',
          title: 'Urgent SOS',
          message: 'Responder assistance requested downtown.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          severity: AlertSeverity.high,
        ),
      ]);
    notifyListeners();
  }
}
