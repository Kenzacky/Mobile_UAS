import 'package:flutter/material.dart';
import '../models/match.dart';
import 'team_provider.dart';

/// Provider untuk mengelola Schedule (Jadwal Pertandingan)
/// Generate jadwal round-robin dan manage status pertandingan
class ScheduleProvider with ChangeNotifier {
  // Reference ke TeamProvider untuk mendapatkan data tim
  final TeamProvider _teamProvider;
  // Menyimpan list pertandingan yang dijadwalkan
  List<MatchModel> _matches = [];

  /// Getter untuk mengakses list jadwal pertandingan
  List<MatchModel> get matches => _matches;

  /// Getter untuk jumlah jadwal pertandingan
  int get matchCount => _matches.length;

  /// Constructor - setup listener dan generate jadwal awal
  ScheduleProvider(this._teamProvider) {
    _teamProvider.addListener(_generateScheduleIfNeeded);
    _generateScheduleIfNeeded();
  }

  /// Generate jadwal jika belum ada atau jika ada perubahan tim
  void _generateScheduleIfNeeded() {
    final teams = _teamProvider.teams;
    // Jika sudah ada jadwal, skip generate dan langsung notify
    if (_matches.isNotEmpty) {
      notifyListeners();
      return;
    }
    // Jika ada kurang dari 2 tim, tidak bisa generate jadwal
    if (teams.length < 2) {
      notifyListeners();
      return;
    }
    // Generate jadwal round-robin
    _generateRoundRobinSchedule(teams);
    notifyListeners();
  }

  /// Generate jadwal round-robin (setiap tim main dengan semua tim lain)
  /// [teams]: List tim yang akan di-schedule
  void _generateRoundRobinSchedule(List<dynamic> teams) {
    _matches.clear();
    List<MatchModel> tempMatches = [];
    int matchId = 0;
    // Mulai dari hari besok
    DateTime currentDate = DateTime.now().add(const Duration(days: 1));

    // Double round-robin: setiap tim bermain melawan setiap tim lain 2x
    for (int i = 0; i < teams.length; i++) {
      for (int j = 0; j < teams.length; j++) {
        // Jika tidak bermain melawan diri sendiri
        if (i != j) {
          tempMatches.add(
            MatchModel(
              id: 'match_${matchId++}',
              homeTeamId: teams[i].id,
              awayTeamId: teams[j].id,
              homeTeamName: teams[i].name,
              awayTeamName: teams[j].name,
              homeTeamLogo: teams[i].logoUrl,
              awayTeamLogo: teams[j].logoUrl,
              homeScore: 0,
              awayScore: 0,
              date: currentDate,
              status: 'scheduled',
              userId: '',
              createdAt: DateTime.now(),
              matchWeek: _getWeekLabel(currentDate),
            ),
          );
          // Jadwal pertandingan setiap 3 hari sekali
          currentDate = currentDate.add(const Duration(days: 3));
        }
      }
    }
    _matches = tempMatches;
  }

  /// Generate label minggu berdasarkan tanggal
  /// [date]: Tanggal pertandingan
  /// Return: String format "Week X"
  String _getWeekLabel(DateTime date) {
    int weekNumber = ((date.difference(DateTime.now()).inDays) ~/ 7) + 1;
    return 'Week $weekNumber';
  }

  /// Get (Dapatkan) pertandingan yang belum dimainkan
  /// Return: List pertandingan yang status-nya 'scheduled'
  List<MatchModel> getUpcomingMatches() {
    final upcoming = _matches.where((m) => m.status == 'scheduled').toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  /// Get (Dapatkan) pertandingan yang sudah dimainkan
  /// Return: List pertandingan yang status-nya 'finished'
  List<MatchModel> getPlayedMatches() {
    final played = _matches.where((m) => m.status == 'finished').toList();
    played.sort((a, b) => b.date.compareTo(a.date));
    return played;
  }

  /// Get (Dapatkan) pertandingan berdasarkan minggu
  /// [week]: Label minggu (contoh: 'Week 1')
  /// Return: List pertandingan di minggu tersebut
  List<MatchModel> getMatchesByWeek(String week) {
    final weekMatches = _matches.where((m) => m.matchWeek == week).toList();
    weekMatches.sort((a, b) => a.date.compareTo(b.date));
    return weekMatches;
  }

  /// Get daftar semua minggu yang ada jadwal pertandingan
  /// Return: List string minggu diurutkan dari minggu 1
  List<String> getAllWeeks() {
    Set<String> weeks = {};
    for (var match in _matches) {
      weeks.add(match.matchWeek);
    }
    List<String> sortedWeeks = weeks.toList();
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

  /// Update hasil pertandingan (set status menjadi selesai)
  /// [matchId]: ID pertandingan
  /// [homeScore]: Skor tim kandang
  /// [awayScore]: Skor tim tandang
  void updateMatchResult(String matchId, int homeScore, int awayScore) {
    int index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      final match = _matches[index];
      _matches[index] = match.copyWith(
        homeScore: homeScore,
        awayScore: awayScore,
        status: 'finished',
      );
      notifyListeners();
    }
  }

  /// Cleanup listeners saat provider di-dispose
  @override
  void dispose() {
    _teamProvider.removeListener(_generateScheduleIfNeeded);
    super.dispose();
  }
}
