// lib/models/match.dart (COMPLETE FIXED)
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final String homeTeamName;
  final String awayTeamName;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final int homeScore;
  final int awayScore;
  final DateTime date;
  final String status; // 'scheduled', 'finished', 'ongoing'
  final String userId;
  final DateTime createdAt;
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
    this.status = 'scheduled',
    required this.userId,
    required this.createdAt,
    this.matchWeek = '',
  });

  // ✅ GETTER isPlayed
  bool get isPlayed => status == 'finished';

  String get result {
    if (homeScore > awayScore) return 'home';
    if (awayScore > homeScore) return 'away';
    return 'draw';
  }

  String get resultText {
    if (result == 'home') return '$homeTeamName Win';
    if (result == 'away') return '$awayTeamName Win';
    return 'Draw';
  }

  int get totalGoals => homeScore + awayScore;
  String get scoreDisplay => '$homeScore - $awayScore';

  // ✅ toMap() METHOD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'date': Timestamp.fromDate(date),
      'status': status,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'matchWeek': matchWeek,
    };
  }

  // ✅ toJson() METHOD
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'date': date.toIso8601String(),
      'status': status,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'matchWeek': matchWeek,
    };
  }

  // ✅ fromJson() FACTORY
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] ?? '',
      homeTeamId: json['homeTeamId'] ?? '',
      awayTeamId: json['awayTeamId'] ?? '',
      homeTeamName: json['homeTeamName'] ?? '',
      awayTeamName: json['awayTeamName'] ?? '',
      homeTeamLogo: json['homeTeamLogo'],
      awayTeamLogo: json['awayTeamLogo'],
      homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
      date: json['date'] is String
          ? DateTime.parse(json['date'])
          : (json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now()),
      status: json['status'] ?? 'scheduled',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : (json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now()),
      matchWeek: json['matchWeek'] ?? '',
    );
  }

  // ✅ fromFirestore() FACTORY
  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MatchModel.fromJson({...data, 'id': doc.id});
  }

  // ✅ copyWith() METHOD
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
  String toString() =>
      'Match(id: $id, $homeTeamName vs $awayTeamName, $homeScore-$awayScore)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MatchModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}