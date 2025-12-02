import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'services/database_service.dart';
import 'services/fcm_service.dart';
import 'splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SQLite (untuk cache offline opsional)
  await DatabaseService.instance.init();

  // Initialize FCM
  await FCMService.instance.initializeFCM();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(), 
    );
  }
}
