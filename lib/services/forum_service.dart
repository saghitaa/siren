import '../models/forum_post_model.dart';
import 'database_service.dart';
import 'auth_service.dart';

class ForumService {
  ForumService._internal();
  static final ForumService instance = ForumService._internal();

  // Mengambil data dari SQLite (sekarang butuh ID user untuk cek status like)
  Future<List<ForumPost>> getAllPosts() async {
    // Pastikan database siap
    await DatabaseService.instance.init();

    // Ambil User ID yang sedang login agar tahu postingan mana yang sudah di-like
    final user = AuthService.instance.currentUser;
    final userId = user?.id ?? 'guest';

    return await DatabaseService.instance.getAllForumPosts(userId);
  }

  // Membuat Postingan Baru (Gambar/Video + Text)
  Future<void> createPost({
    required String content,
    required String name,
    required String role,
    String? attachmentPath,
    String? attachmentType,
  }) async {
    await DatabaseService.instance.init();
    final user = AuthService.instance.currentUser;

    final newPost = ForumPost(
      // Gunakan ID user asli, jika null gunakan 'guest'
      userId: user?.id ?? 'guest',
      name: name,
      role: role,
      content: content,
      createdAt: DateTime.now(),
      repliesCount: 0,
      attachmentPath: attachmentPath,
      attachmentType: attachmentType,
    );

    await DatabaseService.instance.insertForumPost(newPost);
  }

  // --- FITUR LIKE (BARU) ---
  Future<void> toggleLike(String postId) async {
    await DatabaseService.instance.init();
    final user = AuthService.instance.currentUser;

    // User harus login untuk like
    if (user == null) return;

    await DatabaseService.instance.toggleLike(int.parse(postId), user.id);
  }

  // --- FITUR REPLY / KOMENTAR (BARU) ---
  Future<void> sendReply(String postId, String content) async {
    await DatabaseService.instance.init();
    final user = AuthService.instance.currentUser;

    // User harus login untuk komentar
    if (user == null) return;

    await DatabaseService.instance.addReply(
        int.parse(postId),
        user.id,
        user.displayName,
        user.role,
        content
    );
  }

  // Mengambil daftar komentar untuk sebuah postingan
  Future<List<Map<String, dynamic>>> getPostReplies(String postId) async {
    await DatabaseService.instance.init();
    return await DatabaseService.instance.getReplies(int.parse(postId));
  }
}