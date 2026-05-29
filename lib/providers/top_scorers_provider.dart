import 'package:flutter/material.dart';
import '../models/player.dart';
import 'match_provider.dart';

class TopScorersProvider with ChangeNotifier {
  final MatchProvider _matchProvider;
  List<Player> _topScorers = [];

  List<Player> get topScorers => _topScorers.toList();

  TopScorersProvider(this._matchProvider) {
    _matchProvider.addListener(_updateScorers);
    _updateScorers();
  }

  void _updateScorers() {
    Map<String, Player> playersMap = {};

    // Simulasi data: parse dari nama tim dan hitung goals
    for (var match in _matchProvider.matches) {
      if (!match.isPlayed) continue;

      // Home team goals
      for (int i = 0; i < match.homeScore; i++) {
        final playerId = '${match.homeTeamId}_goal_$i';
        if (!playersMap.containsKey(playerId)) {
          playersMap[playerId] = Player(
            id: playerId,
            name: 'Player ${i + 1}',
            teamId: match.homeTeamId,
            teamName: 'Home',
            goals: 1,
          );
        } else {
          playersMap[playerId]!.goals++;
        }
      }

      // Away team goals
      for (int i = 0; i < match.awayScore; i++) {
        final playerId = '${match.awayTeamId}_goal_$i';
        if (!playersMap.containsKey(playerId)) {
          playersMap[playerId] = Player(
            id: playerId,
            name: 'Player ${i + 1}',
            teamId: match.awayTeamId,
            teamName: 'Away',
            goals: 1,
          );
        } else {
          playersMap[playerId]!.goals++;
        }
      }
    }

    _topScorers = playersMap.values.toList();
    _topScorers.sort((a, b) => b.goals.compareTo(a.goals));
    notifyListeners();
  }

  @override
  void dispose() {
    _matchProvider.removeListener(_updateScorers);
    super.dispose();
  }
}
