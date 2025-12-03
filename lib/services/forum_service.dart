import '../models/forum_post_model.dart';
import 'database_service.dart';
import 'auth_service.dart';

/// Service untuk operasi forum (SQLite Version).
class ForumService {
  ForumService._internal();
  static final ForumService instance = ForumService._internal();

  /// Membuat posting baru di forum.
  Future<int> createPost({
    required String content,
    required String name,
    required String role, // 'Warga' atau 'Responder'
  }) async {
    final userId = AuthService.instance.currentUser?.id ?? 'unknown';

    final post = ForumPost(
      userId: userId,
      name: name,
      role: role,
      content: content,
      repliesCount: 0,
      createdAt: DateTime.now(),
    );

    return await DatabaseService.instance.insertForumPost(post);
  }

  /// Get semua posting forum (Future, bukan Stream).
  Future<List<ForumPost>> getAllPosts() async {
    return await DatabaseService.instance.getAllForumPosts();
  }

  /// Menambah reply ke posting (Simulasi).
  Future<void> createReply(String postId, String replyContent) async {
    // TODO: Implementasi tabel 'replies' di SQLite
    // Untuk sekarang update jumlah balasan saja di mock/UI
    print('Reply to post $postId: $replyContent');
  }
}
