import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Team (Tim)
/// Menyimpan informasi dasar tim seperti nama dan logo
class Team {
  // Identifikasi unik tim (dari Firestore)
  final String id;
  // Nama tim
  final String name;
  // URL gambar logo tim
  final String? logoUrl;
  // Waktu tim dibuat
  final DateTime? createdAt;

  Team({
    required this.id,
    required this.name,
    this.logoUrl,
    this.createdAt,
  });

  /// Konstruktor untuk membuat Team dari Firestore document
  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Mengubah Team menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'createdAt': createdAt,
    };
  }

  /// Membuat copy dari Team dengan beberapa field yang bisa diubah
  Team copyWith({
    String? id,
    String? name,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}