import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model responder yang disimpan di Firestore.
@immutable
class Responder {
  final String id;
  final String userId;
  final String displayName;
  final String roleType; // jenis responder
  final String? fcmToken;
  final String status; // 'Tersedia' | 'Tidak'
  final DateTime createdAt;

  const Responder({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.roleType,
    this.fcmToken,
    required this.status,
    required this.createdAt,
  });

  Responder copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? roleType,
    String? fcmToken,
    String? status,
    DateTime? createdAt,
  }) {
    return Responder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      roleType: roleType ?? this.roleType,
      fcmToken: fcmToken ?? this.fcmToken,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Responder.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Responder(
      id: doc.id,
      userId: data['userId'] as String,
      displayName: data['displayName'] as String,
      roleType: data['roleType'] as String,
      fcmToken: data['fcmToken'] as String?,
      status: data['status'] as String? ?? 'Tersedia',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'roleType': roleType,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

