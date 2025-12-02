import 'package:cloud_firestore/cloud_firestore.dart';

/// Singleton service untuk akses Firestore collections.
class FirestoreService {
  FirestoreService._internal();
  static final FirestoreService instance = FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference<Map<String, dynamic>> get users => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get responders => _firestore.collection('responders');
  CollectionReference<Map<String, dynamic>> get reports => _firestore.collection('reports');
  CollectionReference<Map<String, dynamic>> get forumPosts => _firestore.collection('forumPosts');

  // Helper methods
  DocumentReference<Map<String, dynamic>> userDoc(String userId) => users.doc(userId);
  DocumentReference<Map<String, dynamic>> responderDoc(String responderId) => responders.doc(responderId);
  DocumentReference<Map<String, dynamic>> reportDoc(String reportId) => reports.doc(reportId);
  DocumentReference<Map<String, dynamic>> forumPostDoc(String postId) => forumPosts.doc(postId);
}

