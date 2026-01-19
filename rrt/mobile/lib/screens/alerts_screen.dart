import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/alert_store.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final alerts = AlertStore.alerts;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12, width: 1),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Icon(Icons.pets, size: 22, color: Colors.black),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                "Rapid",
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Response Team",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: Color(0xFF9AA0A6),
                ),
              ),
              const SizedBox(height: 42),
              const Text(
                "Nearby situations",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 18),
              if (alerts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No alerts yet.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB6BCC6),
                    ),
                  ),
                )
              else
                _AlertCard(alert: alerts.first),
              const SizedBox(height: 18),
              const Text(
                "CONTACT DETAILS ARE VISIBLE ONLY WHILE THIS\nALERT IS ACTIVE.",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.0,
                  height: 1.6,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB6BCC6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final SosAlert alert;
  const _AlertCard({required this.alert});

  String _timeAgo(DateTime startedAt) {
    final mins = DateTime.now().difference(startedAt).inMinutes;
    if (mins <= 0) return "Started just now";
    return "Started $mins mins ago";
  }

  Future<void> _call() async {
    final uri = Uri.parse("tel:${alert.phoneNumber}");
    await launchUrl(uri);
  }

  Future<void> _directions() async {
    if (alert.lat == null || alert.lng == null) return;

    final url =
        "https://www.google.com/maps/dir/?api=1&destination=${alert.lat},${alert.lng}";
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final distanceText = "4kms away";
    final timeText = _timeAgo(alert.startedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E6EA), width: 1.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: alert.active ? const Color(0xFFE11B22) : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  alert.active ? "ACTIVE" : "CLOSED",
                  style: const TextStyle(
                    fontSize: 14,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "$distanceText  •  $timeText",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB6BCC6),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 18),
          Text(
            "Raised by: ${alert.raisedByName}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Location: ${alert.address}",
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8C939E),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _BlackButton(
                  label: "CALL",
                  icon: Icons.call,
                  onTap: alert.active ? _call : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BlackButton(
                  label: "GET DIRECTIONS",
                  icon: Icons.navigation,
                  onTap: (alert.active && alert.lat != null && alert.lng != null)
                      ? _directions
                      : null,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _BlackButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _BlackButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.black),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w900,
                  color: onTap == null
                      ? Colors.white.withOpacity(0.55)
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
