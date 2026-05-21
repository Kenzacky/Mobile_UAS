import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/standing_provider.dart';
import '../models/standing.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/winner_badge.dart';
import '../widgets/animated_stat_card.dart';

class StandingScreenEnhanced extends StatefulWidget {
  const StandingScreenEnhanced({super.key});

  @override
  State<StandingScreenEnhanced> createState() => _StandingScreenEnhancedState();
}

class _StandingScreenEnhancedState extends State<StandingScreenEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _showCelebration = false;
  late AnimationController _tableController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _tableController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tableController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  void _triggerCelebration() {
    setState(() {
      _showCelebration = true;
    });
    _celebrationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
          _celebrationController.reset();
        }
      });
    });
  }

  Color _getPositionColor(int index) {
    if (index == 0) return const Color(0xFFD4AF37); // Gold - 1st
    if (index == 1) return const Color(0xFFB0B8C8); // Silver - 2nd
    if (index == 2) return const Color(0xFFCD7F32); // Bronze - 3rd
    if (index < 4) return const Color(0xFF3A7BD5); // Champions
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_showCelebration && standings.isNotEmpty) {
            _triggerCelebration();
          }
        });

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Champion Showcase
                  if (standings.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _tableController,
                            curve: const Interval(0, 0.5),
                          ),
                        ),
                        child: WinnerBadge(
                          teamName: standings[0].teamName,
                          position: 1,
                          logoUrl: standings[0].logoUrl,
                          points: standings[0].points,
                        ),
                      ),
                    ),

                  // Runner Up Stats
                  if (standings.length >= 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedStatCard(
                              label: 'Runner Up',
                              value: standings[1].teamName,
                              color: const Color(0xFFB0B8C8),
                              icon: Icons.star_half_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (standings.length >= 3)
                            Expanded(
                              child: AnimatedStatCard(
                                label: 'Podium',
                                value: standings[2].teamName,
                                color: const Color(0xFFCD7F32),
                                icon: Icons.emoji_events,
                              ),
                            ),
                        ],
                      ),
                    ),

                  // Header card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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

                  // Table with enhanced styling
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1829),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFF132040),
                          ),
                          dataRowColor:
                              WidgetStateProperty.resolveWith((states) {
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
                          dataRowMinHeight: 56,
                          dataRowMaxHeight: 56,
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
                            final isChampion = index == 0;

                            return DataRow(
                              color: WidgetStateProperty.resolveWith((states) {
                                if (isChampion) {
                                  return posColor.withOpacity(0.08);
                                }
                                return Colors.transparent;
                              }),
                              cells: [
                                DataCell(
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: posColor.withOpacity(
                                        posColor == Colors.transparent
                                            ? 0
                                            : 0.15,
                                      ),
                                      border: posColor != Colors.transparent
                                          ? Border.all(
                                              color: posColor,
                                              width: 1.5,
                                            )
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
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      if (team.logoUrl != null)
                                        Container(
                                          width: 32,
                                          height: 32,
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
                                              errorBuilder: (_, __, ___) =>
                                                  Icon(
                                                Icons.sports_soccer,
                                                size: 16,
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF1A3A6B)
                                                .withOpacity(0.5),
                                          ),
                                          child: Icon(
                                            Icons.sports_soccer,
                                            size: 16,
                                            color: Colors.white
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 110,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              team.teamName,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isChampion
                                                    ? const Color(0xFFD4AF37)
                                                    : Colors.white,
                                                fontWeight:
                                                    isChampion
                                                        ? FontWeight.w700
                                                        : FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (isChampion)
                                              Text(
                                                '🏆 Champion',
                                                style: TextStyle(
                                                  color: const Color(0xFFD4AF37)
                                                      .withOpacity(0.7),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                          ],
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
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          posColor.withOpacity(0.8),
                                          posColor.withOpacity(0.5),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      team.points.toString(),
                                      style: TextStyle(
                                        color: isChampion
                                            ? const Color(0xFF0A0E1A)
                                            : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _legendDot(const Color(0xFFD4AF37), '1st'),
                      const SizedBox(width: 16),
                      _legendDot(const Color(0xFFB0B8C8), '2nd'),
                      const SizedBox(width: 16),
                      _legendDot(const Color(0xFFCD7F32), '3rd'),
                      const SizedBox(width: 16),
                      _legendDot(const Color(0xFF3A7BD5), 'Promosi'),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Confetti Animation
            if (_showCelebration)
              Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiWidget(
                    autoStart: true,
                    duration: const Duration(seconds: 4),
                  ),
                ),
              ),
          ],
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
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
