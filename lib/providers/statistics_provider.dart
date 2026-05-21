import 'package:flutter/material.dart';
import 'match_provider.dart';
import 'team_provider.dart';

class StatisticsProvider with ChangeNotifier {
  final MatchProvider _matchProvider;
  final TeamProvider _teamProvider;

  late int _totalMatches;
  late int _totalGoals;
  late int _totalWins;
  late int _totalDraws;
  late int _totalLosses;
  late int _highestScoringMatch;
  late List<int> _goalDistribution;

  int get totalMatches => _totalMatches;
  int get totalGoals => _totalGoals;
  int get totalWins => _totalWins;
  int get totalDraws => _totalDraws;
  int get totalLosses => _totalLosses;
  int get highestScoringMatch => _highestScoringMatch;
  List<int> get goalDistribution => _goalDistribution;

  StatisticsProvider(this._matchProvider, this._teamProvider) {
    _matchProvider.addListener(_updateStatistics);
    _teamProvider.addListener(_updateStatistics);
    _updateStatistics();
  }

  void _updateStatistics() {
    _totalMatches = 0;
    _totalGoals = 0;
    _totalWins = 0;
    _totalDraws = 0;
    _totalLosses = 0;
    _highestScoringMatch = 0;
    _goalDistribution = [0, 0, 0, 0, 0]; // 0-1, 2-3, 4-5, 6-7, 8+

    for (var match in _matchProvider.matches) {
      if (!match.isPlayed) continue;

      _totalMatches++;
      int totalGoalsInMatch = match.homeScore + match.awayScore;
      _totalGoals += totalGoalsInMatch;

      // Track highest scoring match
      if (totalGoalsInMatch > _highestScoringMatch) {
        _highestScoringMatch = totalGoalsInMatch;
      }

      // Goal distribution
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

      // Win/Draw/Loss from perspective of teams
      if (match.homeScore > match.awayScore) {
        _totalWins++;
        _totalLosses++;
      } else if (match.homeScore < match.awayScore) {
        _totalLosses++;
        _totalWins++;
      } else {
        _totalDraws += 2;
      }
    }

    notifyListeners();
  }

  double get averageGoalsPerMatch {
    if (_totalMatches == 0) return 0;
    return _totalGoals / _totalMatches;
  }

  @override
  void dispose() {
    _matchProvider.removeListener(_updateStatistics);
    _teamProvider.removeListener(_updateStatistics);
    super.dispose();
  }
}
