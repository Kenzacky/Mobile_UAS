import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Provider untuk mengelola Authentication State
/// Menangani login, register, logout dan session management
class AuthProvider with ChangeNotifier {
  // Instance Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Menyimpan user yang sedang login
  User? _user;

  /// Getter untuk mengakses user dari UI
  /// Return null jika belum login
  User? get user => _user;

  /// Getter untuk mengecek apakah user sudah login
  bool get isLoggedIn => _user != null;

  /// Constructor - setup listener untuk perubahan auth state
  AuthProvider() {
    // Mendengarkan setiap perubahan status autentikasi
    // Bisa digunakan untuk auto-logout atau refresh token
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      // Notify semua listener (UI widgets) tentang perubahan state
      notifyListeners();
    });
  }

  /// Fungsi untuk register/membuat akun baru
  /// [email]: Email yang digunakan untuk registrasi
  /// [password]: Password minimal 6 karakter
  /// Throws: FirebaseAuthException jika ada error (email sudah terdaftar, password lemah, dll)
  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Fungsi untuk login dengan email dan password
  /// [email]: Email pengguna
  /// [password]: Password pengguna
  /// Throws: FirebaseAuthException jika email/password salah
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Fungsi untuk logout/sign out
  /// Akan menghapus session pengguna dan clear cache
  Future<void> logout() async {
    await _auth.signOut();
  }
}