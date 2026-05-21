import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String? logoUrl;

  Team({required this.id, required this.name, this.logoUrl});

  // 🔥 PERHATIKAN: hanya 1 parameter DocumentSnapshot
  factory Team.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,          // ambil id dari snapshot
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}