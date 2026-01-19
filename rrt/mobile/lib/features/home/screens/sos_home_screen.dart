import 'package:flutter/material.dart';

import '../../../core/widgets/rrt_nav_bar.dart';
import '../controllers/sos_controller.dart';
import '../widgets/hold_progress_ring.dart';
import '../widgets/sos_button.dart';

class SosHomeScreen extends StatefulWidget {
  const SosHomeScreen({super.key});

  @override
  State<SosHomeScreen> createState() => _SosHomeScreenState();
}

class _SosHomeScreenState extends State<SosHomeScreen> {
  late final SosController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = SosController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendSos() async {
    await _controller.sendSos();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SOS sent to responders.')),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RRT SOS'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HoldProgressRing(isActive: _controller.isSending),
                const SizedBox(height: 32),
                SosButton(
                  isSending: _controller.isSending,
                  onPressed: _sendSos,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: RrtNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
