import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app_shell.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FcmService.init();
  runApp(const RrtApp());
}

class RrtApp extends StatelessWidget {
  const RrtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppShell(),
    );
  }
}
