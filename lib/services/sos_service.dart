import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/report_model.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// Layanan untuk menangani alur SOS sesuai requirements.md.
class SOSService {
  SOSService._internal();
  static final SOSService instance = SOSService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  String? _currentSOSReportId;

  /// Validasi format nomor telepon E.164.
  bool _isValidPhoneNumber(String phone) {
    // Format E.164: +[country code][number], minimal 10 digit setelah +
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(phone.trim());
  }

  /// Mengirim SOS sesuai alur requirements.md.
  Future<void> sendSOS({
    required BuildContext context,
    String? locationText,
  }) async {
    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        throw Exception('User belum login');
      }

      // 1. Ambil kontak darurat dari profil user
      final userDoc = await FirestoreService.instance.userDoc(userId).get();
      if (!userDoc.exists) {
        throw Exception('Profil user tidak ditemukan');
      }

      final userData = userDoc.data()!;
      final contacts = List<String>.from(userData['contacts'] as List? ?? []);

      if (contacts.isEmpty) {
        throw Exception('Tidak ada kontak darurat. Silakan tambahkan di profil.');
      }

      // 2. Validasi format nomor
      final invalidNumbers = <String>[];
      for (final contact in contacts) {
        if (!_isValidPhoneNumber(contact)) {
          invalidNumbers.add(contact);
        }
      }

      if (invalidNumbers.isNotEmpty) {
        throw Exception(
          'Nomor tidak valid: ${invalidNumbers.join(', ')}. '
          'Format harus E.164 (contoh: +6281234567890).',
        );
      }

      // 3. Ambil lokasi GPS (opsional)
      double? lat;
      double? lng;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      } catch (_) {
        // Lokasi tidak wajib, lanjut tanpa koordinat
      }

      // 4. Ambil nama user
      final userName = userData['displayName'] as String? ?? 'Pengguna';

      // 5. Buat report SOS dengan status 'SOS_SENT'
      final report = Report(
        type: 'SOS',
        userId: userId,
        userName: userName,
        description: locationText ?? 'Pengguna menekan tombol SOS.',
        lat: lat,
        lng: lng,
        reportType: 'SOS',
        status: 'SOS_SENT',
        createdAt: DateTime.now(),
      );

      final docRef = await FirestoreService.instance.reports.add(report.toFirestore());
      _currentSOSReportId = docRef.id;

      // 6. Putar sirene lokal (loop)
      await _putarSirene();

      // 7. Panggil Cloud Function sendSOS untuk SMS + FCM
      try {
        await _functions.httpsCallable('sendSOS').call({
          'reportId': docRef.id,
        });
      } catch (e) {
        // Log error tapi jangan gagalkan alur
        debugPrint('Error calling sendSOS function: $e');
      }

      // 8. Tampilkan dialog dengan opsi cancel
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'SOS Dikirim',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'Sinyal darurat sedang diproses.\n'
              'SMS telah dikirim ke kontak darurat Anda.\n'
              'Responder menerima notifikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await cancelSOS(context: ctx);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Batalkan SOS'),
              ),
            ],
          );
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan SOS berhasil dibuat.'),
          ),
        );
      }
    } catch (e) {
      await _hentikanSirene();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim SOS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Membatalkan SOS: stop sirene, update status, kirim STOP_SIREN.
  Future<void> cancelSOS({required BuildContext context}) async {
    try {
      await _hentikanSirene();

      if (_currentSOSReportId != null) {
        // Update status ke 'cancelled'
        await FirestoreService.instance.reportDoc(_currentSOSReportId!).update({
          'status': 'cancelled',
        });

        // Kirim FCM STOP_SIREN via Cloud Function (opsional, bisa langsung dari sini)
        try {
          await _functions.httpsCallable('stopSiren').call({
            'reportId': _currentSOSReportId,
          });
        } catch (_) {
          // Ignore error
        }
      }

      _currentSOSReportId = null;
    } catch (e) {
      debugPrint('Error canceling SOS: $e');
    }
  }

  Future<void> _putarSirene() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sos siren.mp3'), volume: 1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      // Jika gagal memutar audio, biarkan saja tanpa crash
      debugPrint('Gagal memutar sirene (file mungkin belum ada)');
    }
  }

  Future<void> _hentikanSirene() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // abaikan error
    }
  }

  /// Stop sirene (untuk dipanggil dari FCM service saat menerima STOP_SIREN).
  void stopSiren() {
    _hentikanSirene();
  }
}
