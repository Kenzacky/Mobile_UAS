import 'package:flutter/material.dart';
import '../models/standing.dart';
import 'team_provider.dart';
import 'match_provider.dart';

class StandingProvider with ChangeNotifier {
  final TeamProvider _teamProvider;
  final MatchProvider _matchProvider;

  List<TeamStanding> _standings = [];
  List<TeamStanding> get standings => _standings;

  StandingProvider(this._teamProvider, this._matchProvider) {
    _teamProvider.addListener(_updateStandings);
    _matchProvider.addListener(_updateStandings);
    _updateStandings();
  }

  void _updateStandings() {
    Map<String, TeamStanding> statsMap = {};

    for (var team in _teamProvider.teams) {
      statsMap[team.id] = TeamStanding(
        teamId: team.id,
        teamName: team.name,
        logoUrl: team.logoUrl,
      );
    }

    for (var match in _matchProvider.matches) {
      if (!match.isPlayed) continue;

      final homeStat = statsMap[match.homeTeamId];
      final awayStat = statsMap[match.awayTeamId];

      // Perbaikan: tambahkan kurung kurawal
      if (homeStat != null && awayStat != null) {
        homeStat.played++;
        homeStat.goalsFor += match.homeScore;
        homeStat.goalsAgainst += match.awayScore;

        awayStat.played++;
        awayStat.goalsFor += match.awayScore;
        awayStat.goalsAgainst += match.homeScore;

        if (match.homeScore > match.awayScore) {
          homeStat.won++;
          homeStat.points += 3;
          awayStat.lost++;
        } else if (match.homeScore < match.awayScore) {
          awayStat.won++;
          awayStat.points += 3;
          homeStat.lost++;
        } else {
          homeStat.draw++;
          homeStat.points += 1;
          awayStat.draw++;
          awayStat.points += 1;
        }
      }
    }

    _standings = statsMap.values.toList();
    _standings.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
      return b.goalsFor.compareTo(a.goalsFor);
    });

    notifyListeners();
  }
}