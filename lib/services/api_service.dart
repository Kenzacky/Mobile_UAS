import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/real_standing.dart';

/// Service untuk mengambil data API Football
/// Menggunakan football-data.org API
class ApiService {
  // Ganti dengan API Key kamu yang asli!
  static const String _apiKey = '62f0dc0f6af847679d6f6621be0cdd30';
  static const String _baseUrl = 'https://api.football-data.org/v4';
  static const int _timeoutSeconds = 15;

  /// Daftar liga yang tersedia
  static final List<Map<String, String>> availableLeagues = [
    {'code': 'PL', 'name': '🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League'},
    {'code': 'SA', 'name': '🇮🇹 Serie A'},
    {'code': 'PD', 'name': '🇪🇸 La Liga'},
    {'code': 'BL1', 'name': '🇩🇪 Bundesliga'},
    {'code': 'FL1', 'name': '🇫🇷 Ligue 1'},
    {'code': 'PPL', 'name': '🇵🇹 Liga Portugal'},
    {'code': 'DED', 'name': '🇳🇱 Eredivisie'},
    {'code': 'BSA', 'name': '🇧🇷 Brasileirao'},
  ];

  /// Fetch (Mengambil) data klasemen berdasarkan kode liga
  /// [leagueCode]: Kode liga (contoh: 'PL' untuk Premier League)
  /// Return: List RealTeamStanding dari klasemen liga
  /// Throws: Exception jika gagal atau API error
  static Future<List<RealTeamStanding>> fetchStandings(
      String leagueCode,
      ) async {
    try {
      // Buat URL request ke API
      final url = Uri.parse('$_baseUrl/competitions/$leagueCode/standings');

      // Lakukan HTTP GET request dengan timeout
      final response = await http.get(
        url,
        headers: {'X-Auth-Token': _apiKey},
      ).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      // Cek apakah response berhasil (status code 200)
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> data = json.decode(response.body);
        // Data klasemen biasanya ada di 'standings' -> index 0 -> 'table'
        final List<dynamic> standingsData = data['standings'][0]['table'] ?? [];

        // Map setiap item menjadi RealTeamStanding object
        return standingsData
            .map((item) => RealTeamStanding.fromJson(item))
            .toList();
      } else if (response.statusCode == 400) {
        throw Exception('Bad request - Invalid league code');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden - API key invalid or quota exceeded');
      } else if (response.statusCode == 404) {
        throw Exception('Not found - League not available');
      } else {
        throw Exception('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // Throw error dengan pesan yang lebih detail
      throw Exception('Failed to fetch standings: $e');
    }
  }

  /// Fetch (Mengambil) daftar tim untuk suatu liga
  /// [leagueCode]: Kode liga
  /// Return: List data tim
  static Future<List<dynamic>> fetchTeams(String leagueCode) async {
    try {
      final url = Uri.parse('$_baseUrl/competitions/$leagueCode/teams');
      final response = await http.get(
        url,
        headers: {'X-Auth-Token': _apiKey},
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['teams'] ?? [];
      } else {
        throw Exception('Failed to fetch teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }

  /// Fetch (Mengambil) data pertandingan untuk suatu liga
  /// [leagueCode]: Kode liga
  /// Return: List data pertandingan
  static Future<List<dynamic>> fetchMatches(String leagueCode) async {
    try {
      final url = Uri.parse('$_baseUrl/competitions/$leagueCode/matches');
      final response = await http.get(
        url,
        headers: {'X-Auth-Token': _apiKey},
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['matches'] ?? [];
      } else {
        throw Exception('Failed to fetch matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }
}
