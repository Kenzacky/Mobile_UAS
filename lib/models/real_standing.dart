/// Model untuk Real Standing (Klasemen dari API)
/// Menyimpan data klasemen tim dari API football-data.org
class RealTeamStanding {
  // Posisi tim dalam klasemen
  final int position;
  // Nama tim
  final String teamName;
  // URL badge/logo tim
  final String teamBadgeUrl;
  // Jumlah pertandingan yang sudah dimainkan
  final int played;
  // Jumlah kemenangan
  final int won;
  // Jumlah pertandingan seri
  final int draw;
  // Jumlah kekalahan
  final int lost;
  // Total gol yang dicetak
  final int goalsFor;
  // Total gol yang kemasukan
  final int goalsAgainst;
  // Total poin
  final int points;

  RealTeamStanding({
    required this.position,
    required this.teamName,
    required this.teamBadgeUrl,
    required this.played,
    required this.won,
    required this.draw,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
  });

  /// Getter untuk selisih gol
  int get goalDifference => goalsFor - goalsAgainst;

  /// Getter untuk menampilkan record tim
  String get record => '$won-$draw-$lost';

  /// Konstruktor untuk membuat RealTeamStanding dari JSON API
  factory RealTeamStanding.fromJson(Map<String, dynamic> json) {
    return RealTeamStanding(
      position: json['position'] ?? 0,
      teamName: json['team']['name'] ?? '',
      teamBadgeUrl: json['team']['crest'] ?? '',
      played: json['playedGames'] ?? 0,
      won: json['won'] ?? 0,
      draw: json['draw'] ?? 0,
      lost: json['lost'] ?? 0,
      goalsFor: json['goalsFor'] ?? 0,
      goalsAgainst: json['goalsAgainst'] ?? 0,
      points: json['points'] ?? 0,
    );
  }

  /// Mengubah RealTeamStanding menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'teamName': teamName,
      'teamBadgeUrl': teamBadgeUrl,
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
  String toString() => 'Standing($position. $teamName - $points pts)';
}

/// Model untuk League Config (Konfigurasi Liga)
/// Menyimpan informasi tentang liga yang tersedia
class LeagueConfig {
  // Kode unik liga (contoh: 'PL' untuk Premier League)
  final String code;
  // Nama lengkap liga
  final String name;
  // Negara tempat liga berlangsung
  final String country;
  // Emoji atau simbol negara
  final String emoji;
  // Musim/tahun liga
  final int season;

  LeagueConfig({
    required this.code,
    required this.name,
    required this.country,
    required this.emoji,
    required this.season,
  });

  /// Menampilkan nama liga dengan format "Emoji - Nama"
  String get displayName => '$emoji $name';

  /// Menampilkan informasi lengkap liga
  String get fullName => '$emoji $name ($country)';

  @override
  String toString() => displayName;
}
