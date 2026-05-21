import 'dart:math';
import '../models/team.dart';
import '../models/match.dart';
import '../models/standing.dart';

class SimulationResult {
  final String teamId;
  final String teamName;
  final double championshipPercent;
  final double relegationPercent;

  SimulationResult({
    required this.teamId,
    required this.teamName,
    required this.championshipPercent,
    required this.relegationPercent,
  });
}

class MonteCarloSimulation {
  final List<Team> teams;
  final List<MatchModel> playedMatches;
  final List<MatchModel> remainingMatches;
  static const int iterations = 1000;

  MonteCarloSimulation({
    required this.teams,
    required this.playedMatches,
    required this.remainingMatches,
  });

  Future<Map<String, SimulationResult>> run() async {
    Map<String, int> championshipWins = {};
    Map<String, int> relegationCounts = {};

    for (var team in teams) {
      championshipWins[team.id] = 0;
      relegationCounts[team.id] = 0;
    }

    final random = Random();

    for (int i = 0; i < iterations; i++) {
      Map<String, TeamStanding> simStats = {};
      for (var team in teams) {
        simStats[team.id] = TeamStanding(
          teamId: team.id,
          teamName: team.name,
          logoUrl: team.logoUrl,
        );
      }

      // Pertandingan yang sudah dimainkan
      for (var match in playedMatches) {
        final home = simStats[match.homeTeamId];
        final away = simStats[match.awayTeamId];
        if (home != null && away != null) {
          home.played++;
          away.played++;
          home.goalsFor += match.homeScore;
          home.goalsAgainst += match.awayScore;
          away.goalsFor += match.awayScore;
          away.goalsAgainst += match.homeScore;
          if (match.homeScore > match.awayScore) {
            home.won++;
            home.points += 3;
            away.lost++;
          } else if (match.homeScore < match.awayScore) {
            away.won++;
            away.points += 3;
            home.lost++;
          } else {
            home.draw++;
            home.points += 1;
            away.draw++;
            away.points += 1;
          }
        }
      }

      // Simulasi sisa pertandingan
      for (var match in remainingMatches) {
        final home = simStats[match.homeTeamId];
        final away = simStats[match.awayTeamId];
        if (home != null && away != null) {
          double rand = random.nextDouble();
          int homeScore, awayScore;
          if (rand < 0.4) {
            homeScore = 1 + random.nextInt(3);
            awayScore = random.nextInt(2);
          } else if (rand < 0.65) {
            homeScore = random.nextInt(2);
            awayScore = random.nextInt(2);
          } else {
            homeScore = random.nextInt(2);
            awayScore = 1 + random.nextInt(3);
          }
          home.played++;
          away.played++;
          home.goalsFor += homeScore;
          home.goalsAgainst += awayScore;
          away.goalsFor += awayScore;
          away.goalsAgainst += homeScore;
          if (homeScore > awayScore) {
            home.won++;
            home.points += 3;
            away.lost++;
          } else if (homeScore < awayScore) {
            away.won++;
            away.points += 3;
            home.lost++;
          } else {
            home.draw++;
            home.points += 1;
            away.draw++;
            away.points += 1;
          }
        }
      }

      List<TeamStanding> standings = simStats.values.toList();
      standings.sort((a, b) {
        if (a.points != b.points) return b.points.compareTo(a.points);
        if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
        return b.goalsFor.compareTo(a.goalsFor);
      });
      if (standings.isNotEmpty) {
        championshipWins[standings.first.teamId] =
            (championshipWins[standings.first.teamId] ?? 0) + 1;
        relegationCounts[standings.last.teamId] =
            (relegationCounts[standings.last.teamId] ?? 0) + 1;
      }
    }

    Map<String, SimulationResult> results = {};
    for (var team in teams) {
      results[team.id] = SimulationResult(
        teamId: team.id,
        teamName: team.name,
        championshipPercent: (championshipWins[team.id]! / iterations) * 100,
        relegationPercent: (relegationCounts[team.id]! / iterations) * 100,
      );
    }
    return results;
  }
}