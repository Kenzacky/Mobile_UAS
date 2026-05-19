class Player {
  final String id;
  final String name;
  final String teamId;
  final String teamName;
  int goals;

  Player({
    required this.id,
    required this.name,
    required this.teamId,
    required this.teamName,
    this.goals = 0,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
