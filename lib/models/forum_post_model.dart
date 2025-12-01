import 'package:flutter/foundation.dart';

/// Model kiriman forum yang disimpan di SQLite.
@immutable
class ForumPost {
  final int? id;
  final String nama;
  final String peran; // "Warga" atau "Responder"
  final String isi;
  final int jumlahSuka;
  final int jumlahBalasan;
  final DateTime dibuatPada;

  const ForumPost({
    this.id,
    required this.nama,
    required this.peran,
    required this.isi,
    required this.jumlahSuka,
    required this.jumlahBalasan,
    required this.dibuatPada,
  });

  ForumPost copyWith({
    int? id,
    String? nama,
    String? peran,
    String? isi,
    int? jumlahSuka,
    int? jumlahBalasan,
    DateTime? dibuatPada,
  }) {
    return ForumPost(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      peran: peran ?? this.peran,
      isi: isi ?? this.isi,
      jumlahSuka: jumlahSuka ?? this.jumlahSuka,
      jumlahBalasan: jumlahBalasan ?? this.jumlahBalasan,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      peran: map['peran'] as String,
      isi: map['isi'] as String,
      jumlahSuka: map['jumlah_suka'] as int,
      jumlahBalasan: map['jumlah_balasan'] as int,
      dibuatPada:
          DateTime.fromMillisecondsSinceEpoch(map['dibuat_pada'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'peran': peran,
      'isi': isi,
      'jumlah_suka': jumlahSuka,
      'jumlah_balasan': jumlahBalasan,
      'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
    };
  }
}


