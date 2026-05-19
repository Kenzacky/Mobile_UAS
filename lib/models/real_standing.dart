class RealTeamStanding {
  final int position;
  final String teamName;
  final String teamCrest;
  final int playedGames;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  RealTeamStanding({
    required this.position,
    required this.teamName,
    required this.teamCrest,
    required this.playedGames,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  // Mengubah JSON dari API menjadi objek Dart
  factory RealTeamStanding.fromJson(Map<String, dynamic> json) {
    return RealTeamStanding(
      position: json['position'] ?? 0,
      teamName: json['team']['name'] ?? '',
      teamCrest: json['team']['crest'] ?? '',
      playedGames: json['playedGames'] ?? 0,
      won: json['won'] ?? 0,
      draw: json['draw'] ?? 0,
      lost: json['lost'] ?? 0,
      points: json['points'] ?? 0,
      goalsFor: json['goalsFor'] ?? 0,
      goalsAgainst: json['goalsAgainst'] ?? 0,
      goalDifference: (json['goalsFor'] ?? 0) - (json['goalsAgainst'] ?? 0),
    );
  }
}