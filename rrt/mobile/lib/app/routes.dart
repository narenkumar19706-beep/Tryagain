import 'package:flutter/material.dart';

import '../features/alerts/screens/alerts_screen.dart';
import '../features/auth/screens/volunteer_register_screen.dart';
import '../features/home/screens/sos_home_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class AppRoutes {
  static const String sosHome = '/';
  static const String volunteerRegister = '/auth/volunteer';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
}

Map<String, WidgetBuilder> buildAppRoutes() {
  return {
    AppRoutes.sosHome: (_) => const SosHomeScreen(),
    AppRoutes.volunteerRegister: (_) => const VolunteerRegisterScreen(),
    AppRoutes.alerts: (_) => const AlertsScreen(),
    AppRoutes.profile: (_) => const ProfileScreen(),
  };
}
