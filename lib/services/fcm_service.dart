import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'firestore_service.dart';
import 'auth_service.dart';
import 'sos_service.dart';

/// Service untuk FCM (Firebase Cloud Messaging) notifications.
class FCMService {
  FCMService._internal();
  static final FCMService instance = FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _fcmToken;

  /// Initialize FCM dan register token.
  Future<void> initializeFCM() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('FCM permission denied');
      return;
    }

    // Get token
    _fcmToken = await _messaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Simpan token ke Firestore (untuk responder)
    final userId = AuthService.instance.currentUserId;
    if (userId != null && _fcmToken != null) {
      // Cek apakah user adalah responder
      final userDoc = await FirestoreService.instance.userDoc(userId).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'] as String?;
        if (role == 'responder') {
          // Update atau create responder doc dengan fcmToken
          final responders = await FirestoreService.instance.responders
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

          if (responders.docs.isNotEmpty) {
            await responders.docs.first.reference.update({
              'fcmToken': _fcmToken,
            });
          }
        }
      }
    }

    // Setup foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Setup background message handler (harus top-level function)
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  /// Handle pesan FCM saat app di foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    debugPrint('FCM Foreground: $type');

    switch (type) {
      case 'NEW_REPORT':
        _handleNewReport(data);
        break;
      case 'SOS_ALERT':
        _handleSOSAlert(data);
        break;
      case 'SOS_ACK':
        _handleSOSAck(data);
        break;
      case 'STOP_SIREN':
        _handleStopSiren(data);
        break;
      default:
        debugPrint('Unknown FCM type: $type');
    }
  }

  void _handleNewReport(Map<String, dynamic> data) {
    // Tampilkan notifikasi lokal untuk laporan baru
    // (bisa ditambahkan flutter_local_notifications jika perlu)
    debugPrint('NEW_REPORT: ${data['reportId']}');
  }

  void _handleSOSAlert(Map<String, dynamic> data) async {
    final reportId = data['reportId'] as String?;
    final userName = data['userName'] as String? ?? 'Pengguna';

    debugPrint('SOS_ALERT: $reportId from $userName');

    // Putar sirene lokal
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sos siren.mp3'), volume: 1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      debugPrint('Gagal memutar sirene');
    }

    // Tampilkan popup/alert dengan opsi Acknowledge/Ignore
    // Note: Perlu context, jadi akan dipanggil dari UI layer
    // Untuk sekarang, simpan state bahwa ada SOS alert
  }

  void _handleSOSAck(Map<String, dynamic> data) {
    final reportId = data['reportId'] as String?;
    final responderName = data['responderName'] as String?;

    debugPrint('SOS_ACK: $reportId oleh $responderName');

    // Stop sirene reporter
    SOSService.instance.stopSiren();

    // Tampilkan modal/toast dengan pesan:
    // "LAPORAN ANDA DITERIMA. RESPONDER MENUJU LOKASI"
    // (Akan di-handle di UI layer dengan listener)
  }

  void _handleStopSiren(Map<String, dynamic> data) {
    final reportId = data['reportId'] as String?;
    debugPrint('STOP_SIREN: $reportId');

    // Stop sirene
    try {
      _audioPlayer.stop();
    } catch (_) {
      // Ignore
    }
    SOSService.instance.stopSiren();
  }

  /// Acknowledge report (dipanggil dari responder dashboard).
  Future<void> acknowledgeReport({
    required String reportId,
    required String responderId,
    required String responderName,
    String? responseMessage,
  }) async {
    try {
      await _functions.httpsCallable('acknowledgeReport').call({
        'reportId': reportId,
        'responderId': responderId,
        'responderName': responderName,
        'responseMessage': responseMessage,
      });
    } catch (e) {
      throw Exception('Gagal acknowledge report: $e');
    }
  }

  String? get fcmToken => _fcmToken;
}

/// Top-level function untuk background message handler (wajib top-level).
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  debugPrint('FCM Background: ${message.data}');
  // Background handler - bisa stop sirene atau update UI jika perlu
}

