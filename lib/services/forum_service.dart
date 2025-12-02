import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/forum_post_model.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

/// Service untuk operasi forum (post & reply).
class ForumService {
  ForumService._internal();
  static final ForumService instance = ForumService._internal();

  /// Membuat posting baru di forum.
  Future<String> createPost({
    required String content,
    required String name,
    required String role, // 'Warga' atau 'Responder'
  }) async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    final post = ForumPost(
      userId: userId,
      name: name,
      role: role,
      content: content,
      repliesCount: 0,
      createdAt: DateTime.now(),
    );

    final docRef = await FirestoreService.instance.forumPosts.add(post.toFirestore());
    return docRef.id;
  }

  /// Stream semua posting forum (urut terbaru).
  Stream<List<ForumPost>> getAllPosts() {
    return FirestoreService.instance.forumPosts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ForumPost.fromFirestore(doc))
            .toList());
  }

  /// Menambah reply ke posting (opsional - bisa diimplementasi nanti).
  Future<void> createReply(String postId, String replyContent) async {
    final userId = AuthService.instance.currentUserId;
    if (userId == null) {
      throw Exception('User belum login');
    }

    // Update repliesCount
    await FirestoreService.instance.forumPostDoc(postId).update({
      'repliesCount': FieldValue.increment(1),
    });

    // TODO: Bisa tambahkan subcollection 'replies' jika perlu detail reply
  }
}

