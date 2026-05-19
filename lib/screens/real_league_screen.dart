import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/real_standing.dart';

class RealLeagueScreen extends StatefulWidget {
  const RealLeagueScreen({super.key});

  @override
  State<RealLeagueScreen> createState() => _RealLeagueScreenState();
}

class _RealLeagueScreenState extends State<RealLeagueScreen> {
  String _selectedLeague = 'PL';
  List<RealTeamStanding> _standings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStandings();
  }

  Future<void> _fetchStandings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final standings = await ApiService().fetchStandings(_selectedLeague);
      setState(() {
        _standings = standings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String get _selectedLeagueName {
    return ApiService.availableLeagues
        .firstWhere(
          (l) => l['code'] == _selectedLeague,
      orElse: () => {'name': 'Liga'},
    )['name'] ??
        'Liga';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: Column(
        children: [
          // League selector
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1829),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLeague,
                isExpanded: true,
                dropdownColor: const Color(0xFF0F1829),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFD4AF37),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: ApiService.availableLeagues.map((league) {
                  return DropdownMenuItem<String>(
                    value: league['code'],
                    child: Text(
                      league['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newLeague) {
                  if (newLeague != null) {
                    setState(() => _selectedLeague = newLeague);
                    _fetchStandings();
                  }
                },
              ),
            ),
          ),

          // Header info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F1829), Color(0xFF132040)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.public_rounded,
                    color: Color(0xFFD4AF37),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedLeagueName,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  if (!_isLoading && _errorMessage == null)
                    Text(
                      '${_standings.length} Tim',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD4AF37),
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat klasemen...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
                : _errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F1829),
                        border: Border.all(
                          color: const Color(0xFFEF5350).withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 38,
                        color: Color(0xFFEF5350),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gagal Memuat Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Periksa koneksi internet Anda\nlalu coba lagi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                        ),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _fetchStandings,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('COBA LAGI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: const Color(0xFF0A0E1A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : _standings.isEmpty
                ? Center(
              child: Text(
                'Belum ada data klasemen',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1829),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFF132040),
                      ),
                      columnSpacing: 14,
                      headingTextStyle: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                      dividerThickness: 0.5,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 52,
                      columns: const [
                        DataColumn(label: Text('POS')),
                        DataColumn(label: Text('TIM')),
                        DataColumn(label: Text('M')),
                        DataColumn(label: Text('W')),
                        DataColumn(label: Text('D')),
                        DataColumn(label: Text('L')),
                        DataColumn(label: Text('GF')),
                        DataColumn(label: Text('GA')),
                        DataColumn(label: Text('GD')),
                        DataColumn(label: Text('PTS')),
                      ],
                      rows: _standings.asMap().entries.map((entry) {
                        final i = entry.key;
                        final team = entry.value;
                        return DataRow(cells: [
                          DataCell(
                            Text(
                              team.position.toString(),
                              style: TextStyle(
                                color: i < 3
                                    ? const Color(0xFFD4AF37)
                                    : Colors.white.withOpacity(0.5),
                                fontWeight: i < 3
                                    ? FontWeight.w800
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                if (team.teamCrest.isNotEmpty)
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Image.network(
                                      team.teamCrest,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          Icon(
                                            Icons.sports_soccer,
                                            size: 20,
                                            color: Colors.white
                                                .withOpacity(0.4),
                                          ),
                                    ),
                                  ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    team.teamName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _numCell(team.playedGames.toString()),
                          _numCell(team.won.toString()),
                          _numCell(team.draw.toString()),
                          _numCell(team.lost.toString()),
                          _numCell(team.goalsFor.toString()),
                          _numCell(team.goalsAgainst.toString()),
                          DataCell(
                            Text(
                              (team.goalDifference >= 0 ? '+' : '') +
                                  team.goalDifference.toString(),
                              style: TextStyle(
                                color: team.goalDifference > 0
                                    ? const Color(0xFF4CAF50)
                                    : team.goalDifference < 0
                                    ? const Color(0xFFEF5350)
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFF5D76E),
                                  ],
                                ),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Text(
                                team.points.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF0A0E1A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataCell _numCell(String val) {
    return DataCell(
      Text(
        val,
        style: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontSize: 13,
        ),
      ),
    );
  }
}