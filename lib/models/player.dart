/// Model untuk Player (Pemain)
/// Menyimpan informasi pemain dan statistik golnya
class Player {
  // Identifikasi unik pemain
  final String id;
  // Nama pemain
  final String name;
  // ID tim pemain
  final String teamId;
  // Nama tim pemain
  final String teamName;
  // Jumlah gol yang sudah dicetak
  int goals;

  Player({
    required this.id,
    required this.name,
    required this.teamId,
    required this.teamName,
    this.goals = 0,
  });

  /// Mengubah Player menjadi Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teamId': teamId,
      'teamName': teamName,
      'goals': goals,
    };
  }

  /// Konstruktor untuk membuat Player dari Map
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      teamId: map['teamId'] ?? '',
      teamName: map['teamName'] ?? '',
      goals: map['goals'] ?? 0,
    );
  }

  /// Membuat copy dari Player dengan beberapa field yang bisa diubah
  Player copyWith({
    String? id,
    String? name,
    String? teamId,
    String? teamName,
    int? goals,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      goals: goals ?? this.goals,
    );
  }

  @override
  String toString() => 'Player($name: $goals goals)';
}
