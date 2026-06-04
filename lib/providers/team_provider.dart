import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';

/// Provider untuk mengelola Team (Tim) Data
/// Menangani CRUD operation tim dari Firestore
class TeamProvider with ChangeNotifier {
  // Reference ke collection 'teams' di Firestore
  final CollectionReference<Map<String, dynamic>> _teamsCollection =
  FirebaseFirestore.instance.collection('teams');

  // Menyimpan list tim yang sedang di-load
  List<Team> _teams = [];
  // Flag untuk loading state
  bool _isLoading = false;
  // Menyimpan error message jika ada
  String? _errorMessage;

  /// Getter untuk mengakses list tim dari UI
  List<Team> get teams => _teams;

  /// Getter untuk loading state
  bool get isLoading => _isLoading;

  /// Getter untuk error message
  String? get errorMessage => _errorMessage;

  /// Getter untuk jumlah tim
  int get teamCount => _teams.length;

  /// Constructor - langsung fetch data tim saat provider dibuat
  TeamProvider() {
    fetchTeams();
  }

  /// Fetch (Membaca) semua tim dari Firestore
  /// Menggunakan real-time listener untuk auto-update saat data berubah
  void fetchTeams() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _teamsCollection.snapshots().listen(
          (snapshot) {
        try {
          // Map setiap document menjadi Team object
          _teams = snapshot.docs.map((doc) {
            return Team.fromFirestore(doc);
          }).toList();

          // Urutkan tim berdasarkan nama
          _teams.sort((a, b) => a.name.compareTo(b.name));
          _isLoading = false;
          _errorMessage = null;

          // Notify semua listener tentang perubahan data
          notifyListeners();
        } catch (e) {
          _isLoading = false;
          _errorMessage = 'Error loading teams: $e';
          notifyListeners();
        }
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  /// Create (Membuat) tim baru ke Firestore
  /// [name]: Nama tim
  /// [logoUrl]: URL logo tim (optional)
  Future<void> addTeam(
      String name,
      String? logoUrl,
      ) async {
    try {
      await _teamsCollection.add({
        'name': name,
        'logoUrl': logoUrl,
        // Set timestamp server untuk waktu yang akurat
        'createdAt': FieldValue.serverTimestamp(),
      });
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error adding team: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update (Mengubah) data tim di Firestore
  /// [id]: ID tim yang akan diubah
  /// [name]: Nama tim baru
  /// [logoUrl]: URL logo tim baru (optional)
  Future<void> updateTeam(
      String id,
      String name,
      String? logoUrl,
      ) async {
    try {
      await _teamsCollection.doc(id).update({
        'name': name,
        'logoUrl': logoUrl,
      });
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error updating team: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete (Menghapus) tim dari Firestore
  /// [id]: ID tim yang akan dihapus
  /// WARNING: Harus hapus semua match yang melibatkan tim ini terlebih dahulu
  Future<void> deleteTeam(String id) async {
    try {
      await _teamsCollection.doc(id).delete();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error deleting team: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get (Mencari) tim berdasarkan ID
  /// [id]: ID tim yang dicari
  /// Return: Team object atau null jika tidak ditemukan
  Team? getTeamById(String id) {
    try {
      return _teams.firstWhere(
            (team) => team.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get (Mencari) tim berdasarkan nama
  /// [name]: Nama tim yang dicari
  /// Return: Team object atau null jika tidak ditemukan
  Team? getTeamByName(String name) {
    try {
      return _teams.firstWhere(
            (team) => team.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah nama tim sudah ada
  /// [name]: Nama tim yang dicek
  /// Return: true jika sudah ada, false jika belum
  bool isTeamNameExists(String name) {
    return _teams.any(
          (team) => team.name.toLowerCase() == name.toLowerCase(),
    );
  }

  /// Search (Mencari) tim berdasarkan keyword
  /// [keyword]: Kata kunci pencarian
  /// Return: List tim yang sesuai dengan keyword
  List<Team> searchTeams(String keyword) {
    final lowerKeyword = keyword.toLowerCase();
    return _teams
        .where((team) => team.name.toLowerCase().contains(lowerKeyword))
        .toList();
  }
}
