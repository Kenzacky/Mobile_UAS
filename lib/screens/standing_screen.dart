import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/standing_provider.dart';
import '../models/standing.dart';

class StandingScreen extends StatelessWidget {
  const StandingScreen({super.key});

  Color _getPositionColor(int index) {
    if (index == 0) return const Color(0xFFD4AF37);      // Gold - 1st
    if (index == 1) return const Color(0xFFB0B8C8);      // Silver - 2nd
    if (index == 2) return const Color(0xFFCD7F32);      // Bronze - 3rd
    if (index < 4) return const Color(0xFF3A7BD5);       // Champions
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StandingProvider>(
      builder: (ctx, standingProvider, _) {
        final standings = standingProvider.standings;

        if (standings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F1829),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 44,
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Belum Ada Klasemen',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan tim dan pertandingan\nterlebih dahulu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F1829), Color(0xFF132040)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'KLASEMEN LIGA',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${standings.length} Tim',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Table
              Container(
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
                      dataRowColor: WidgetStateProperty.resolveWith((states) {
                        return Colors.transparent;
                      }),
                      columnSpacing: 16,
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
                        DataColumn(label: Text('NO')),
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
                      rows: standings.asMap().entries.map((entry) {
                        final index = entry.key;
                        final team = entry.value;
                        final posColor = _getPositionColor(index);

                        return DataRow(cells: [
                          DataCell(
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: posColor.withOpacity(
                                  posColor == Colors.transparent ? 0 : 0.15,
                                ),
                                border: posColor != Colors.transparent
                                    ? Border.all(color: posColor, width: 1.5)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: posColor != Colors.transparent
                                      ? posColor
                                      : Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                if (team.logoUrl != null)
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFD4AF37)
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        team.logoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.sports_soccer,
                                          size: 16,
                                          color:
                                          Colors.white.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF1A3A6B)
                                          .withOpacity(0.5),
                                    ),
                                    child: Icon(
                                      Icons.sports_soccer,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.5),
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
                          _numCell(team.played.toString()),
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
                                borderRadius: BorderRadius.circular(8),
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

              const SizedBox(height: 16),
              // Legend
              Row(
                children: [
                  _legendDot(const Color(0xFFD4AF37), '1st'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFFB0B8C8), '2nd'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFFCD7F32), '3rd'),
                  const SizedBox(width: 12),
                  _legendDot(const Color(0xFF3A7BD5), 'Promosi'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  DataCell _numCell(String val) {
    return DataCell(
      Text(
        val,
        style: TextStyle(
          color: Colors.white.withOpacity(0.65),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}