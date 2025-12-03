import 'package:flutter/material.dart';

import 'splash.dart';

// Logika inisialisasi (seperti database) telah dipindahkan ke SplashScreen
// untuk mencegah aplikasi macet saat startup.
// Fungsi main() sekarang hanya bertanggung jawab untuk menjalankan aplikasi.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
