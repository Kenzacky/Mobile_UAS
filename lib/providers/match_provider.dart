import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';

class MatchProvider with ChangeNotifier {
  final CollectionReference _matchesCollection =
  FirebaseFirestore.instance.collection('matches');

  List<MatchModel> _matches = [];
  List<MatchModel> get matches => _matches;

  MatchProvider() {
    fetchMatches();
  }

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

  Future<void> addMatch(MatchModel match) async {
    await _matchesCollection.add(match.toMap());
  }

  Future<void> updateMatch(MatchModel match) async {
    await _matchesCollection.doc(match.id).update(match.toMap());
  }

  Future<void> deleteMatch(String id) async {
    await _matchesCollection.doc(id).delete();
  }
}