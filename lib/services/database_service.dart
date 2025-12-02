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

        await _seedInitialData(db);
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
    // Convert new Report model to legacy SQLite format
    final map = {
      'jenis': report.type == 'SOS' ? 'SOS' : report.reportType ?? 'regular',
      'judul': report.reportType ?? report.type,
      'deskripsi': report.description,
      'lokasi_teks': null,
      'latitude': report.lat,
      'longitude': report.lng,
      'dibuat_pada': report.createdAt.millisecondsSinceEpoch,
      'status': report.status,
    };
    return db.insert('laporan', map);
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
    // Convert new ForumPost model to legacy SQLite format
    final map = {
      'nama': post.name,
      'peran': post.role,
      'isi': post.content,
      'jumlah_suka': 0,
      'jumlah_balasan': post.repliesCount,
      'dibuat_pada': post.createdAt.millisecondsSinceEpoch,
    };
    return db.insert('forum_post', map);
  }

  Future<List<ForumPost>> getAllForumPosts() async {
    final db = _database;
    final maps = await db.query(
      'forum_post',
      orderBy: 'dibuat_pada DESC',
    );
    return maps.map((m) => ForumPost.fromMap(m)).toList();
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();

    // Seed forum posts using legacy format for SQLite compatibility
    final dummyForum = [
      {
        'nama': 'Rina',
        'peran': 'Warga',
        'isi': 'Ada jalan berlubang besar di dekat pos ronda RW 05. Mohon diperbaiki.',
        'jumlah_suka': 12,
        'jumlah_balasan': 3,
        'dibuat_pada': now.subtract(const Duration(hours: 4)).millisecondsSinceEpoch,
      },
      {
        'nama': 'Agus',
        'peran': 'Responder',
        'isi': 'Tim pemadam sedang patroli di wilayah barat kota. Laporkan jika lihat asap atau api.',
        'jumlah_suka': 20,
        'jumlah_balasan': 5,
        'dibuat_pada': now.subtract(const Duration(days: 1, hours: 2)).millisecondsSinceEpoch,
      },
      {
        'nama': 'Dwi',
        'peran': 'Warga',
        'isi': 'Sirene SOS tadi malam sangat membantu, terima kasih tim responder!',
        'jumlah_suka': 30,
        'jumlah_balasan': 10,
        'dibuat_pada': now.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
      },
    ];

    for (final post in dummyForum) {
      await db.insert('forum_post', post);
    }

    // Seed reports using legacy format for SQLite compatibility
    final dummyReports = [
      {
        'jenis': 'SOS',
        'judul': 'Butuh Ambulans',
        'deskripsi': 'Kecelakaan kecil di Jalan Sisingamangaraja, korban masih sadar.',
        'lokasi_teks': 'Jalan Sisingamangaraja No.12',
        'latitude': -6.9965,
        'longitude': 110.4281,
        'dibuat_pada': now.subtract(const Duration(minutes: 50)).millisecondsSinceEpoch,
        'status': 'baru',
      },
      {
        'jenis': 'Banjir',
        'judul': 'Banjir Setinggi Lutut',
        'deskripsi': 'Air meluap ke jalan utama, kendaraan sulit lewat.',
        'lokasi_teks': 'Komplek Melati Indah',
        'latitude': -6.9843,
        'longitude': 110.4212,
        'dibuat_pada': now.subtract(const Duration(hours: 5)).millisecondsSinceEpoch,
        'status': 'baru',
      },
      {
        'jenis': 'Kebakaran',
        'judul': 'Asap di Gudang',
        'deskripsi': 'Ada asap pekat keluar dari gudang kayu bekas.',
        'lokasi_teks': 'Gudang Kayu RT 07',
        'latitude': -6.9731,
        'longitude': 110.4355,
        'dibuat_pada': now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        'status': 'baru',
      },
    ];

    for (final report in dummyReports) {
      await db.insert('laporan', report);
    }
  }
}



