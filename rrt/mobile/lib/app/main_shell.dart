import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: screens[_tab]),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDEFF3)),
          SizedBox(
            height: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_filled,
                  label: "HOME",
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  icon: Icons.notifications_none_rounded,
                  label: "ALERTS",
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: "PROFILE",
                  selected: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "SECURE  ACCESS   •   PRIVACY  ENSURED",
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
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = Colors.black;
    final inactive = const Color(0xFFB6BCC6);

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        width: 110,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: selected ? active : inactive),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: selected ? active : inactive,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
