import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../controllers/alerts_controller.dart';
import '../models/alert_item.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late final AlertsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AlertsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _severityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.alerts.isEmpty) {
            return const Center(child: Text('No alerts available.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = _controller.alerts[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _severityColor(alert.severity),
                    child: const Icon(Icons.warning, color: Colors.white),
                  ),
                  title: Text(alert.title),
                  subtitle: Text(
                    '${alert.message}\n${Formatters.formatShortDate(alert.timestamp)}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
