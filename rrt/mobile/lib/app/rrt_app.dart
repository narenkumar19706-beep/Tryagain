import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../features/home/screens/sos_home_screen.dart';
import 'routes.dart';
import 'theme.dart';

class RrtApp extends StatelessWidget {
  const RrtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: buildAppTheme(),
      routes: buildAppRoutes(),
      home: const SosHomeScreen(),
    );
  }
}
