import 'dart:math';
import '../models/team.dart';
import '../models/match.dart';
import '../models/standing.dart';

/// Model untuk menyimpan hasil simulasi
class SimulationResult {
  // ID tim
  final String teamId;
  // Nama tim
  final String teamName;
  // Persentase peluang menjadi juara
  final double championshipPercent;
  // Persentase peluang degradasi
  final double relegationPercent;

  SimulationResult({
    required this.teamId,
    required this.teamName,
    required this.championshipPercent,
    required this.relegationPercent,
  });

  @override
  String toString() =>
      '$teamName: ${championshipPercent.toStringAsFixed(1)}% juara, ${relegationPercent.toStringAsFixed(1)}% degradasi';
}

/// Service untuk simulasi Monte Carlo
/// Memprediksi peluang tim menjadi juara atau degradasi
class MonteCarloSimulation {
  // List tim yang akan disimulasikan
  final List<Team> teams;
  // Pertandingan yang sudah dimainkan
  final List<MatchModel> playedMatches;
  // Pertandingan yang belum dimainkan
  final List<MatchModel> remainingMatches;
  // Jumlah iterasi simulasi (semakin banyak = lebih akurat)
  static const int iterations = 1000;

  MonteCarloSimulation({
    required this.teams,
    required this.playedMatches,
    required this.remainingMatches,
  });

  /// Jalankan simulasi Monte Carlo
  /// Return: Map berisi SimulationResult untuk setiap tim
  Future<Map<String, SimulationResult>> run() async {
    // Map untuk menghitung berapa kali tim menjadi juara
    Map<String, int> championshipWins = {};
    // Map untuk menghitung berapa kali tim degradasi
    Map<String, int> relegationCounts = {};

    // Inisialisasi counter untuk setiap tim
    for (var team in teams) {
      championshipWins[team.id] = 0;
      relegationCounts[team.id] = 0;
    }

    // Random number generator
    final random = Random();

    // Jalankan simulasi sebanyak iterations kali
    for (int i = 0; i < iterations; i++) {
      // Map untuk statistik setiap tim dalam 1 simulasi
      Map<String, TeamStanding> simStats = {};

      // Inisialisasi statistik tim untuk simulasi ini
      for (var team in teams) {
        simStats[team.id] = TeamStanding(
          teamId: team.id,
          teamName: team.name,
          logoUrl: team.logoUrl,
        );
      }

      // Process pertandingan yang sudah dimainkan
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

      // Simulasi pertandingan yang belum dimainkan
      for (var match in remainingMatches) {
        final home = simStats[match.homeTeamId];
        final away = simStats[match.awayTeamId];
        if (home != null && away != null) {
          // Random hasil pertandingan berdasarkan probabilitas
          double rand = random.nextDouble();
          int homeScore, awayScore;

          // 40% peluang tim kandang menang dengan skor 1-2 gol
          if (rand < 0.4) {
            homeScore = 1 + random.nextInt(3);
            awayScore = random.nextInt(2);
          }
          // 25% peluang hasil seri
          else if (rand < 0.65) {
            homeScore = random.nextInt(2);
            awayScore = random.nextInt(2);
          }
          // 35% peluang tim tandang menang dengan skor 1-2 gol
          else {
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

      // Sort klasemen simulasi ini
      final standings = simStats.values.toList();
      standings.sort((a, b) {
        if (a.points != b.points) {
          return b.points.compareTo(a.points);
        }
        if (a.goalDifference != b.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        return b.goalsFor.compareTo(a.goalsFor);
      });

      // Check tim yang menjadi juara (posisi 1)
      if (standings.isNotEmpty) {
        championshipWins[standings[0].teamId] =
            (championshipWins[standings[0].teamId] ?? 0) + 1;
      }

      // Check tim yang degradasi (posisi terakhir)
      // Asumsikan 3-4 tim terakhir yang degradasi tergantung jumlah tim
      int relegationSpots = (teams.length / 8).ceil();
      for (int j = 0; j < relegationSpots && j < standings.length; j++) {
        relegationCounts[standings[standings.length - 1 - j].teamId] =
            (relegationCounts[standings[standings.length - 1 - j].teamId] ?? 0) +
                1;
      }
    }

    // Hitung persentase dan buat result
    Map<String, SimulationResult> results = {};
    for (var team in teams) {
      final champWins = championshipWins[team.id] ?? 0;
      final relegations = relegationCounts[team.id] ?? 0;

      results[team.id] = SimulationResult(
        teamId: team.id,
        teamName: team.name,
        championshipPercent: (champWins / iterations) * 100,
        relegationPercent: (relegations / iterations) * 100,
      );
    }

    return results;
  }
}
