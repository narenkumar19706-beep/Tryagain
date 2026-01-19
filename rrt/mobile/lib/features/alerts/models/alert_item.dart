enum AlertSeverity { low, medium, high }

class AlertItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AlertSeverity severity;

  const AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
  });

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      timestamp: DateTime.tryParse((json['timestamp'] as String?) ?? '') ??
          DateTime.now(),
      severity: _parseSeverity(json['severity'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
    };
  }

  static AlertSeverity _parseSeverity(String? value) {
    switch (value) {
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      default:
        return AlertSeverity.low;
    }
  }
}
