import 'package:flutter/foundation.dart';

/// Model kiriman forum yang disimpan di SQLite.
@immutable
class ForumPost {
  final String? id;
  final String userId;
  final String name;
  final String role; // "Warga" atau "Responder"
  final String content;
  final int repliesCount;
  final DateTime createdAt;

  const ForumPost({
    this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.content,
    required this.repliesCount,
    required this.createdAt,
  });

  ForumPost copyWith({
    String? id,
    String? userId,
    String? name,
    String? role,
    String? content,
    int? repliesCount,
    DateTime? createdAt,
  }) {
    return ForumPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      content: content ?? this.content,
      repliesCount: repliesCount ?? this.repliesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      id: map['id'].toString(),
      userId: 'legacy_user', // TODO: Tambahkan user_id di tabel forum
      name: map['nama'] as String,
      role: map['peran'] as String,
      content: map['isi'] as String,
      repliesCount: map['jumlah_balasan'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': name,
      'peran': role,
      'isi': content,
      'jumlah_balasan': repliesCount,
      'dibuat_pada': createdAt.millisecondsSinceEpoch,
      // 'user_id': userId // Tambahkan jika tabel sudah diupdate
    };
  }
}
