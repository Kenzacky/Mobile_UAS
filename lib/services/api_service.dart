import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/real_standing.dart';

class ApiService {
  // Ganti dengan API Key kamu yang asli!
  static const String _apiKey = '62f0dc0f6af847679d6f6621be0cdd30';
  static const String _baseUrl = 'https://api.football-data.org/v4';

  // Daftar liga yang tersedia (kode dan nama)
  static final List<Map<String, String>> availableLeagues = [
    {'code': 'PL', 'name': '🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League'},
    {'code': 'SA', 'name': '🇮🇹 Serie A'},
    {'code': 'PD', 'name': '🇪🇸 La Liga'},
    {'code': 'BL1', 'name': '🇩🇪 Bundesliga'},
    {'code': 'FL1', 'name': '🇫🇷 Ligue 1'},
    {'code': 'PPL', 'name': '🇵🇹 Liga Portugal'},
    {'code': 'DED', 'name': '🇳🇱 Eredivisie'},
    {'code': 'BSA', 'name': '🇧🇷 Brasileirao'},
    // Catatan: Liga Indonesia (Liga 1) tidak tersedia di API ini.
    // Kamu bisa menambahkannya nanti dengan cara manual (Mock data) atau mencari API lain.
  ];

  // Fungsi untuk mengambil data klasemen berdasarkan kode liga
  Future<List<RealTeamStanding>> fetchStandings(String leagueCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/competitions/$leagueCode/standings'),
        headers: {'X-Auth-Token': _apiKey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Data standings biasanya ada di array 'standings' -> index 0 -> 'table'
        final List<dynamic> standingsData = data['standings'][0]['table'];

        return standingsData
            .map((item) => RealTeamStanding.fromJson(item))
            .toList();
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
