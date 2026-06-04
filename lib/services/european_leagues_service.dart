import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/real_standing.dart';

/// European Leagues API Service dengan Better Error Handling & Caching
/// Mendukung: Premier League, La Liga, Serie A, Bundesliga, Ligue 1, dan liga top Eropa lainnya
class EuropeanLeaguesService {
  // API Configuration
  static const String _apiKey = 'a1c83f54033b45a098b78835d5b9ca71';
  static const String _baseUrl = 'https://api.football-data.org/v4';
  static const int _timeoutSeconds = 20;

  // Cache untuk menyimpan data sementara
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  static const int _cacheDurationMinutes = 5;

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

  /// Check apakah cache masih valid
  static bool _isCacheValid(String key) {
    if (!_cacheTime.containsKey(key)) return false;
    final cachedTime = _cacheTime[key];
    if (cachedTime == null) return false;
    final elapsed = DateTime.now().difference(cachedTime).inMinutes;
    return elapsed < _cacheDurationMinutes;
  }

  /// Get all available European leagues
  static List<LeagueConfig> getAllLeagues() {
    return europeanLeagues.values.toList();
  }

  /// Get league by ID
  static LeagueConfig? getLeagueById(String leagueId) {
    return europeanLeagues[leagueId];
  }

  /// Fetch standings untuk league tertentu dengan caching & retry logic
  static Future<List<RealTeamStanding>> fetchLeagueStandings(
      String leagueCode, {
        bool forceRefresh = false,
      }) async {
    try {
      final cacheKey = 'standings_$leagueCode';

      // Check cache terlebih dahulu
      if (!forceRefresh && _isCacheValid(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<RealTeamStanding>;
      }

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
        onTimeout: () => throw Exception('Request timeout - API response terlalu lama'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Validasi data struktur
        if (!data.containsKey('standings') || data['standings'].isEmpty) {
          throw Exception('Format data API tidak sesuai - standings tidak ditemukan');
        }

        final List<dynamic> standingsData = data['standings'][0]['table'] ?? [];

        final result = standingsData
            .map((item) => RealTeamStanding.fromJson(item))
            .toList();

        // Simpan ke cache
        _cache[cacheKey] = result;
        _cacheTime[cacheKey] = DateTime.now();

        return result;
      } else if (response.statusCode == 401) {
        throw Exception('❌ API Key tidak valid atau sudah expired\n\nSilahkan update API key di european_leagues_service.dart');
      } else if (response.statusCode == 429) {
        throw Exception('⚠️ Rate limit exceeded!\n\nAnda telah membuat terlalu banyak request.\nSilahkan coba lagi dalam beberapa menit');
      } else if (response.statusCode == 404) {
        throw Exception('❌ League code tidak ditemukan: $leagueCode');
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.reasonPhrase}\n\nResponse: ${response.body.substring(0, 200)}');
      }
    } on SocketException catch (_) {
      throw Exception('❌ Tidak ada koneksi internet\n\nSilahkan periksa koneksi Anda');
    } catch (e) {
      throw Exception('⚠️ Error mengambil data: $e');
    }
  }

  /// Fetch upcoming matches untuk league tertentu
  static Future<List<dynamic>> fetchUpcomingMatches(
      String leagueCode, {
        int days = 7,
      }) async {
    try {
      final cacheKey = 'upcoming_$leagueCode';

      if (_isCacheValid(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<dynamic>;
      }

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

        _cache[cacheKey] = matches;
        _cacheTime[cacheKey] = DateTime.now();

        return matches;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded');
      } else {
        throw Exception('Gagal memuat pertandingan: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('Tidak ada koneksi internet');
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
      final cacheKey = 'completed_$leagueCode';

      if (_isCacheValid(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<dynamic>;
      }

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
        final List<dynamic> matches = (data['matches'] ?? [])
            .take(limit)
            .toList();

        _cache[cacheKey] = matches;
        _cacheTime[cacheKey] = DateTime.now();

        return matches;
      } else {
        throw Exception('Gagal memuat hasil: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Error mengambil data hasil: $e');
    }
  }

  /// Fetch top scorers untuk league tertentu
  static Future<List<dynamic>> fetchTopScorers(String leagueCode) async {
    try {
      final cacheKey = 'topscorers_$leagueCode';

      if (_isCacheValid(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<dynamic>;
      }

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

        _cache[cacheKey] = scorers;
        _cacheTime[cacheKey] = DateTime.now();

        return scorers;
      } else {
        throw Exception('Gagal memuat top scorers: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Error mengambil data top scorers: $e');
    }
  }

  /// Fetch team detail
  static Future<Map<String, dynamic>> fetchTeamDetail(int teamId) async {
    try {
      final cacheKey = 'team_$teamId';

      if (_isCacheValid(cacheKey) && _cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as Map<String, dynamic>;
      }

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

        _cache[cacheKey] = data;
        _cacheTime[cacheKey] = DateTime.now();

        return data;
      } else {
        throw Exception('Gagal memuat detail tim: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('Tidak ada koneksi internet');
    } catch (e) {
      throw Exception('Error mengambil data tim: $e');
    }
  }

  /// Clear cache
  static void clearCache() {
    _cache.clear();
    _cacheTime.clear();
  }

  /// Clear specific cache
  static void clearCacheFor(String key) {
    _cache.remove(key);
    _cacheTime.remove(key);
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
