import 'package:flutter/material.dart';
import '../models/match.dart';
import 'team_provider.dart';

class ScheduleProvider with ChangeNotifier {
  final TeamProvider _teamProvider;
  List<MatchModel> _matches = [];

  List<MatchModel> get matches => _matches;

  ScheduleProvider(this._teamProvider) {
    _teamProvider.addListener(_generateScheduleIfNeeded);
    _generateScheduleIfNeeded();
  }

  void _generateScheduleIfNeeded() {
    final teams = _teamProvider.teams;
    if (_matches.isNotEmpty) {
      notifyListeners();
      return;
    }
    if (teams.length < 2) {
      notifyListeners();
      return;
    }
    _generateRoundRobinSchedule(teams);
    notifyListeners();
  }

  void _generateRoundRobinSchedule(List<dynamic> teams) {
    _matches.clear();
    List<MatchModel> tempMatches = [];
    int matchId = 0;
    DateTime currentDate = DateTime.now().add(const Duration(days: 1));

    for (int i = 0; i < teams.length; i++) {
      for (int j = 0; j < teams.length; j++) {
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
          currentDate = currentDate.add(const Duration(days: 3));
        }
      }
    }
    _matches = tempMatches;
  }

  String _getWeekLabel(DateTime date) {
    int weekNumber = ((date.difference(DateTime.now()).inDays) ~/ 7) + 1;
    return 'Week $weekNumber';
  }

  List<MatchModel> getUpcomingMatches() {
    final upcoming = _matches.where((m) => m.status == 'scheduled').toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date));
    return upcoming;
  }

  List<MatchModel> getPlayedMatches() {
    final played = _matches.where((m) => m.status == 'finished').toList();
    played.sort((a, b) => b.date.compareTo(a.date));
    return played;
  }

  List<MatchModel> getMatchesByWeek(String week) {
    final weekMatches = _matches.where((m) => m.matchWeek == week).toList();
    weekMatches.sort((a, b) => a.date.compareTo(b.date));
    return weekMatches;
  }

  List<String> getAllWeeks() {
    Set<String> weeks = {};
    for (var match in _matches) {
      weeks.add(match.matchWeek);
    }
    List<String> sortedWeeks = weeks.toList();
    sortedWeeks.sort((a, b) {
      int aNum = int.parse(a.split(' ')[1]);
      int bNum = int.parse(b.split(' ')[1]);
      return aNum.compareTo(bNum);
    });
    return sortedWeeks;
  }

  void updateMatchResult(String matchId, int homeScore, int awayScore) {
    int index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      _matches[index] = _matches[index].copyWith(
        homeScore: homeScore,
        awayScore: awayScore,
        status: 'finished',
      );
      notifyListeners();
    }
  }

  MatchModel? getNextMatch() {
    final upcoming = getUpcomingMatches();
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  @override
  void dispose() {
    _teamProvider.removeListener(_generateScheduleIfNeeded);
    super.dispose();
  }
}