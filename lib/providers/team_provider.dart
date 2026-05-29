import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';

class TeamProvider with ChangeNotifier {

  final CollectionReference<Map<String, dynamic>> _teamsCollection =
  FirebaseFirestore.instance.collection('teams');

  List<Team> _teams = [];

  List<Team> get teams => _teams;

  TeamProvider() {
    fetchTeams();
  }

  // FETCH TEAM
  void fetchTeams() {
    _teamsCollection.snapshots().listen((snapshot) {

      _teams = snapshot.docs.map((doc) {
        return Team.fromFirestore(doc);
      }).toList();

      notifyListeners();
    });
  }

  // ADD TEAM
  Future<void> addTeam(
      String name,
      String? logoUrl,
      ) async {

    await _teamsCollection.add({
      'name': name,
      'logoUrl': logoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE TEAM
  Future<void> updateTeam(
      String id,
      String name,
      String? logoUrl,
      ) async {

    await _teamsCollection.doc(id).update({
      'name': name,
      'logoUrl': logoUrl,
    });
  }

  // DELETE TEAM
  Future<void> deleteTeam(String id) async {

    await _teamsCollection.doc(id).delete();
  }

  // GET TEAM BY ID
  Team? getTeamById(String id) {

    try {
      return _teams.firstWhere(
            (team) => team.id == id,
      );

    } catch (e) {
      return null;
    }
  }
}