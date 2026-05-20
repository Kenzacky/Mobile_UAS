import 'package:flutter/material.dart';
import '../models/match.dart';
import 'team_provider.dart';

class ScheduleProvider with ChangeNotifier {
  final TeamProvider _teamProvider;
  List<MatchModel> _schedule = [];

  List<MatchModel> get schedule => _schedule;

  ScheduleProvider(this._teamProvider) {
    _teamProvider.addListener(_generateSchedule);
    _generateSchedule();
  }

  /// Generate jadwal liga dengan sistem round-robin (setiap tim bertemu 2x)
  /// - Home & Away untuk setiap pertandingan
  /// - Setiap tim bertemu semua tim lain 2 kali
  void _generateSchedule() {
    final teams = _teamProvider.teams;
    if (teams.length < 2) {
      _schedule = [];
      notifyListeners();
      return;
    }

    List<MatchModel> newSchedule = [];
    int matchId = 0;

    // Generate round-robin schedule
    for (int round = 0; round < 2; round++) {
      for (int i = 0; i < teams.length; i++) {
        for (int j = 0; j < teams.length; j++) {
          if (i != j) {
            // Jika round 0: i adalah home, j adalah away
            // Jika round 1: reverse-nya
            final homeTeamId = round == 0 ? teams[i].id : teams[j].id;
            final awayTeamId = round == 0 ? teams[j].id : teams[i].id;

            // Hindari duplikat
            final isDuplicate = newSchedule.any((m) =>
                m.homeTeamId == homeTeamId && m.awayTeamId == awayTeamId);

            if (!isDuplicate) {
              final matchDate = DateTime.now().add(
                Duration(days: matchId * 3), // Setiap 3 hari
              );

              newSchedule.add(
                MatchModel(
                  id: 'schedule_${matchId++}',
                  homeTeamId: homeTeamId,
                  awayTeamId: awayTeamId,
                  homeScore: 0,
                  awayScore: 0,
                  date: matchDate,
                  isPlayed: false,
                ),
              );
            }
          }
        }
      }
    }

    // Sort by date
    newSchedule.sort((a, b) => a.date.compareTo(b.date));
    _schedule = newSchedule;
    notifyListeners();
  }

  /// Get upcoming matches (belum dimainkan)
  List<MatchModel> getUpcomingMatches() {
    return _schedule.where((m) => !m.isPlayed).toList();
  }

  /// Get played matches
  List<MatchModel> getPlayedMatches() {
    return _schedule.where((m) => m.isPlayed).toList();
  }

  /// Get next upcoming match
  MatchModel? getNextMatch() {
    final upcoming = getUpcomingMatches();
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  /// Update match result (set isPlayed: true dan skor)
  void updateMatchResult(String matchId, int homeScore, int awayScore) {
    final index = _schedule.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final match = _schedule[index];
      _schedule[index] = MatchModel(
        id: match.id,
        homeTeamId: match.homeTeamId,
        awayTeamId: match.awayTeamId,
        homeScore: homeScore,
        awayScore: awayScore,
        date: match.date,
        isPlayed: true,
      );
      notifyListeners();
    }
  }

  /// Get matches between two specific teams
  List<MatchModel> getHeadToHeadMatches(String team1Id, String team2Id) {
    return _schedule.where((m) =>
        (m.homeTeamId == team1Id && m.awayTeamId == team2Id) ||
        (m.homeTeamId == team2Id && m.awayTeamId == team1Id)).toList();
  }

  /// Check if two teams have already met in both directions
  bool haveTeamsMetTwice(String team1Id, String team2Id) {
    final matches = getHeadToHeadMatches(team1Id, team2Id);
    return matches.length >= 2;
  }

  @override
  void dispose() {
    _teamProvider.removeListener(_generateSchedule);
    super.dispose();
  }
}
