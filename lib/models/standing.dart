/// Model untuk Standing (Klasemen)
/// Menyimpan statistik tim dalam klasemen (poin, kemenangan, dst)
class TeamStanding {
  // Identifikasi unik tim
  final String teamId;
  // Nama tim
  final String teamName;
  // URL logo tim
  final String? logoUrl;

  // Jumlah pertandingan yang sudah dimainkan
  int played = 0;
  // Jumlah kemenangan
  int won = 0;
  // Jumlah pertandingan seri
  int draw = 0;
  // Jumlah kekalahan
  int lost = 0;
  // Total gol yang dicetak
  int goalsFor = 0;
  // Total gol yang kemasukan
  int goalsAgainst = 0;
  // Total poin (kemenangan = 3 poin, seri = 1 poin)
  int points = 0;

  TeamStanding({
    required this.teamId,
    required this.teamName,
    this.logoUrl,
  });

  /// Getter untuk selisih gol (goal difference)
  /// Positif jika tim mencetak lebih banyak gol dari yang kemasukan
  int get goalDifference => goalsFor - goalsAgainst;

  /// Getter untuk menampilkan record tim (contoh: "12-3-1")
  String get record => '$won-$draw-$lost';

  /// Getter untuk win rate (persentase kemenangan)
  double get winRate {
    if (played == 0) return 0;
    return (won / played) * 100;
  }

  /// Getter untuk draw rate (persentase seri)
  double get drawRate {
    if (played == 0) return 0;
    return (draw / played) * 100;
  }

  /// Getter untuk loss rate (persentase kekalahan)
  double get lossRate {
    if (played == 0) return 0;
    return (lost / played) * 100;
  }

  /// Getter untuk rata-rata gol per pertandingan yang dicetak
  double get avgGoalsFor {
    if (played == 0) return 0;
    return goalsFor / played;
  }

  /// Getter untuk rata-rata gol per pertandingan yang kemasukan
  double get avgGoalsAgainst {
    if (played == 0) return 0;
    return goalsAgainst / played;
  }

  /// Mengubah TeamStanding menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'logoUrl': logoUrl,
      'played': played,
      'won': won,
      'draw': draw,
      'lost': lost,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'points': points,
    };
  }

  @override
  String toString() => 'Standing($teamName: $points pts, $record)';
}
