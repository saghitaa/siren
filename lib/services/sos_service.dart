import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/report_model.dart';
import 'database_service.dart';
import 'auth_service.dart';

/// Layanan untuk menangani alur SOS (Versi Offline/SQLite).
class SOSService {
  SOSService._internal();
  static final SOSService instance = SOSService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Variabel untuk menyimpan ID laporan SOS yang sedang aktif (opsional)
  String? _currentSOSReportId;

  /// Mengirim SOS
  Future<void> sendSOS({
    required BuildContext context,
    String? locationText,
  }) async {
    try {
      // 1. Cek User Login
      final user = AuthService.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus Login untuk mengirim SOS!')),
        );
        return;
      }

      // 2. Ambil Lokasi GPS (Opsional)
      double? lat;
      double? lng;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      } catch (_) {
        // Abaikan jika gagal ambil GPS
      }

      // 3. Buat Objek Laporan SOS
      final report = Report(
        type: 'SOS',
        userId: user.id,
        userName: user.displayName,
        description: 'SOS Darurat', // Pastikan ini ada
        lat: lat,
        lng: lng,
        reportType: 'SOS',
        status: 'SOS_SENT',
        createdAt: DateTime.now(),
      );

      // 4. Simpan ke Database SQLite
      final id = await DatabaseService.instance.insertReport(report);
      _currentSOSReportId = id.toString();

      // 5. Tampilkan Dialog Konfirmasi
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFEBEE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.red, width: 2),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text('SOS DIKIRIM!',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Sinyal darurat telah disebarkan ke Responder terdekat.\nTetap tenang, bantuan segera datang.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Matikan suara saat dialog ditutup
                  await stopSiren();
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Tutup', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

    } catch (e) {
      await stopSiren();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal mengirim SOS: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Membatalkan SOS (Opsional).
  Future<void> cancelSOS({required BuildContext context}) async {
    await stopSiren();
    _currentSOSReportId = null;
  }

  // --- LOGIKA AUDIO (PUBLIC) ---
  // Diletakkan DI LUAR fungsi sendSOS, tapi DI DALAM class SOSService

  Future<void> playSiren() async {
    try {
      await _audioPlayer.stop();
      // Pastikan file ada di assets/sounds/sos_siren.mp3
      await _audioPlayer.play(AssetSource('sounds/sos_siren.mp3'));

      // PENTING: Set volume ke 1.0 karena kita mengecilkan volume saat stop
      await _audioPlayer.setVolume(1.0);

      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Ulang terus
    } catch (e) {
      debugPrint("Gagal memutar sirene: $e");
    }
  }

  Future<void> stopSiren() async {
    try {
      // TRIK RESPONSIF:
      // Set volume ke 0 terlebih dahulu agar hening instan sebelum proses stop berjalan
      await _audioPlayer.setVolume(0.0);

      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    } catch (_) {}
  }

} // <--- KURUNG TUTUP CLASS UTAMA (PENTING)