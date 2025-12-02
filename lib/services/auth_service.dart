import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'firestore_service.dart';

/// Service untuk autentikasi Firebase.
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  firebase_auth.User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in secara anonymous (untuk demo/testing).
  Future<firebase_auth.UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  /// Sign in dengan email & password.
  Future<firebase_auth.UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up dengan email & password.
  Future<firebase_auth.UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user data dari Firestore.
  Future<User?> getUserData(String userId) async {
    final doc = await FirestoreService.instance.userDoc(userId).get();
    if (!doc.exists) return null;
    return User.fromFirestore(doc);
  }

  /// Create atau update user data di Firestore.
  Future<void> saveUserData(User user) async {
    await FirestoreService.instance.userDoc(user.id).set(user.toFirestore());
  }
}

