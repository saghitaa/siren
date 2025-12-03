import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/report_model.dart';
import '../models/forum_post_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'siren_app_v2.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Tabel User
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            no_hp TEXT NOT NULL,
            peran TEXT NOT NULL,
            kontak_darurat TEXT,
            foto_profil TEXT,
            dibuat_pada INTEGER NOT NULL
          );
        ''');

        // Tabel Laporan
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
            status TEXT NOT NULL,
            user_id INTEGER 
          );
        ''');

        // Tabel Forum
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

  // ================== OPERASI USER ==================

  Future<User?> login(String email, String password) async {
    final db = _database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> registerUser(User user, String password) async {
    final db = _database;
    final map = user.toMap();
    map['password'] = password;
    return await db.insert('users', map);
  }

  Future<User?> getUserById(int id) async {
     final db = _database;
     final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
     if(maps.isNotEmpty) return User.fromMap(maps.first);
     return null;
  }

  // ================== OPERASI LAPORAN ==================

  Future<int> insertReport(Report report) async {
    final db = _database;
    final map = {
      'jenis': report.type == 'SOS' ? 'SOS' : report.reportType ?? 'regular',
      'judul': report.reportType ?? report.type,
      'deskripsi': report.description,
      'lokasi_teks': null,
      'latitude': report.lat,
      'longitude': report.lng,
      'dibuat_pada': report.createdAt.millisecondsSinceEpoch,
      'status': report.status,
      'user_id': report.userId, // Pastikan ini ada
    };
    return db.insert('laporan', map);
  }

  // --- FUNGSI UPDATE STATUS (INI YANG KEMARIN HILANG) ---
  Future<int> updateReportStatus(int id, String newStatus) async {
    final db = _database;
    return await db.update(
      'laporan',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  // -----------------------------------------------------

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
    final maps = await db.query('forum_post', orderBy: 'dibuat_pada DESC');
    return maps.map((m) => ForumPost.fromMap(m)).toList();
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();
    await db.insert('users', {
      'nama': 'Warga Demo', 'email': 'warga@siren.id', 'password': 'password', 'no_hp': '08123456789', 'peran': 'warga', 'kontak_darurat': '08111111111,08222222222', 'foto_profil': null, 'dibuat_pada': now.millisecondsSinceEpoch,
    });
    await db.insert('users', {
      'nama': 'Petugas Demo', 'email': 'petugas@siren.id', 'password': 'password', 'no_hp': '08987654321', 'peran': 'responder', 'kontak_darurat': '', 'foto_profil': null, 'dibuat_pada': now.millisecondsSinceEpoch,
    });
  }
}