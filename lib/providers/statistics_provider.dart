import 'package:flutter/material.dart';
import 'match_provider.dart';
import 'team_provider.dart';

/// Provider untuk mengelola Statistics (Statistik Pertandingan)
/// Menghitung berbagai statistik berdasarkan data pertandingan
class StatisticsProvider with ChangeNotifier {
  // Reference ke MatchProvider untuk data pertandingan
  final MatchProvider _matchProvider;
  // Reference ke TeamProvider untuk data tim
  final TeamProvider _teamProvider;

  // Total pertandingan yang sudah selesai
  late int _totalMatches;
  // Total gol di semua pertandingan
  late int _totalGoals;
  // Total kemenangan (dari perspektif semua tim)
  late int _totalWins;
  // Total hasil seri
  late int _totalDraws;
  // Total kekalahan (dari perspektif semua tim)
  late int _totalLosses;
  // Skor tertinggi dalam satu pertandingan
  late int _highestScoringMatch;
  // Distribusi gol: [0-1, 2-3, 4-5, 6-7, 8+]
  late List<int> _goalDistribution;

  /// Getter untuk total pertandingan
  int get totalMatches => _totalMatches;
  /// Getter untuk total gol
  int get totalGoals => _totalGoals;
  /// Getter untuk total kemenangan
  int get totalWins => _totalWins;
  /// Getter untuk total seri
  int get totalDraws => _totalDraws;
  /// Getter untuk total kekalahan
  int get totalLosses => _totalLosses;
  /// Getter untuk skor tertinggi
  int get highestScoringMatch => _highestScoringMatch;
  /// Getter untuk distribusi gol
  List<int> get goalDistribution => _goalDistribution;

  /// Constructor - setup listeners dan hitung statistik awal
  StatisticsProvider(this._matchProvider, this._teamProvider) {
    _matchProvider.addListener(_updateStatistics);
    _teamProvider.addListener(_updateStatistics);
    _updateStatistics();
  }

  /// Hitung ulang statistik berdasarkan data pertandingan terbaru
  void _updateStatistics() {
    // Reset semua statistik
    _totalMatches = 0;
    _totalGoals = 0;
    _totalWins = 0;
    _totalDraws = 0;
    _totalLosses = 0;
    _highestScoringMatch = 0;
    // Distribusi gol: 0-1 gol, 2-3 gol, 4-5 gol, 6-7 gol, 8+ gol
    _goalDistribution = [0, 0, 0, 0, 0];

    // Process setiap pertandingan yang sudah selesai
    for (var match in _matchProvider.matches) {
      // Skip jika pertandingan belum dimainkan
      if (!match.isPlayed) continue;

      _totalMatches++;
      int totalGoalsInMatch = match.homeScore + match.awayScore;
      _totalGoals += totalGoalsInMatch;

      // Track skor tertinggi dalam satu pertandingan
      if (totalGoalsInMatch > _highestScoringMatch) {
        _highestScoringMatch = totalGoalsInMatch;
      }

      // Hitung distribusi gol
      if (totalGoalsInMatch <= 1) {
        _goalDistribution[0]++;
      } else if (totalGoalsInMatch <= 3) {
        _goalDistribution[1]++;
      } else if (totalGoalsInMatch <= 5) {
        _goalDistribution[2]++;
      } else if (totalGoalsInMatch <= 7) {
        _goalDistribution[3]++;
      } else {
        _goalDistribution[4]++;
      }

      // Hitung menang/seri/kalah (dari perspektif semua pertandingan)
      if (match.homeScore > match.awayScore) {
        _totalWins++; // Tim kandang menang
        _totalLosses++; // Tim tandang kalah
      } else if (match.homeScore < match.awayScore) {
        _totalLosses++; // Tim kandang kalah
        _totalWins++; // Tim tandang menang
      } else {
        // Seri
        _totalDraws += 2; // Dua tim sama-sama seri
      }
    }

    notifyListeners();
  }

  /// Getter untuk rata-rata gol per pertandingan
  double get averageGoalsPerMatch {
    if (_totalMatches == 0) return 0;
    return _totalGoals / _totalMatches;
  }

  /// Getter untuk persentase pertandingan dengan hasil seri
  double get drawPercentage {
    if (_totalMatches == 0) return 0;
    return ((_totalDraws / 2) / _totalMatches) * 100;
  }

  /// Getter untuk persentase pertandingan dengan hasil menang
  double get winPercentage {
    if (_totalMatches == 0) return 0;
    return (_totalWins / _totalMatches) * 100;
  }

  /// Getter untuk jumlah pertandingan dengan banyak gol (4+)
  int get highScoringMatches {
    return _goalDistribution[2] + _goalDistribution[3] + _goalDistribution[4];
  }

  /// Getter untuk jumlah pertandingan dengan sedikit gol (0-1)
  int get lowScoringMatches => _goalDistribution[0];

  /// Cleanup listeners saat provider di-dispose
  @override
  void dispose() {
    _matchProvider.removeListener(_updateStatistics);
    _teamProvider.removeListener(_updateStatistics);
    super.dispose();
  }
}
