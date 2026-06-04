import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/league_season.dart';

/// Provider untuk manage season/musim liga
class SeasonProvider with ChangeNotifier {
  List<LeagueSeason> _seasons = [];
  LeagueSeason? _currentSeason;

  List<LeagueSeason> get seasons => _seasons;
  LeagueSeason? get currentSeason => _currentSeason;

  // Getter untuk info season saat ini
  bool get hasActiveSeason => _currentSeason != null && !_currentSeason!.isCompleted;
  bool get isSeasonCompleted => _currentSeason?.isCompleted ?? false;

  /// Create new season
  Future<void> createNewSeason({
    required String seasonName,
    required int seasonYear,
  }) async {
    try {
      final newSeason = LeagueSeason(
        id: 'season_${DateTime.now().millisecondsSinceEpoch}',
        seasonName: seasonName,
        seasonYear: seasonYear,
        startDate: DateTime.now(),
        status: 'active',
      );

      _seasons.add(newSeason);
      _currentSeason = newSeason;
      notifyListeners();
    } catch (e) {
      throw Exception('Error create season: $e');
    }
  }

  /// Complete current season dengan winner
  Future<void> completeCurrentSeason({
    required String winnerId,
    required String winnerName,
    required Map<String, dynamic> statistics,
  }) async {
    try {
      if (_currentSeason == null) {
        throw Exception('No active season');
      }

      final completedSeason = _currentSeason!.copyWith(
        status: 'completed',
        endDate: DateTime.now(),
        winnerId: winnerId,
        winnerName: winnerName,
        statistics: statistics,
      );

      final index = _seasons.indexWhere((s) => s.id == _currentSeason!.id);
      if (index != -1) {
        _seasons[index] = completedSeason;
      }

      _currentSeason = completedSeason;
      notifyListeners();
    } catch (e) {
      throw Exception('Error complete season: $e');
    }
  }

  /// Get season by ID
  LeagueSeason? getSeasonById(String seasonId) {
    try {
      return _seasons.firstWhere((s) => s.id == seasonId);
    } catch (e) {
      return null;
    }
  }

  /// Get semua season yang selesai
  List<LeagueSeason> getCompletedSeasons() {
    return _seasons.where((s) => s.isCompleted).toList();
  }

  /// Get semua season yang aktif
  List<LeagueSeason> getActiveSeasons() {
    return _seasons.where((s) => !s.isCompleted).toList();
  }

  /// Archive season
  Future<void> archiveSeason(String seasonId) async {
    try {
      final index = _seasons.indexWhere((s) => s.id == seasonId);
      if (index != -1) {
        final archivedSeason = _seasons[index].copyWith(status: 'archived');
        _seasons[index] = archivedSeason;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error archive season: $e');
    }
  }

  /// Switch ke season lain
  void switchToSeason(String seasonId) {
    _currentSeason = getSeasonById(seasonId);
    notifyListeners();
  }

  /// Get statistics keseluruhan dari season
  Map<String, dynamic> getSeasonStatistics(String seasonId) {
    final season = getSeasonById(seasonId);
    return season?.statistics ?? {};
  }

  /// Reset klasemen untuk season baru (tanpa reset jadwal)
  void resetClassementForNewSeason() {
    // Klasemen akan direset otomatis saat matches baru ditambahkan
    // Provider standing akan otomatis update
    notifyListeners();
  }
}
