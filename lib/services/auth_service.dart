import 'dart:async';

import '../models/user_model.dart';
import 'database_service.dart';

/// Service untuk autentikasi menggunakan SQLite Lokal (Tanpa Firebase).
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  // Stream controller untuk memberitahu UI tentang perubahan status auth
  final _authStateController = StreamController<User?>.broadcast();
  
  User? _currentUser;

  User? get currentUser => _currentUser;
  Stream<User?> get authStateChanges => _authStateController.stream;

  /// Sign in dengan email & password (cek database lokal).
  Future<User?> signInWithEmail(String email, String password) async {
    final user = await DatabaseService.instance.login(email, password);
    if (user != null) {
      _currentUser = user;
      _authStateController.add(user);
    }
    return user;
  }

  /// Sign up dengan email & password (simpan ke database lokal).
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final newUser = User(
        id: 'temp_id', // ID akan di-generate otomatis oleh SQLite
        displayName: name,
        phone: phone,
        email: email,
        role: role,
        contacts: [],
        createdAt: DateTime.now(),
      );
      
      await DatabaseService.instance.registerUser(newUser, password);
      
      // Auto login setelah register
      await signInWithEmail(email, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }
}
