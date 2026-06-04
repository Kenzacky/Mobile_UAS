import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Match (Pertandingan)
/// Menyimpan informasi lengkap tentang satu pertandingan
class MatchModel {
  // Identifikasi unik pertandingan
  final String id;
  // ID tim kandang
  final String homeTeamId;
  // ID tim tandang
  final String awayTeamId;
  // Nama tim kandang
  final String homeTeamName;
  // Nama tim tandang
  final String awayTeamName;
  // URL logo tim kandang
  final String? homeTeamLogo;
  // URL logo tim tandang
  final String? awayTeamLogo;
  // Skor tim kandang
  final int homeScore;
  // Skor tim tandang
  final int awayScore;
  // Tanggal dan waktu pertandingan
  final DateTime date;
  // Status pertandingan: 'scheduled' (dijadwalkan) atau 'finished' (selesai)
  final String status;
  // ID user yang membuat pertandingan
  final String userId;
  // Waktu pertandingan dibuat
  final DateTime createdAt;
  // Minggu pertandingan (contoh: 'Week 1')
  final String matchWeek;

  MatchModel({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamLogo,
    this.awayTeamLogo,
    required this.homeScore,
    required this.awayScore,
    required this.date,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.matchWeek,
  });

  /// Getter untuk mengecek apakah pertandingan sudah dimainkan
  /// Return true jika status adalah 'finished'
  bool get isPlayed => status == 'finished';

  /// Getter untuk nama pemenang
  /// Return string nama tim pemenang atau 'Draw' jika seri
  String get winner {
    if (homeScore > awayScore) return homeTeamName;
    if (awayScore > homeScore) return awayTeamName;
    return 'Draw';
  }

  /// Getter untuk total gol dalam pertandingan
  int get totalGoals => homeScore + awayScore;

  /// Getter untuk format waktu pertandingan yang user-friendly
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Konstruktor untuk membuat MatchModel dari Firestore document
  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      homeTeamId: data['homeTeamId'] ?? '',
      awayTeamId: data['awayTeamId'] ?? '',
      homeTeamName: data['homeTeamName'] ?? '',
      awayTeamName: data['awayTeamName'] ?? '',
      homeTeamLogo: data['homeTeamLogo'],
      awayTeamLogo: data['awayTeamLogo'],
      homeScore: data['homeScore'] ?? 0,
      awayScore: data['awayScore'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'scheduled',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      matchWeek: data['matchWeek'] ?? '',
    );
  }

  /// Mengubah MatchModel menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'date': date,
      'status': status,
      'userId': userId,
      'createdAt': createdAt,
      'matchWeek': matchWeek,
    };
  }

  /// Membuat copy dari MatchModel dengan beberapa field yang bisa diubah
  MatchModel copyWith({
    String? id,
    String? homeTeamId,
    String? awayTeamId,
    String? homeTeamName,
    String? awayTeamName,
    String? homeTeamLogo,
    String? awayTeamLogo,
    int? homeScore,
    int? awayScore,
    DateTime? date,
    String? status,
    String? userId,
    DateTime? createdAt,
    String? matchWeek,
  }) {
    return MatchModel(
      id: id ?? this.id,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      date: date ?? this.date,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      matchWeek: matchWeek ?? this.matchWeek,
    );
  }

  @override
  String toString() => 'Match($homeTeamName vs $awayTeamName: $homeScore-$awayScore)';
}
