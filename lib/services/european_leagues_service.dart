import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/real_standing.dart';

/// European Leagues API Service
/// Mendukung: Premier League, La Liga, Serie A, Bundesliga, Ligue 1, dan liga top Eropa lainnya
/// Cross-platform compatible: Windows, Android, iOS, Web
class EuropeanLeaguesService {
  // API Configuration
  static const String _apiKey = '62f0dc0f6af847679d6f6621be0cdd30';
  static const String _baseUrl = 'https://api.football-data.org/v4';
  static const int _timeoutSeconds = 15;

  // European Top Leagues Configuration
  static final Map<String, LeagueConfig> europeanLeagues = {
    'PL': LeagueConfig(
      code: 'PL',
      name: 'Premier League',
      country: 'England',
      emoji: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
      season: 2024,
    ),
    'LA': LeagueConfig(
      code: 'PD',
      name: 'La Liga',
      country: 'Spain',
      emoji: '🇪🇸',
      season: 2024,
    ),
    'SA': LeagueConfig(
      code: 'SA',
      name: 'Serie A',
      country: 'Italy',
      emoji: '🇮🇹',
      season: 2024,
    ),
    'BL': LeagueConfig(
      code: 'BL1',
      name: 'Bundesliga',
      country: 'Germany',
      emoji: '🇩🇪',
      season: 2024,
    ),
    'L1': LeagueConfig(
      code: 'FL1',
      name: 'Ligue 1',
      country: 'France',
      emoji: '🇫🇷',
      season: 2024,
    ),
    'PT': LeagueConfig(
      code: 'PPL',
      name: 'Liga Portugal',
      country: 'Portugal',
      emoji: '🇵🇹',
      season: 2024,
    ),
    'NL': LeagueConfig(
      code: 'DED',
      name: 'Eredivisie',
      country: 'Netherlands',
      emoji: '🇳🇱',
      season: 2024,
    ),
    'BE': LeagueConfig(
      code: 'BL3',
      name: 'Belgian Pro League',
      country: 'Belgium',
      emoji: '🇧🇪',
      season: 2024,
    ),
  };

  /// Get all available European leagues
  static List<LeagueConfig> getAllLeagues() {
    return europeanLeagues.values.toList();
  }

  /// Get league by ID
  static LeagueConfig? getLeagueById(String leagueId) {
    return europeanLeagues[leagueId];
  }

  /// Fetch standings untuk league tertentu
  /// Throws Exception jika gagal atau API key tidak valid
  static Future<List<RealTeamStanding>> fetchLeagueStandings(
      String leagueCode,
      ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/competitions/$leagueCode/standings',
      );

      final response = await http.get(
        url,
        headers: {
          'X-Auth-Token': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> standingsData = data['standings'][0]['table'];

        return standingsData
            .map((item) => RealTeamStanding.fromJson(item))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('API Key tidak valid atau expired');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Silahkan coba lagi nanti');
      } else {
        throw Exception('Gagal memuat klasemen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error mengambil data: $e');
    }
  }

  /// Fetch upcoming matches untuk league tertentu
  static Future<List<dynamic>> fetchUpcomingMatches(
      String leagueCode, {
        int days = 7,
      }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/competitions/$leagueCode/matches?status=SCHEDULED&order=asc',
      );

      final response = await http.get(
        url,
        headers: {
          'X-Auth-Token': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> matches = data['matches'] ?? [];
        return matches;
      } else {
        throw Exception('Gagal memuat pertandingan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error mengambil data pertandingan: $e');
    }
  }

  /// Fetch completed matches untuk league tertentu
  static Future<List<dynamic>> fetchCompletedMatches(
      String leagueCode, {
        int limit = 10,
      }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/competitions/$leagueCode/matches?status=FINISHED&order=desc',
      );

      final response = await http.get(
        url,
        headers: {
          'X-Auth-Token': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> matches = data['matches'] ?? [];
        return matches.take(limit).toList();
      } else {
        throw Exception('Gagal memuat hasil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error mengambil data hasil: $e');
    }
  }

  /// Fetch top scorers untuk league tertentu
  static Future<List<dynamic>> fetchTopScorers(String leagueCode) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/competitions/$leagueCode/scorers?order=DESC&limit=10',
      );

      final response = await http.get(
        url,
        headers: {
          'X-Auth-Token': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> scorers = data['scorers'] ?? [];
        return scorers;
      } else {
        throw Exception('Gagal memuat top scorers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error mengambil data top scorers: $e');
    }
  }

  /// Fetch team detail
  static Future<Map<String, dynamic>> fetchTeamDetail(int teamId) async {
    try {
      final url = Uri.parse('$_baseUrl/teams/$teamId');

      final response = await http.get(
        url,
        headers: {
          'X-Auth-Token': _apiKey,
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat detail tim: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error mengambil data tim: $e');
    }
  }
}

/// Configuration class untuk setiap league
class LeagueConfig {
  final String code;
  final String name;
  final String country;
  final String emoji;
  final int season;

  LeagueConfig({
    required this.code,
    required this.name,
    required this.country,
    required this.emoji,
    required this.season,
  });

  String get displayName => '$emoji $name';

  @override
  String toString() => '$emoji $name ($country)';
}
