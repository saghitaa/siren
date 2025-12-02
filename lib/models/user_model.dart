import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model user yang disimpan di Firestore.
@immutable
class User {
  final String id;
  final String displayName;
  final String phone;
  final String role; // 'warga' atau 'responder'
  final List<String> contacts; // array nomor darurat
  final String? profileImageUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.role,
    required this.contacts,
    this.profileImageUrl,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? displayName,
    String? phone,
    String? role,
    List<String>? contacts,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      contacts: contacts ?? this.contacts,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      id: doc.id,
      displayName: data['displayName'] as String,
      phone: data['phone'] as String,
      role: data['role'] as String,
      contacts: List<String>.from(data['contacts'] as List? ?? []),
      profileImageUrl: data['profileImageUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'phone': phone,
      'role': role,
      'contacts': contacts,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

