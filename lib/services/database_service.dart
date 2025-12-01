import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/report_model.dart';
import '../models/forum_post_model.dart';

/// Layanan tunggal untuk mengelola database SQLite aplikasi.
///
/// Tabel utama:
/// - laporan
/// - forum_post
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'siren_app.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE laporan(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis TEXT NOT NULL,
            judul TEXT NOT NULL,
            deskripsi TEXT NOT NULL,
            lokasi_teks TEXT,
            latitude REAL,
            longitude REAL,
            dibuat_pada INTEGER NOT NULL,
            status TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE forum_post(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            peran TEXT NOT NULL,
            isi TEXT NOT NULL,
            jumlah_suka INTEGER NOT NULL,
            jumlah_balasan INTEGER NOT NULL,
            dibuat_pada INTEGER NOT NULL
          );
        ''');
      },
    );
  }

  Database get _database {
    final db = _db;
    if (db == null) {
      throw StateError(
          'Database belum diinisialisasi. Panggil DatabaseService.instance.init() di awal aplikasi.');
    }
    return db;
  }

  // ================== OPERASI LAPORAN ==================

  Future<int> insertReport(Report report) async {
    final db = _database;
    return db.insert('laporan', report.toMap());
  }

  Future<List<Report>> getAllReports() async {
    final db = _database;
    final maps = await db.query(
      'laporan',
      orderBy: 'dibuat_pada DESC',
    );
    return maps.map((m) => Report.fromMap(m)).toList();
  }

  // ================== OPERASI FORUM ==================

  Future<int> insertForumPost(ForumPost post) async {
    final db = _database;
    return db.insert('forum_post', post.toMap());
  }

  Future<List<ForumPost>> getAllForumPosts() async {
    final db = _database;
    final maps = await db.query(
      'forum_post',
      orderBy: 'dibuat_pada DESC',
    );
    return maps.map((m) => ForumPost.fromMap(m)).toList();
  }
}


