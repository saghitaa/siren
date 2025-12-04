import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;

  User? get currentUser => _currentUser;
  Stream<User?> get authStateChanges => _authStateController.stream;

  Future<void> init() async {
    await DatabaseService.instance.init();
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final user = await DatabaseService.instance.login(email, password);
    if (user != null) {
      _currentUser = user;
      _authStateController.add(user);
      notifyListeners();
    }
    return user;
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final newUser = User(
        id: 'temp_id', // Akan diabaikan oleh DB
        displayName: name,
        phone: phone,
        email: email,
        role: role,
        contacts: [],
        createdAt: DateTime.now(),
        status: 'Offline', // Default saat daftar
      );

      await DatabaseService.instance.registerUser(newUser, password);
      await signInWithEmail(email, password);
      return true;
    } catch (e) {
      debugPrint("SignUp Gagal: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    // Sebelum logout, set status jadi offline
    if (_currentUser != null) {
      await updateUserStatus('Offline');
    }
    _currentUser = null;
    _authStateController.add(null);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? photoPath,
    List<String>? contacts,
    String? role,
  }) async {
    if (_currentUser == null) return;

    // Ambil status terakhir dari DB, JANGAN TIMPA
    final latestUser = await DatabaseService.instance.getUserById(int.parse(_currentUser!.id));

    final updatedUser = _currentUser!.copyWith(
      displayName: name,
      email: email,
      phone: phone,
      profileImageUrl: photoPath ?? _currentUser!.profileImageUrl,
      contacts: contacts ?? _currentUser!.contacts,
      role: role ?? _currentUser!.role,
      status: latestUser?.status ?? _currentUser!.status, // Pertahankan status terakhir
    );

    await DatabaseService.instance.updateUser(updatedUser);

    _currentUser = updatedUser;
    _authStateController.add(updatedUser);
    notifyListeners();
  }

  Future<void> updateUserStatus(String status) async {
    if (_currentUser == null) return;

    await DatabaseService.instance.updateUserStatus(_currentUser!.id, status);

    final updatedUser = _currentUser!.copyWith(status: status);
    _currentUser = updatedUser;
    
    _authStateController.add(updatedUser);
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    final user = await DatabaseService.instance.getUserById(int.parse(_currentUser!.id));
    if (user != null) {
      _currentUser = user;
      _authStateController.add(user);
      notifyListeners();
    }
  }
}