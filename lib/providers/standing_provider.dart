import 'package:flutter/material.dart';
import '../models/standing.dart';
import 'team_provider.dart';
import 'match_provider.dart';

/// Provider untuk mengelola Standing (Klasemen)
/// Menghitung poin, kemenangan, kekalahan berdasarkan data pertandingan
class StandingProvider with ChangeNotifier {
  // Reference ke TeamProvider untuk mendapatkan data tim
  final TeamProvider _teamProvider;
  // Reference ke MatchProvider untuk mendapatkan data pertandingan
  final MatchProvider _matchProvider;

  // Menyimpan klasemen yang sudah dihitung
  List<TeamStanding> _standings = [];

  /// Getter untuk mengakses klasemen dari UI
  List<TeamStanding> get standings => _standings;

  /// Getter untuk jumlah tim di klasemen
  int get teamCount => _standings.length;

  /// Constructor - setup listeners dan hitung klasemen awal
  StandingProvider(this._teamProvider, this._matchProvider) {
    // Listen ke perubahan data tim
    _teamProvider.addListener(_updateStandings);
    // Listen ke perubahan data pertandingan
    _matchProvider.addListener(_updateStandings);
    // Hitung klasemen awal
    _updateStandings();
  }

  /// Hitung ulang klasemen berdasarkan data tim dan pertandingan terbaru
  void _updateStandings() {
    // Map untuk menyimpan statistik setiap tim
    Map<String, TeamStanding> statsMap = {};

    // Inisialisasi klasemen untuk semua tim dengan 0 poin
    for (var team in _teamProvider.teams) {
      statsMap[team.id] = TeamStanding(
        teamId: team.id,
        teamName: team.name,
        logoUrl: team.logoUrl,
      );
    }

    // Process setiap pertandingan yang sudah selesai
    for (var match in _matchProvider.matches) {
      // Skip jika pertandingan belum dimainkan
      if (!match.isPlayed) continue;

      final homeStat = statsMap[match.homeTeamId];
      final awayStat = statsMap[match.awayTeamId];

      if (homeStat != null && awayStat != null) {
        // Update jumlah pertandingan yang dimainkan
        homeStat.played++;
        awayStat.played++;

        // Update gol yang dicetak dan kemasukan
        homeStat.goalsFor += match.homeScore;
        homeStat.goalsAgainst += match.awayScore;

        awayStat.goalsFor += match.awayScore;
        awayStat.goalsAgainst += match.homeScore;

        // Update hasil (menang/seri/kalah) dan poin
        if (match.homeScore > match.awayScore) {
          // Tim kandang menang
          homeStat.won++;
          homeStat.points += 3; // Menang = 3 poin
          awayStat.lost++;
        } else if (match.homeScore < match.awayScore) {
          // Tim tandang menang
          awayStat.won++;
          awayStat.points += 3;
          homeStat.lost++;
        } else {
          // Seri
          homeStat.draw++;
          homeStat.points += 1; // Seri = 1 poin
          awayStat.draw++;
          awayStat.points += 1;
        }
      }
    }

    // Konversi map menjadi list
    _standings = statsMap.values.toList();

    // Sort klasemen berdasarkan:
    // 1. Poin (terbanyak di atas)
    // 2. Goal difference (selisih gol terbesar di atas)
    // 3. Goals for (gol dicetak terbanyak di atas)
    _standings.sort((a, b) {
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      }
      if (a.goalDifference != b.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      return b.goalsFor.compareTo(a.goalsFor);
    });

    // Notify semua listener tentang perubahan klasemen
    notifyListeners();
  }

  /// Get (Cari) posisi tim dalam klasemen
  /// [teamId]: ID tim yang dicari
  /// Return: Nomor posisi (1-based) atau -1 jika tim tidak ditemukan
  int getTeamPosition(String teamId) {
    for (int i = 0; i < _standings.length; i++) {
      if (_standings[i].teamId == teamId) {
        return i + 1; // Position dimulai dari 1, bukan 0
      }
    }
    return -1;
  }

  /// Get (Cari) statistik tim dalam klasemen
  /// [teamId]: ID tim yang dicari
  /// Return: TeamStanding object atau null jika tidak ditemukan
  TeamStanding? getTeamStanding(String teamId) {
    try {
      return _standings.firstWhere((standing) => standing.teamId == teamId);
    } catch (e) {
      return null;
    }
  }

  /// Get tim dengan posisi teratas (juara sementara)
  /// Return: TeamStanding object atau null jika belum ada pertandingan
  TeamStanding? getLeaderTeam() {
    return _standings.isNotEmpty ? _standings.first : null;
  }

  /// Get tim-tim teratas (top N)
  /// [limit]: Jumlah tim yang ingin diambil (default: 3)
  /// Return: List TeamStanding dari top teams
  List<TeamStanding> getTopTeams({int limit = 3}) {
    return _standings.take(limit).toList();
  }

  /// Get tim-tim yang terancam degradasi
  /// [limit]: Jumlah tim dari bawah (default: 3)
  /// Return: List TeamStanding dari bottom teams
  List<TeamStanding> getBottomTeams({int limit = 3}) {
    if (_standings.length <= limit) return _standings;
    return _standings.sublist(_standings.length - limit);
  }

  /// Cleanup listeners saat provider di-dispose
  @override
  void dispose() {
    _teamProvider.removeListener(_updateStandings);
    _matchProvider.removeListener(_updateStandings);
    super.dispose();
  }
}
