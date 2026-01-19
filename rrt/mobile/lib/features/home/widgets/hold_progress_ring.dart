import 'package:flutter/material.dart';

class HoldProgressRing extends StatelessWidget {
  final bool isActive;

  const HoldProgressRing({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 64,
          width: 64,
          child: CircularProgressIndicator(
            value: isActive ? null : 0,
            strokeWidth: 6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isActive ? 'Sending SOS...' : 'Hold to send',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
