import 'package:flutter/foundation.dart';

/// Model laporan darurat / umum yang disimpan di SQLite.
@immutable
class Report {
  final int? id;
  final String jenis; // contoh: "SOS", "Banjir", "Kebakaran"
  final String judul;
  final String deskripsi;
  final String? lokasiTeks;
  final double? latitude;
  final double? longitude;
  final DateTime dibuatPada;
  final String status; // contoh: "baru", "dikirim", "selesai"

  const Report({
    this.id,
    required this.jenis,
    required this.judul,
    required this.deskripsi,
    this.lokasiTeks,
    this.latitude,
    this.longitude,
    required this.dibuatPada,
    required this.status,
  });

  Report copyWith({
    int? id,
    String? jenis,
    String? judul,
    String? deskripsi,
    String? lokasiTeks,
    double? latitude,
    double? longitude,
    DateTime? dibuatPada,
    String? status,
  }) {
    return Report(
      id: id ?? this.id,
      jenis: jenis ?? this.jenis,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasiTeks: lokasiTeks ?? this.lokasiTeks,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      status: status ?? this.status,
    );
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as int?,
      jenis: map['jenis'] as String,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String,
      lokasiTeks: map['lokasi_teks'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      dibuatPada:
          DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
      status: map['status'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'jenis': jenis,
      'judul': judul,
      'deskripsi': deskripsi,
      'lokasi_teks': lokasiTeks,
      'latitude': latitude,
      'longitude': longitude,
      'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
      'status': status,
    };
  }
}


