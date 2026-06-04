import 'dart:math';
import '../models/match.dart';
import '../models/team.dart';

/// Service untuk generate jadwal pertandingan liga
/// dengan aturan: setiap tim bertemu tim lain maksimal 2 kali
class ScheduleGeneratorService {
  /// Generate jadwal liga dengan aturan round-robin
  /// Setiap tim bertemu tim lain maksimal 2x (home & away)
  static List<MatchModel> generateSchedule({
    required List<Team> teams,
    required String userId,
    int matchesPerWeek = 10,
  }) {
    if (teams.length < 2) {
      throw Exception('Minimal 2 tim diperlukan untuk generate jadwal');
    }

    List<MatchModel> matches = [];
    Set<String> addedMatches = {}; // Tracking matches yang sudah ditambah
    int matchId = 0;
    int weekCounter = 1;
    int matchesInCurrentWeek = 0;

    // Shuffle untuk randomize jadwal
    final shuffledTeams = List<Team>.from(teams)..shuffle();

    // Generate round 1: Semua tim main di kandang (home)
    for (int i = 0; i < shuffledTeams.length; i++) {
      for (int j = 0; j < shuffledTeams.length; j++) {
        if (i == j) continue; // Tim tidak bertemu diri sendiri

        String matchKey = _createMatchKey(
          shuffledTeams[i].id,
          shuffledTeams[j].id,
          isHome: true,
        );

        if (addedMatches.contains(matchKey)) continue;

        final match = MatchModel(
          id: 'match_${matchId++}',
          homeTeamId: shuffledTeams[i].id,
          awayTeamId: shuffledTeams[j].id,
          homeTeamName: shuffledTeams[i].name,
          awayTeamName: shuffledTeams[j].name,
          homeTeamLogo: shuffledTeams[i].logoUrl,
          awayTeamLogo: shuffledTeams[j].logoUrl,
          homeScore: 0,
          awayScore: 0,
          date: _calculateMatchDate(weekCounter),
          status: 'scheduled',
          userId: userId,
          createdAt: DateTime.now(),
          matchWeek: 'Week $weekCounter',
        );

        matches.add(match);
        addedMatches.add(matchKey);
        matchesInCurrentWeek++;

        // Update minggu jika sudah mencapai batas matches per minggu
        if (matchesInCurrentWeek >= matchesPerWeek) {
          weekCounter++;
          matchesInCurrentWeek = 0;
        }
      }
    }

    // Validasi jadwal
    if (!validateSchedule(matches)) {
      throw Exception('Jadwal tidak valid: ada tim yang bertemu >2x');
    }

    return matches;
  }

  /// Generate jadwal dengan round-robin advanced (berimbang)
  /// Menggunakan algoritma berimbang agar distribusi tim di setiap minggu adil
  static List<MatchModel> generateBalancedSchedule({
    required List<Team> teams,
    required String userId,
  }) {
    if (teams.length < 2) {
      throw Exception('Minimal 2 tim diperlukan untuk generate jadwal');
    }

    List<MatchModel> matches = [];
    int matchId = 0;
    int weekCounter = 1;

    // Validasi: jumlah tim harus genap untuk round-robin yang sempurna
    final teamList = teams.length.isEven ? teams : teams + [Team(
      id: 'bye',
      name: 'BYE',
      logoUrl: '',
    )];

    // Generate round 1 (home matches)
    _generateRound(
      matches: matches,
      teams: teamList,
      userId: userId,
      weekCounter: weekCounter,
      matchId: matchId,
      round: 1,
    );

    // Hitung week setelah round 1
    weekCounter = ((matches.length) ~/ (teamList.length ~/ 2)) + 1;

    // Generate round 2 (away matches)
    _generateRound(
      matches: matches,
      teams: teamList,
      userId: userId,
      weekCounter: weekCounter,
      matchId: matches.length,
      round: 2,
    );

    // Hapus matches dengan BYE team jika ada
    matches.removeWhere((m) => m.homeTeamId == 'bye' || m.awayTeamId == 'bye');

    // Validasi jadwal final
    if (!validateSchedule(matches)) {
      throw Exception('Jadwal tidak valid: ada tim yang bertemu >2x');
    }

    return matches;
  }

  /// Helper method untuk generate satu round
  static void _generateRound({
    required List<MatchModel> matches,
    required List<Team> teams,
    required String userId,
    required int weekCounter,
    required int matchId,
    required int round,
  }) {
    final n = teams.length;
    const int matchesPerWeek = 10;
    int weekMatchCount = 0;
    int currentWeek = weekCounter;

    // Algoritma bergeser (shift algorithm) untuk round-robin
    List<int> indices = List.generate(n, (i) => i);

    for (int week = 0; week < n - 1; week++) {
      // Generate matches untuk minggu ini
      for (int i = 0; i < n ~/ 2; i++) {
        int homeIdx = indices[i];
        int awayIdx = indices[n - 1 - i];

        // Skip jika salah satu adalah BYE
        if (teams[homeIdx].id == 'bye' || teams[awayIdx].id == 'bye') {
          continue;
        }

        final match = MatchModel(
          id: 'match_${matchId++}',
          homeTeamId: teams[homeIdx].id,
          awayTeamId: teams[awayIdx].id,
          homeTeamName: teams[homeIdx].name,
          awayTeamName: teams[awayIdx].name,
          homeTeamLogo: teams[homeIdx].logoUrl,
          awayTeamLogo: teams[awayIdx].logoUrl,
          homeScore: 0,
          awayScore: 0,
          date: _calculateMatchDate(currentWeek),
          status: 'scheduled',
          userId: userId,
          createdAt: DateTime.now(),
          matchWeek: 'Week $currentWeek Round $round',
        );

        matches.add(match);
        weekMatchCount++;

        // Update minggu jika sudah mencapai batas
        if (weekMatchCount >= matchesPerWeek) {
          currentWeek++;
          weekMatchCount = 0;
        }
      }

      // Shift indices untuk minggu berikutnya
      indices = _shiftIndices(indices);
    }
  }

  /// Shift indices untuk algoritma round-robin
  static List<int> _shiftIndices(List<int> indices) {
    final n = indices.length;
    final lastIdx = indices[n - 1];
    final shiftedIndices = List<int>.from(indices);

    for (int i = n - 1; i > 0; i--) {
      shiftedIndices[i] = shiftedIndices[i - 1];
    }
    shiftedIndices[0] = lastIdx;

    return shiftedIndices;
  }

  /// Buat key unik untuk match (sensitif terhadap home/away)
  static String _createMatchKey(
      String teamId1,
      String teamId2, {
        required bool isHome,
      }) {
    if (isHome) {
      return '${teamId1}_h_vs_${teamId2}_a';
    } else {
      return '${teamId1}_a_vs_${teamId2}_h';
    }
  }

  /// Buat key untuk pasangan tim (order-independent)
  static String _createTeamPairKey(String teamId1, String teamId2) {
    final ids = [teamId1, teamId2]..sort();
    return '${ids[0]}_vs_${ids[1]}';
  }

  /// Hitung tanggal match berdasarkan minggu
  static DateTime _calculateMatchDate(int week) {
    final now = DateTime.now();
    final daysFromNow = (week - 1) * 7; // Setiap minggu = 7 hari
    return now.add(Duration(days: daysFromNow)).add(
      Duration(hours: (Random().nextInt(6) + 14)), // Jam 14:00-20:00
    );
  }

  /// Validasi jadwal: pastikan setiap pasangan tim bertemu maksimal 2x
  static bool validateSchedule(List<MatchModel> matches) {
    Map<String, int> meetingCount = {};

    for (var match in matches) {
      String key = _createTeamPairKey(match.homeTeamId, match.awayTeamId);
      meetingCount[key] = (meetingCount[key] ?? 0) + 1;

      // Jika ada pasangan yang bertemu lebih dari 2x, return false
      if (meetingCount[key]! > 2) {
        return false;
      }
    }

    return true;
  }

  /// Get statistik pertemuan antar tim
  static Map<String, int> getMeetingStats(List<MatchModel> matches) {
    Map<String, int> stats = {};

    for (var match in matches) {
      String key = _createTeamPairKey(match.homeTeamId, match.awayTeamId);
      stats[key] = (stats[key] ?? 0) + 1;
    }

    return stats;
  }

  /// Get detail pertemuan antar dua tim
  static List<MatchModel> getHeadToHeadMatches(
      List<MatchModel> matches,
      String teamId1,
      String teamId2,
      ) {
    return matches
        .where((m) =>
    (m.homeTeamId == teamId1 && m.awayTeamId == teamId2) ||
        (m.homeTeamId == teamId2 && m.awayTeamId == teamId1))
        .toList();
  }

  /// Hitung total jadwal (total matches)
  static int calculateTotalMatches(int teamCount) {
    // Untuk setiap pasangan: 2 matches (home + away)
    // Total = n * (n-1)
    return teamCount * (teamCount - 1);
  }

  /// Hitung total minggu yang diperlukan
  static int calculateTotalWeeks(int teamCount, {int matchesPerWeek = 10}) {
    final totalMatches = calculateTotalMatches(teamCount);
    return (totalMatches / matchesPerWeek).ceil();
  }

  /// Get statistik jadwal
  static Map<String, dynamic> getScheduleStats(
      List<MatchModel> matches,
      List<Team> teams,
      ) {
    final stats = {
      'totalMatches': matches.length,
      'totalTeams': teams.length,
      'totalWeeks': _getWeekCount(matches),
      'matchesByWeek': _getMatchesPerWeek(matches),
      'teamMeetings': getMeetingStats(matches),
    };

    return stats;
  }

  /// Get jumlah minggu unik dalam jadwal
  static int _getWeekCount(List<MatchModel> matches) {
    final weeks = matches.map((m) => m.matchWeek).toSet();
    return weeks.length;
  }

  /// Get jumlah matches per minggu
  static Map<String, int> _getMatchesPerWeek(List<MatchModel> matches) {
    final byWeek = <String, int>{};

    for (var match in matches) {
      final week = match.matchWeek;
      byWeek[week] = (byWeek[week] ?? 0) + 1;
    }

    return byWeek;
  }

  /// Export jadwal ke format CSV
  static String exportScheduleToCSV(List<MatchModel> matches) {
    StringBuffer csv = StringBuffer();

    // Header
    csv.writeln(
      'Match ID,Week,Date,Home Team,Away Team,Status,Home Score,Away Score',
    );

    // Data
    for (var match in matches) {
      csv.writeln(
        '${match.id},'
            '${match.matchWeek},'
            '${match.date.toIso8601String()},'
            '${match.homeTeamName},'
            '${match.awayTeamName},'
            '${match.status},'
            '${match.homeScore},'
            '${match.awayScore}',
      );
    }

    return csv.toString();
  }

  /// Get jadwal harian
  static Map<DateTime, List<MatchModel>> getScheduleByDate(
      List<MatchModel> matches,
      ) {
    final byDate = <DateTime, List<MatchModel>>{};

    for (var match in matches) {
      final dateOnly = DateTime(match.date.year, match.date.month, match.date.day);
      if (!byDate.containsKey(dateOnly)) {
        byDate[dateOnly] = [];
      }
      byDate[dateOnly]!.add(match);
    }

    return byDate;
  }

  /// Reorder jadwal dengan algoritma balanced scheduling
  static List<MatchModel> reorderScheduleBalanced(
      List<MatchModel> matches,
      ) {
    final byWeek = <String, List<MatchModel>>{};

    // Group by week
    for (var match in matches) {
      final week = match.matchWeek;
      if (!byWeek.containsKey(week)) {
        byWeek[week] = [];
      }
      byWeek[week]!.add(match);
    }

    // Reorder matches dalam setiap minggu
    final reordered = <MatchModel>[];
    for (var weekMatches in byWeek.values) {
      weekMatches.shuffle();
      reordered.addAll(weekMatches);
    }

    return reordered;
  }
}
