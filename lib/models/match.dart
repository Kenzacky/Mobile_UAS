import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final int homeScore;
  final int awayScore;
  final DateTime date;
  final bool isPlayed;

  MatchModel({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeScore,
    required this.awayScore,
    required this.date,
    this.isPlayed = true,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      homeTeamId: data['homeTeamId'],
      awayTeamId: data['awayTeamId'],
      homeScore: data['homeScore'],
      awayScore: data['awayScore'],
      date: (data['date'] as Timestamp).toDate(),
      isPlayed: data['isPlayed'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'date': Timestamp.fromDate(date),
      'isPlayed': isPlayed,
    };
  }
}