import 'package:flutter/foundation.dart';

/// Model laporan darurat / umum yang disimpan di SQLite.
@immutable
class Report {
  final String? id;
  final String type; // 'regular' | 'SOS'
  final String userId;
  final String userName;
  final String description;
  final double? lat;
  final double? lng;
  final String? reportType; // kategori/jenis laporan
  final String status; // 'Belum ditanggapi' | 'Proses' | 'Sudah ditanggapi' | 'SOS_SENT' | 'cancelled' | 'Menanggapi'
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? responderId;
  final String? responderName;
  final String? responseMessage;

  const Report({
    this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.description,
    this.lat,
    this.lng,
    this.reportType,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.responderId,
    this.responderName,
    this.responseMessage,
  });

  String get jenis => reportType ?? 'Tidak diketahui';

  Report copyWith({
    String? id,
    String? type,
    String? userId,
    String? userName,
    String? description,
    double? lat,
    double? lng,
    String? reportType,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? responderId,
    String? responderName,
    String? responseMessage,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      description: description ?? this.description,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      reportType: reportType ?? this.reportType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      responderId: responderId ?? this.responderId,
      responderName: responderName ?? this.responderName,
      responseMessage: responseMessage ?? this.responseMessage,
    );
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'].toString(),
      // Mapping kolom legacy 'jenis' ke logika tipe baru
      type: map['jenis'] == 'SOS' ? 'SOS' : 'regular',
      userId: map['user_id']?.toString() ?? 'unknown',
      userName: 'Warga', // Simplifikasi karena join user belum ada
      description: map['deskripsi'] as String,
      lat: map['latitude'] as double?,
      lng: map['longitude'] as double?,
      reportType: map['judul'] as String?, // Menggunakan 'judul' sebagai kategori/jenis
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
      // Field tambahan ini belum ada di tabel 'laporan' versi awal, jadi null dulu
      respondedAt: null,
      responderId: null,
      responderName: null,
      responseMessage: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jenis': type == 'SOS' ? 'SOS' : reportType ?? 'regular',
      'judul': reportType ?? type,
      'deskripsi': description,
      'latitude': lat,
      'longitude': lng,
      'dibuat_pada': createdAt.millisecondsSinceEpoch,
      'status': status,
      'user_id': userId,
    };
  }
}
