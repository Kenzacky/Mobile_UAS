class TeamStanding {
  final String teamId;
  final String teamName;
  final String? logoUrl;
  int played = 0;
  int won = 0;
  int draw = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;

  TeamStanding({
    required this.teamId,
    required this.teamName,
    this.logoUrl,
  });

  int get goalDifference => goalsFor - goalsAgainst;
}