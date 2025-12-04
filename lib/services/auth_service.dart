import 'dart:async';

import '../models/user_model.dart';
import 'database_service.dart';
import 'package:flutter/foundation.dart'; // Wajib untuk notifyListeners/ChangeNotifier

class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  // Stream controller untuk memberitahu UI tentang perubahan status auth
  final _authStateController = StreamController<User?>.broadcast();

  User? _currentUser;

  User? get currentUser => _currentUser;
  Stream<User?> get authStateChanges => _authStateController.stream;

  /// Sign in dengan email & password (cek database lokal).
  Future<User?> signInWithEmail(String email, String password) async {
    // PENTING: Inisialisasi DB di sini
    await DatabaseService.instance.init();

    final user = await DatabaseService.instance.login(email, password);

    if (user != null) {
      _currentUser = user;
      _authStateController.add(user);
      notifyListeners(); // Memberi tahu widget lain
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
      // PENTING: Inisialisasi DB di sini
      await DatabaseService.instance.init();

      final newUser = User(
        id: 'temp_id',
        displayName: name,
        phone: phone,
        email: email,
        role: role,
        contacts: [],
        createdAt: DateTime.now(),
      );

      await DatabaseService.instance.registerUser(newUser, password);

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
    notifyListeners();
  }

  // --- FUNGSI updateProfile (DIPERLUKAN OLEH PROFILE SCREEN) ---
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? photoPath,
    List<String>? contacts, // List kontak baru
  }) async {
    if (_currentUser == null) return;

    await DatabaseService.instance.init();

    // Baris ini memanggil copyWith, yang akan diperbaiki di file User Model
    final updatedUser = _currentUser!.copyWith(
      displayName: name,
      email: email,
      phone: phone,
      profileImageUrl: photoPath ?? _currentUser!.profileImageUrl,
      contacts: contacts ?? _currentUser!.contacts,
    );

    // Baris ini memanggil updateUser, yang akan diperbaiki di file Database Service
    await DatabaseService.instance.updateUser(updatedUser);

    _currentUser = updatedUser;
    _authStateController.add(updatedUser);
    notifyListeners(); // Wajib dipanggil untuk widget Listener
  }
}