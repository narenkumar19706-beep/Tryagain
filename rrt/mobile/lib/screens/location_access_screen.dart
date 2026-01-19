import 'package:flutter/material.dart';

import '../services/local_storage.dart';

class LocationAccessScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const LocationAccessScreen({super.key, required this.onContinue});

  Future<void> _grant(BuildContext context) async {
    await LocalStorage.setLocationGranted(true);
    onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
                'Rapid',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Response Team',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: Color(0xFF9AA0A6),
                ),
              ),
              const SizedBox(height: 54),
              const Text(
                'Grant location access to see\n'
                'alerts in your district and\n'
                'ensure help reaches you\n'
                'quickly.',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                width: width,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: InkWell(
                  onTap: () => _grant(context),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'GET STARTED',
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Colors.white24,
                      ),
                      SizedBox(
                        width: 70,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'SECURE  ACCESS   |   PRIVACY  ENSURED',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.22),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
