import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

// import 'sos_service.dart'; // Komentari dulu jika menyebabkan circular dependency

/// Service untuk Notifikasi Lokal (Pengganti FCM).
/// Menggunakan AudioPlayer untuk sirene dan print debug untuk simulasi notifikasi.
class FCMService {
  FCMService._internal();
  static final FCMService instance = FCMService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Token dummy untuk kompatibilitas kode lama
  String? get fcmToken => "dummy_local_token";

  /// Initialize (Simulasi saja).
  Future<void> initializeFCM() async {
    debugPrint('Local Notification Service Initialized');
  }

  /// Simulasi menerima notifikasi laporan baru
  void simulateNewReport(String reportId) {
    debugPrint('NOTIFIKASI: Laporan Baru diterima! ID: $reportId');
    // Di sini nanti bisa trigger local notification popup
  }

  /// Simulasi menerima SOS Alert
  Future<void> simulateSOSAlert(String userName) async {
    debugPrint('NOTIFIKASI DARURAT: SOS dari $userName');
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sos siren.mp3'), volume: 1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      debugPrint('Gagal memutar sirene');
    }
  }

  /// Stop sirene
  void stopSiren() {
    try {
      _audioPlayer.stop();
    } catch (_) {}
  }

  /// Acknowledge report (Simulasi).
  Future<void> acknowledgeReport({
    required String reportId,
    required String responderId,
    required String responderName,
    String? responseMessage,
  }) async {
    debugPrint('Report $reportId acknowledged by $responderName');
    // Update status di database lokal bisa dilakukan di sini lewat DatabaseService
  }
}
