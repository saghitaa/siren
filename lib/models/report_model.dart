import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model laporan darurat / umum yang disimpan di Firestore.
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

  factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Report(
      id: doc.id,
      type: data['type'] as String? ?? 'regular',
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      description: data['description'] as String,
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      reportType: data['reportType'] as String?,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      responderId: data['responderId'] as String?,
      responderName: data['responderName'] as String?,
      responseMessage: data['responseMessage'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'userId': userId,
      'userName': userName,
      'description': description,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (reportType != null) 'reportType': reportType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (respondedAt != null) 'respondedAt': Timestamp.fromDate(respondedAt!),
      if (responderId != null) 'responderId': responderId,
      if (responderName != null) 'responderName': responderName,
      if (responseMessage != null) 'responseMessage': responseMessage,
    };
  }

  // Legacy SQLite support (untuk migrasi)
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id']?.toString(),
      type: map['jenis'] == 'SOS' ? 'SOS' : 'regular',
      userId: 'legacy_user',
      userName: 'Legacy User',
      description: map['deskripsi'] as String,
      lat: map['latitude'] as double?,
      lng: map['longitude'] as double?,
      reportType: map['jenis'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
    );
  }
}
