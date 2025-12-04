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

  // --- FIELD BARU UNTUK LIKE ---
  final int likesCount; // Jumlah Like
  final bool isLiked;   // Status like user saat ini
  // -----------------------------

  final DateTime createdAt;

  // --- FIELD GAMBAR/VIDEO ---
  final String? attachmentPath; // Path lokal file
  final String? attachmentType; // 'image' atau 'video'

  const ForumPost({
    this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.content,
    required this.repliesCount,
    this.likesCount = 0, // Default 0
    this.isLiked = false, // Default false
    required this.createdAt,
    this.attachmentPath,
    this.attachmentType,
  });

  ForumPost copyWith({
    String? id,
    String? userId,
    String? name,
    String? role,
    String? content,
    int? repliesCount,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    String? attachmentPath,
    String? attachmentType,
  }) {
    return ForumPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
      content: content ?? this.content,
      repliesCount: repliesCount ?? this.repliesCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      attachmentType: attachmentType ?? this.attachmentType,
    );
  }

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      id: map['id'].toString(),
      userId: map['user_id'] != null ? map['user_id'].toString() : 'legacy_user',
      name: map['nama'] as String,
      role: map['peran'] as String,
      content: map['isi'] as String,
      repliesCount: map['jumlah_balasan'] as int? ?? 0,

      // --- BACA DATA LIKE DARI DB ---
      likesCount: map['jumlah_suka'] as int? ?? 0,
      // SQLite return 1 atau 0, kita ubah ke boolean
      isLiked: (map['is_liked'] ?? 0) == 1,
      // ------------------------------

      createdAt: DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
      attachmentPath: map['attachment_path'] as String?,
      attachmentType: map['attachment_type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': name,
      'peran': role,
      'isi': content,
      'jumlah_balasan': repliesCount,
      'jumlah_suka': likesCount, // Simpan jumlah suka
      'dibuat_pada': createdAt.millisecondsSinceEpoch,
      'user_id': userId,
      'attachment_path': attachmentPath,
      'attachment_type': attachmentType,
    };
  }
}