import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';

/// Provider untuk mengelola Match (Pertandingan) Data
/// Menangani CRUD operation pertandingan dari Firestore
class MatchProvider with ChangeNotifier {
  // Reference ke collection 'matches' di Firestore
  final CollectionReference _matchesCollection =
  FirebaseFirestore.instance.collection('matches');

  // Menyimpan list pertandingan yang sedang di-load
  List<MatchModel> _matches = [];
  // Flag untuk loading state
  bool _isLoading = false;
  // Menyimpan error message jika ada
  String? _errorMessage;

  /// Getter untuk mengakses list semua pertandingan
  List<MatchModel> get matches => _matches;

  /// Getter untuk list pertandingan yang sudah selesai
  List<MatchModel> get playedMatches =>
      _matches.where((m) => m.isPlayed).toList();

  /// Getter untuk list pertandingan yang belum dimainkan
  List<MatchModel> get upcomingMatches =>
      _matches.where((m) => !m.isPlayed).toList();

  /// Getter untuk loading state
  bool get isLoading => _isLoading;

  /// Getter untuk error message
  String? get errorMessage => _errorMessage;

  /// Getter untuk jumlah pertandingan
  int get matchCount => _matches.length;

  /// Constructor - langsung fetch data pertandingan saat provider dibuat
  MatchProvider() {
    fetchMatches();
  }

  /// Fetch (Membaca) semua pertandingan dari Firestore
  /// Diurutkan berdasarkan tanggal terbaru
  /// Menggunakan real-time listener untuk auto-update
  void fetchMatches() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _matchesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        try {
          // Map setiap document menjadi MatchModel object
          _matches = snapshot.docs
              .map((doc) => MatchModel.fromFirestore(doc))
              .toList();

          _isLoading = false;
          _errorMessage = null;
          // Notify semua listener tentang perubahan data
          notifyListeners();
        } catch (e) {
          _isLoading = false;
          _errorMessage = 'Error loading matches: $e';
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

  /// Create (Membuat) pertandingan baru ke Firestore
  /// [match]: MatchModel object yang akan dibuat
  Future<void> addMatch(MatchModel match) async {
    try {
      // Simpan ke Firestore dan dapatkan document ID
      final docRef = await _matchesCollection.add(match.toMap());

      // Update local list dengan ID yang baru
      final newMatch = match.copyWith(id: docRef.id);
      _matches.add(newMatch);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error adding match: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update (Mengubah) data pertandingan di Firestore
  /// [match]: MatchModel object dengan data yang sudah diubah
  Future<void> updateMatch(MatchModel match) async {
    try {
      await _matchesCollection.doc(match.id).update(match.toMap());

      // Update di local list
      final index = _matches.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        _matches[index] = match;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating match: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete (Menghapus) pertandingan dari Firestore
  /// [id]: ID pertandingan yang akan dihapus
  Future<void> deleteMatch(String id) async {
    try {
      await _matchesCollection.doc(id).delete();
      _matches.removeWhere((m) => m.id == id);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error deleting match: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get (Mencari) pertandingan berdasarkan ID
  /// [id]: ID pertandingan yang dicari
  /// Return: MatchModel object atau null jika tidak ditemukan
  MatchModel? getMatchById(String id) {
    try {
      return _matches.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get (Mencari) pertandingan berdasarkan minggu
  /// [week]: Minggu pertandingan (contoh: 'Week 1')
  /// Return: List pertandingan yang diurutkan berdasarkan tanggal
  List<MatchModel> getMatchesByWeek(String week) {
    return _matches
        .where((match) => match.matchWeek == week)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get (Mencari) pertandingan yang melibatkan tim tertentu
  /// [teamId]: ID tim yang dicari
  /// Return: List pertandingan tim tersebut (home atau away)
  List<MatchModel> getTeamMatches(String teamId) {
    return _matches
        .where((match) =>
    match.homeTeamId == teamId || match.awayTeamId == teamId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get (Mencari) head-to-head history antara 2 tim
  /// [team1Id]: ID tim pertama
  /// [team2Id]: ID tim kedua
  /// Return: List pertandingan antara 2 tim tersebut
  List<MatchModel> getHeadToHead(String team1Id, String team2Id) {
    return _matches
        .where((match) =>
    (match.homeTeamId == team1Id && match.awayTeamId == team2Id) ||
        (match.homeTeamId == team2Id && match.awayTeamId == team1Id))
        .toList();
  }

  /// Get daftar semua minggu yang ada pertandingan
  /// Return: List string minggu (contoh: ['Week 1', 'Week 2', ...])
  List<String> getAllWeeks() {
    Set<String> weeks = {};
    for (var match in _matches) {
      weeks.add(match.matchWeek);
    }
    List<String> sortedWeeks = weeks.toList();
    // Urutkan berdasarkan nomor minggu
    sortedWeeks.sort((a, b) {
      try {
        int aNum = int.parse(a.split(' ')[1]);
        int bNum = int.parse(b.split(' ')[1]);
        return aNum.compareTo(bNum);
      } catch (e) {
        return a.compareTo(b);
      }
    });
    return sortedWeeks;
  }

  /// Get pertandingan dengan skor tertinggi
  /// Return: MatchModel dengan total gol terbanyak
  MatchModel? getHighestScoringMatch() {
    if (_matches.isEmpty) return null;
    return _matches.reduce((a, b) =>
    a.totalGoals > b.totalGoals ? a : b);
  }
}
