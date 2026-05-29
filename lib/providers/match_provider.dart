// lib/providers/match_provider.dart (COMPLETE FIXED)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';

class MatchProvider with ChangeNotifier {
  final CollectionReference _matchesCollection =
  FirebaseFirestore.instance.collection('matches');

  List<MatchModel> _matches = [];

  List<MatchModel> get matches => _matches;
  List<MatchModel> get playedMatches =>
      _matches.where((m) => m.isPlayed).toList();
  List<MatchModel> get upcomingMatches =>
      _matches.where((m) => !m.isPlayed).toList();

  MatchProvider() {
    fetchMatches();
  }

  // ✅ FETCH MATCHES
  void fetchMatches() {
    _matchesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _matches = snapshot.docs
          .map((doc) => MatchModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  // ✅ ADD MATCH
  Future<void> addMatch(MatchModel match) async {
    try {
      final docRef = await _matchesCollection.add(match.toMap());

      // Update local list immediately
      final newMatch = match.copyWith(id: docRef.id);
      _matches.add(newMatch);
      notifyListeners();
    } catch (e) {
      throw Exception('Error adding match: $e');
    }
  }

  // ✅ UPDATE MATCH
  Future<void> updateMatch(MatchModel match) async {
    try {
      await _matchesCollection.doc(match.id).update(match.toMap());

      final index = _matches.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        _matches[index] = match;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error updating match: $e');
    }
  }

  // ✅ DELETE MATCH
  Future<void> deleteMatch(String id) async {
    try {
      await _matchesCollection.doc(id).delete();
      _matches.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Error deleting match: $e');
    }
  }

  // ✅ GET MATCH BY ID
  MatchModel? getMatchById(String id) {
    try {
      return _matches.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ GET MATCHES BY WEEK
  List<MatchModel> getMatchesByWeek(String week) {
    return _matches
        .where((match) => match.matchWeek == week)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // ✅ GET TEAM MATCHES
  List<MatchModel> getTeamMatches(String teamId) {
    return _matches
        .where((match) =>
    match.homeTeamId == teamId || match.awayTeamId == teamId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ✅ GET HEAD TO HEAD
  List<MatchModel> getHeadToHead(String team1Id, String team2Id) {
    return _matches
        .where((match) =>
    (match.homeTeamId == team1Id && match.awayTeamId == team2Id) ||
        (match.homeTeamId == team2Id && match.awayTeamId == team1Id))
        .toList();
  }

  // ✅ STREAM MATCHES
  Stream<List<MatchModel>> getMatchesStream() {
    return _matchesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList());
  }

  // ✅ CLEAR
  void clear() {
    _matches.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}