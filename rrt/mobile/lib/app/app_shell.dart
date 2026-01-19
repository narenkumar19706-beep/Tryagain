import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/location_access_screen.dart';
import '../screens/profile_screen.dart';
import '../services/local_storage.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _loading = true;
  bool _locationGranted = false;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _locationGranted = await LocalStorage.isLocationGranted();
    _hasProfile = await LocalStorage.hasProfile();

    if (!mounted) {
      return;
    }
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _boot();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_locationGranted) {
      return LocationAccessScreen(onContinue: _refresh);
    }

    if (!_hasProfile) {
      return ProfileScreen(onContinue: _refresh);
    }

    return const HomeScreen();
  }
}
