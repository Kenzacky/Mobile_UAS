import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk menyimpan data season/musim liga
class LeagueSeason {
  final String id;
  final String seasonName; // "Season 1", "Season 2", dll
  final int seasonYear;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'active', 'completed', 'archived'
  final String? winnerId; // ID tim juara
  final String? winnerName;
  final Map<String, dynamic> statistics; // Stats keseluruhan season

  LeagueSeason({
    required this.id,
    required this.seasonName,
    required this.seasonYear,
    required this.startDate,
    this.endDate,
    this.status = 'active',
    this.winnerId,
    this.winnerName,
    this.statistics = const {},
  });

  // Getter untuk cek apakah season sudah selesai
  bool get isCompleted => status == 'completed' && endDate != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seasonName': seasonName,
      'seasonYear': seasonYear,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'statistics': statistics,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seasonName': seasonName,
      'seasonYear': seasonYear,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'statistics': statistics,
    };
  }

  factory LeagueSeason.fromJson(Map<String, dynamic> json) {
    return LeagueSeason(
      id: json['id'] ?? '',
      seasonName: json['seasonName'] ?? '',
      seasonYear: (json['seasonYear'] as num?)?.toInt() ?? DateTime.now().year,
      startDate: json['startDate'] is String
          ? DateTime.parse(json['startDate'])
          : (json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.now()),
      endDate: json['endDate'] != null
          ? (json['endDate'] is String
          ? DateTime.parse(json['endDate'])
          : (json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : null))
          : null,
      status: json['status'] ?? 'active',
      winnerId: json['winnerId'],
      winnerName: json['winnerName'],
      statistics: json['statistics'] ?? {},
    );
  }

  factory LeagueSeason.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LeagueSeason.fromJson({...data, 'id': doc.id});
  }

  LeagueSeason copyWith({
    String? id,
    String? seasonName,
    int? seasonYear,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? winnerId,
    String? winnerName,
    Map<String, dynamic>? statistics,
  }) {
    return LeagueSeason(
      id: id ?? this.id,
      seasonName: seasonName ?? this.seasonName,
      seasonYear: seasonYear ?? this.seasonYear,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      winnerName: winnerName ?? this.winnerName,
      statistics: statistics ?? this.statistics,
    );
  }

  @override
  String toString() => 'LeagueSeason($seasonName - $status)';
}
