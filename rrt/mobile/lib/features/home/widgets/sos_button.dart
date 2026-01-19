import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onPressed;

  const SosButton({
    super.key,
    required this.isSending,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: ElevatedButton(
        onPressed: isSending ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
        ),
        child: isSending
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Text(
                'SOS',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
