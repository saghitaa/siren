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
  
  // Tidak ada Cloud Functions, semua lokal
  
  String? _currentSOSReportId;

  /// Validasi format nomor telepon (Sederhana).
  bool _isValidPhoneNumber(String phone) {
    return phone.length >= 10;
  }

  /// Mengirim SOS (Simulasi Offline).
  Future<void> sendSOS({
    required BuildContext context,
    String? locationText,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) {
        throw Exception('User belum login');
      }

      final contacts = user.contacts;
      if (contacts.isEmpty) {
        throw Exception('Tidak ada kontak darurat. Silakan tambahkan di profil.');
      }

      // Ambil lokasi GPS (opsional)
      double? lat;
      double? lng;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      } catch (_) {
        // Lokasi tidak wajib
      }

      // Buat report SOS
      final report = Report(
        type: 'SOS',
        userId: user.id,
        userName: user.displayName,
        description: locationText ?? 'Pengguna menekan tombol SOS.',
        lat: lat,
        lng: lng,
        reportType: 'SOS',
        status: 'SOS_SENT',
        createdAt: DateTime.now(),
      );

      final id = await DatabaseService.instance.insertReport(report);
      _currentSOSReportId = id.toString();

      // Putar sirene lokal
      await _putarSirene();

      // Simulasi kirim SMS & Notifikasi Responder
      debugPrint('SIMULASI: Mengirim SMS ke ${contacts.join(', ')}');
      debugPrint('SIMULASI: Mengirim Notifikasi ke semua Responder');

      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('SOS Dikirim', style: TextStyle(fontWeight: FontWeight.w600)),
            content: const Text(
              'Sinyal darurat sedang diproses.\n'
              '(Simulasi) SMS terkirim ke kontak darurat.\n'
              '(Simulasi) Responder menerima notifikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await cancelSOS(context: ctx);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Batalkan SOS'),
              ),
            ],
          );
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan SOS berhasil dibuat (Offline).')),
        );
      }
    } catch (e) {
      await _hentikanSirene();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim SOS: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Membatalkan SOS.
  Future<void> cancelSOS({required BuildContext context}) async {
    try {
      await _hentikanSirene();
      _currentSOSReportId = null;
      debugPrint('SOS Dibatalkan');
    } catch (e) {
      debugPrint('Error canceling SOS: $e');
    }
  }

  Future<void> _putarSirene() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sos siren.mp3'), volume: 1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {}
  }

  Future<void> _hentikanSirene() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  void stopSiren() {
    _hentikanSirene();
  }
}
