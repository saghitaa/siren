import 'dart:async';
import 'package:flutter/foundation.dart';
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

    // GANTI NAMA DB UNTUK MEMAKSA PEMBUATAN ULANG STRUKTUR YANG BENAR
    final dbPath = p.join(docsDir.path, 'siren_app_final.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // 1. Tabel User
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

        // 2. Tabel Laporan (SUDAH DILENGKAPI DENGAN userName)
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
            user_id TEXT, 
            userName TEXT, -- Kolom yang sebelumnya error
            
            responded_at INTEGER,
            responder_id TEXT,
            responder_name TEXT,
            response_message TEXT 
          );
        ''');

        // 3. Tabel Forum
        await db.execute('''
          CREATE TABLE forum_post(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            peran TEXT NOT NULL,
            isi TEXT NOT NULL,
            jumlah_suka INTEGER DEFAULT 0,
            jumlah_balasan INTEGER DEFAULT 0,
            dibuat_pada INTEGER NOT NULL,
            attachment_path TEXT, 
            attachment_type TEXT,
            user_id TEXT 
          );
        ''');

        // 4. Tabel Likes
        await db.execute('''
          CREATE TABLE forum_likes(
            post_id INTEGER,
            user_id TEXT,
            PRIMARY KEY (post_id, user_id)
          );
        ''');

        // 5. Tabel Replies
        await db.execute('''
          CREATE TABLE forum_replies(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            post_id INTEGER,
            user_id TEXT,
            nama TEXT,
            role TEXT,
            isi TEXT,
            dibuat_pada INTEGER
          );
        ''');

        await _seedInitialData(db);
      },
    );
  }

  Database get _database {
    final db = _db;
    if (db == null) {
      throw StateError('Database belum diinisialisasi. Panggil DatabaseService.instance.init() di awal aplikasi.');
    }
    return db;
  }

  // --- UPDATE USER ---
  Future<int> updateUser(User user) async {
    final db = _database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ================== OPERASI LAPORAN ==================

  Future<int> insertReport(Report report) async {
    final db = _database;

    // Pastikan data lengkap sebelum insert
    final map = report.toMap();

    // Pastikan userName terisi (Fallback ke 'Warga' jika null)
    if (map['userName'] == null) {
      map['userName'] = report.userName.isNotEmpty ? report.userName : 'Warga';
    }

    // Konversi DateTime
    if (map['dibuat_pada'] is DateTime) {
      map['dibuat_pada'] = (map['dibuat_pada'] as DateTime).millisecondsSinceEpoch;
    }

    map.remove('id');

    return db.insert('laporan', map);
  }

  Future<int> updateReportStatus(int id, String newStatus, {String? responderId, String? responderName}) async {
    final db = _database;

    final Map<String, dynamic> updateMap = {'status': newStatus};

    if (newStatus.toLowerCase().contains('proses') || newStatus.toLowerCase().contains('selesai')) {
      updateMap['responded_at'] = DateTime.now().millisecondsSinceEpoch;
      if (responderId != null) updateMap['responder_id'] = responderId;
      if (responderName != null) updateMap['responder_name'] = responderName;
    }

    return await db.update(
      'laporan',
      updateMap,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Report>> getAllReports() async {
    final db = _database;
    final maps = await db.query('laporan', orderBy: 'dibuat_pada DESC');
    return maps.map((m) => Report.fromMap(m)).toList();
  }

  // ================== OPERASI FORUM ==================

  Future<int> insertForumPost(ForumPost post) async {
    final db = _database;
    final map = post.toMap();
    map.remove('id');
    return db.insert('forum_post', map);
  }

  Future<List<ForumPost>> getAllForumPosts(String uid) async {
    final db = _database;
    final res = await db.rawQuery('''
      SELECT 
        p.*, 
        CASE WHEN l.user_id IS NOT NULL THEN 1 ELSE 0 END as is_liked
      FROM forum_post p
      LEFT JOIN forum_likes l ON p.id = l.post_id AND l.user_id = ?
      ORDER BY p.dibuat_pada DESC
    ''', [uid]);
    return res.map((m) => ForumPost.fromMap(m)).toList();
  }

  Future<void> toggleLike(int postId, String userId) async {
    final db = _database;
    final check = await db.query('forum_likes', where: 'post_id = ? AND user_id = ?', whereArgs: [postId, userId]);

    if (check.isNotEmpty) {
      await db.delete('forum_likes', where: 'post_id = ? AND user_id = ?', whereArgs: [postId, userId]);
      await db.rawUpdate('UPDATE forum_post SET jumlah_suka = jumlah_suka - 1 WHERE id = ?', [postId]);
    } else {
      await db.insert('forum_likes', {'post_id': postId, 'user_id': userId});
      await db.rawUpdate('UPDATE forum_post SET jumlah_suka = jumlah_suka + 1 WHERE id = ?', [postId]);
    }
  }

  Future<void> addReply(int postId, String userId, String nama, String role, String isi) async {
    final db = _database;
    await db.insert('forum_replies', {
      'post_id': postId,
      'user_id': userId,
      'nama': nama,
      'role': role,
      'isi': isi,
      'dibuat_pada': DateTime.now().millisecondsSinceEpoch,
    });
    await db.rawUpdate('UPDATE forum_post SET jumlah_balasan = jumlah_balasan + 1 WHERE id = ?', [postId]);
  }

  Future<List<Map<String, dynamic>>> getReplies(int postId) async {
    final db = _database;
    return await db.query('forum_replies', where: 'post_id = ?', whereArgs: [postId], orderBy: 'dibuat_pada ASC');
  }

  // --- AUTHENTICATION ---
  Future<User?> login(String email, String password) async {
    final db = _database;
    final maps = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
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
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();
    await db.insert('users', {'nama': 'Warga Demo', 'email': 'warga@siren.id', 'password': 'password', 'no_hp': '08123456789', 'peran': 'warga', 'kontak_darurat': '08111111111,08222222222', 'foto_profil': null, 'dibuat_pada': now.millisecondsSinceEpoch});
    await db.insert('users', {'nama': 'Petugas Demo', 'email': 'petugas@siren.id', 'password': 'password', 'no_hp': '08987654321', 'peran': 'responder', 'kontak_darurat': '', 'foto_profil': null, 'dibuat_pada': now.millisecondsSinceEpoch});
  }
}