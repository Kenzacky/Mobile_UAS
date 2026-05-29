class MatchEvent {
  final String id;
  final String type;
  final String playerName;
  final String teamId;
  final int minute;
  final String? description;

  MatchEvent({
    required this.id,
    required this.type,
    required this.playerName,
    required this.teamId,
    required this.minute,
    this.description,
  });

  String get emoji {
    switch (type) {
      case 'goal':
        return '⚽';
      case 'yellowCard':
        return '🟨';
      case 'redCard':
        return '🔴';
      case 'substitution':
        return '🔄';
      default:
        return '📝';
    }
  }
}
