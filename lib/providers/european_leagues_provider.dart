import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/european_leagues_service.dart';

class EuropeanLeaguesProvider with ChangeNotifier {
  final EuropeanLeaguesService _service = EuropeanLeaguesService();

  String _selectedLeagueCode = 'PL';
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> _standings = [];
  List<dynamic> _upcomingMatches = [];
  List<dynamic> _completedMatches = [];
  List<dynamic> _topScorers = [];

  // Getters
  String get selectedLeagueCode => _selectedLeagueCode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get standings => _standings;
  List<dynamic> get upcomingMatches => _upcomingMatches;
  List<dynamic> get completedMatches => _completedMatches;
  List<dynamic> get topScorers => _topScorers;
  List<LeagueConfig> get availableLeagues =>
      EuropeanLeaguesService.getAllLeagues();

  // Select League
  Future<void> selectLeague(String leagueCode) async {
    _selectedLeagueCode = leagueCode;
    await fetchAllLeagueData();
  }

  // Fetch All Data
  Future<void> fetchAllLeagueData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final standings = await EuropeanLeaguesService.fetchLeagueStandings(
        _selectedLeagueCode,
      );
      final upcoming = await EuropeanLeaguesService.fetchUpcomingMatches(
        _selectedLeagueCode,
      );
      final completed = await EuropeanLeaguesService.fetchCompletedMatches(
        _selectedLeagueCode,
      );
      final scorers =
      await EuropeanLeaguesService.fetchTopScorers(_selectedLeagueCode);

      _standings = standings;
      _upcomingMatches = upcoming;
      _completedMatches = completed;
      _topScorers = scorers;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh Data
  Future<void> refreshData() async {
    await fetchAllLeagueData();
  }
}
