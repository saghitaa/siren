import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/report_model.dart';
import 'database_service.dart';

/// Layanan untuk menangani alur SOS pada aplikasi mobile.
///
/// Versi ini:
/// - Menyimpan laporan SOS ke SQLite (tabel `laporan`)
/// - Memutar suara sirene lokal
/// - Mencoba membuka WhatsApp ke nomor darurat utama
/// - Jika WhatsApp tidak tersedia, fallback ke panggilan telepon biasa
class SOSService {
  SOSService._internal();
  static final SOSService instance = SOSService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Panggil fungsi ini ketika tombol SOS ditekan di UI.
  ///
  /// [nomorDaruratUtama] sebaiknya dalam format internasional, misal: +6281234567890
  Future<void> kirimSOS({
    required BuildContext context,
    String? lokasiTeks,
    String nomorDaruratUtama = '+6281234567890',
  }) async {
    try {
      // 1. Simpan laporan SOS ke SQLite
      final laporan = Report(
        jenis: 'SOS',
        judul: 'Laporan Keadaan Darurat',
        deskripsi: lokasiTeks ?? 'Pengguna menekan tombol SOS.',
        lokasiTeks: lokasiTeks,
        latitude: null,
        longitude: null,
        dibuatPada: DateTime.now(),
        status: 'baru',
      );

      await DatabaseService.instance.insertReport(laporan);

      // 2. Mulai memutar suara sirene
      await _putarSirene();

      // 3. Tampilkan dialog konfirmasi + opsi batal
      //    Sambil mencoba membuka WhatsApp / telepon di belakang.
      //    (User masih melihat dialog di aplikasi.)
      _bukaKontakDarurat(nomorDaruratUtama);

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
              'Aplikasi juga mencoba menghubungi kontak darurat Anda.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _hentikanSirene();
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('Hentikan Sirene'),
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
          ),
        );
      }
    }
  }

  Future<void> _putarSirene() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('siren.mp3'), volume: 1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      // Jika gagal memutar audio, biarkan saja tanpa crash
    }
  }

  Future<void> _hentikanSirene() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // abaikan error
    }
  }

  Future<void> _bukaKontakDarurat(String nomorDaruratUtama) async {
    final nomorTanpaPlus = nomorDaruratUtama.replaceAll('+', '').trim();

    // Coba buka WhatsApp terlebih dahulu
    final waUri =
        Uri.parse('https://wa.me/$nomorTanpaPlus?text=Darurat%20saya%20butuh%20bantuan');

    try {
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {
      // lanjut ke fallback telepon
    }

    // Fallback ke telepon biasa
    final telUri = Uri.parse('tel:$nomorDaruratUtama');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      }
    } catch (_) {
      // jika gagal juga, tidak ada yang bisa kita lakukan di sisi aplikasi
    }
  }
}


