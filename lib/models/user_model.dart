import 'package:flutter/foundation.dart';

/// Model user yang disimpan di SQLite.
@immutable
class User {
  final String id;
  final String displayName;
  final String phone;
  final String email; // Tambahan untuk login
  final String role; // 'warga' atau 'responder'
  final List<String> contacts; // Disimpan sebagai string dipisahkan koma
  final String? profileImageUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.role,
    required this.contacts,
    this.profileImageUrl,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      displayName: map['nama'] as String,
      phone: map['no_hp'] as String,
      email: map['email'] as String,
      role: map['peran'] as String,
      contacts: (map['kontak_darurat'] as String?)?.split(',') ?? [],
      profileImageUrl: map['foto_profil'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': displayName,
      'no_hp': phone,
      'email': email,
      'peran': role,
      'kontak_darurat': contacts.join(','),
      'foto_profil': profileImageUrl,
      'dibuat_pada': createdAt.millisecondsSinceEpoch,
    };
  }
}
