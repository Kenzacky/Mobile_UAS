// lib/screens/real_league_screen.dart (FIXED - Using Mock Data)
import 'package:flutter/material.dart';
import '../services/mock_leagues_data.dart';

class RealLeagueScreen extends StatefulWidget {
  const RealLeagueScreen({super.key});

  @override
  State<RealLeagueScreen> createState() => _RealLeagueScreenState();
}

class _RealLeagueScreenState extends State<RealLeagueScreen> {
  String _selectedLeague = 'PL';

  final Map<String, String> _leagueNames = {
    'PL': '🏴󠁧󠁢󠁥󠁮󠁧󠁿 Premier League',
    'PD': '🇪🇸 La Liga',
    'SA': '🇮🇹 Serie A',
    'BL1': '🇩🇪 Bundesliga',
    'FL1': '🇫🇷 Ligue 1',
  };

  @override
  Widget build(BuildContext context) {
    final standings = MockLeaguesData.getStandingsByLeague(_selectedLeague);

    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A1020),
                    Colors.green[800] ?? const Color(0xFF2E7D32),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.sports_soccer_rounded,
                        color: Color(0xFFD4AF37),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'KLASEMEN EROPA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // League Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF0A1020),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _leagueNames.entries.map((entry) {
                    final code = entry.key;
                    final name = entry.value;
                    final isSelected = code == _selectedLeague;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF0A0E1A)
                                : Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        selectedColor: const Color(0xFFD4AF37),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFFD4AF37)
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedLeague = code);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Standings Table
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1829),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            'Pos',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tim',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'M',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'W',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'D',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'L',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 45,
                          child: Text(
                            'Pts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Rows
                  ...standings.asMap().entries.map((entry) {
                    final team = entry.value;
                    final position = team['position'] as int;
                    final teamName = team['team']['name'] as String;
                    final played = team['playedGames'] as int;
                    final won = team['won'] as int;
                    final draw = team['draw'] as int;
                    final lost = team['lost'] as int;
                    final points = team['points'] as int;

                    final color = _getPositionColor(position);

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: color, width: 4),
                          bottom: BorderSide(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                          ),
                          right: BorderSide(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                          ),
                        ),
                        color: position <= 4
                            ? Colors.green.withValues(alpha: 0.05)
                            : position <= 6
                            ? Colors.blue.withValues(alpha: 0.05)
                            : position >= standings.length - 3
                            ? Colors.red.withValues(alpha: 0.05)
                            : const Color(0xFF0F1829),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                '$position',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                teamName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$played',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$won',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$draw',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.yellow.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$lost',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 45,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$points',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  // Table Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1829),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border(
                        left: BorderSide(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        ),
                        right: BorderSide(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        ),
                        bottom: BorderSide(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('🟢', 'Champion', Colors.green),
                        _buildLegendItem('🔵', 'UCL', Colors.blue),
                        _buildLegendItem('🔴', 'Relegation', Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 4) return const Color(0xFF4CAF50);
    if (position <= 6) return const Color(0xFF4ECDC4);
    if (position >= 18) return const Color(0xFFFF6B6B);
    return const Color(0xFFD4AF37);
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
