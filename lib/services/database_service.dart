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
    final dbPath = p.join(docsDir.path, 'siren_app_v3.db'); // Versi 3 (Ganti nama file agar bersih)

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

        // Tabel Forum (Utama)
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

        // Tabel Likes (Baru: Menyimpan status like per user)
        await db.execute('''
          CREATE TABLE forum_likes(
            post_id INTEGER,
            user_id TEXT,
            PRIMARY KEY (post_id, user_id)
          );
        ''');

        // Tabel Replies / Komentar (Baru)
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
    if (maps.isNotEmpty) return User.fromMap(maps.first);
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
      'user_id': report.userId,
    };
    return db.insert('laporan', map);
  }

  Future<int> updateReportStatus(int id, String newStatus) async {
    final db = _database;
    return await db.update(
      'laporan',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Report>> getAllReports() async {
    final db = _database;
    final maps = await db.query(
      'laporan',
      orderBy: 'dibuat_pada DESC',
    );
    return maps.map((m) => Report.fromMap(m)).toList();
  }

  // ================== OPERASI FORUM (UPDATED FOR LIKES & REPLIES) ==================

  Future<int> insertForumPost(ForumPost post) async {
    final db = _database;
    // toMap() sudah termasuk field attachment dari update model sebelumnya
    return db.insert('forum_post', post.toMap());
  }

  /// Mengambil semua postingan, lengkap dengan status 'isLiked' untuk user yang sedang login.
  Future<List<ForumPost>> getAllForumPosts(String currentUserId) async {
    final db = _database;

    // Kita gunakan RAW QUERY agar bisa melakukan LEFT JOIN ke tabel likes.
    // Ini berguna untuk mengecek: Apakah user (currentUserId) sudah like post ini?
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        p.*, 
        CASE WHEN l.user_id IS NOT NULL THEN 1 ELSE 0 END as is_liked
      FROM forum_post p
      LEFT JOIN forum_likes l ON p.id = l.post_id AND l.user_id = ?
      ORDER BY p.dibuat_pada DESC
    ''', [currentUserId]);

    return result.map((m) => ForumPost.fromMap(m)).toList();
  }

  // --- LOGIKA LIKE / UNLIKE ---
  Future<void> toggleLike(int postId, String userId) async {
    final db = _database;

    // 1. Cek apakah user ini sudah like postingan tersebut
    final check = await db.query(
      'forum_likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
    );

    if (check.isNotEmpty) {
      // SUDAH LIKE -> LAKUKAN UNLIKE
      // Hapus dari tabel likes
      await db.delete(
        'forum_likes',
        where: 'post_id = ? AND user_id = ?',
        whereArgs: [postId, userId],
      );
      // Kurangi counter di tabel post
      await db.rawUpdate(
        'UPDATE forum_post SET jumlah_suka = jumlah_suka - 1 WHERE id = ?',
        [postId],
      );
    } else {
      // BELUM LIKE -> LAKUKAN LIKE
      // Masukkan ke tabel likes
      await db.insert('forum_likes', {
        'post_id': postId,
        'user_id': userId,
      });
      // Tambah counter di tabel post
      await db.rawUpdate(
        'UPDATE forum_post SET jumlah_suka = jumlah_suka + 1 WHERE id = ?',
        [postId],
      );
    }
  }

  // --- LOGIKA TAMBAH BALASAN (KOMENTAR) ---
  Future<void> addReply(int postId, String userId, String nama, String role, String isi) async {
    final db = _database;

    // 1. Simpan komentar ke tabel forum_replies
    await db.insert('forum_replies', {
      'post_id': postId,
      'user_id': userId,
      'nama': nama,
      'role': role,
      'isi': isi,
      'dibuat_pada': DateTime.now().millisecondsSinceEpoch,
    });

    // 2. Update jumlah balasan di postingan utama (Increment)
    await db.rawUpdate(
      'UPDATE forum_post SET jumlah_balasan = jumlah_balasan + 1 WHERE id = ?',
      [postId],
    );
  }

  // --- AMBIL DATA BALASAN ---
  Future<List<Map<String, dynamic>>> getReplies(int postId) async {
    final db = _database;
    return await db.query(
      'forum_replies',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'dibuat_pada ASC', // Urutkan dari komentar terlama ke terbaru
    );
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();
    await db.insert('users', {
      'nama': 'Warga Demo',
      'email': 'warga@siren.id',
      'password': 'password',
      'no_hp': '08123456789',
      'peran': 'warga',
      'kontak_darurat': '08111111111,08222222222',
      'foto_profil': null,
      'dibuat_pada': now.millisecondsSinceEpoch,
    });
    await db.insert('users', {
      'nama': 'Petugas Demo',
      'email': 'petugas@siren.id',
      'password': 'password',
      'no_hp': '08987654321',
      'peran': 'responder',
      'kontak_darurat': '',
      'foto_profil': null,
      'dibuat_pada': now.millisecondsSinceEpoch,
    });
  }
}