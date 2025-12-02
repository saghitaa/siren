import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Model kiriman forum yang disimpan di Firestore.
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

  factory ForumPost.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ForumPost(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      role: data['role'] as String,
      content: data['content'] as String,
      repliesCount: data['repliesCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'content': content,
      'repliesCount': repliesCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Legacy SQLite support
  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      id: map['id']?.toString(),
      userId: 'legacy_user',
      name: map['nama'] as String,
      role: map['peran'] as String,
      content: map['isi'] as String,
      repliesCount: map['jumlah_balasan'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
    );
  }
}
