import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../providers/team_provider.dart';
import '../providers/match_provider.dart';
import '../models/match.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ScheduleProvider, TeamProvider, MatchProvider>(
      builder: (ctx, scheduleProvider, teamProvider, matchProvider, _) {
        final weeks = scheduleProvider.getAllWeeks();
        final upcomingMatches = scheduleProvider.getUpcomingMatches();

        if (weeks.isEmpty || upcomingMatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F1829),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withAlpha(51),
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 50,
                    color: const Color(0xFFD4AF37).withAlpha(128),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Jadwal Belum Tersedia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan tim terlebih dahulu',
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F1829), Color(0xFF132040)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withAlpha(38),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'JADWAL LIGA',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${weeks.length} Weeks',
                      style: TextStyle(
                        color: Colors.white.withAlpha(102),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: weeks.length,
                  itemBuilder: (ctx, index) {
                    final week = weeks[index];
                    final isFirst = index == 0;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: isFirst ? 0 : 8,
                        right: 8,
                      ),
                      child: _buildWeekChip(week),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ...weeks.map((week) {
                return _buildWeekMatches(
                  week: week,
                  matches: scheduleProvider.getMatchesByWeek(week),
                  teamProvider: teamProvider,
                  scheduleProvider: scheduleProvider,
                  matchProvider: matchProvider,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekChip(String week) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          week,
          style: const TextStyle(
            color: Color(0xFF0A0E1A),
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekMatches({
    required String week,
    required List<MatchModel> matches,
    required TeamProvider teamProvider,
    required ScheduleProvider scheduleProvider,
    required MatchProvider matchProvider,
  }) {
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  week,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${matches.length} matches',
                  style: TextStyle(
                    color: Colors.white.withAlpha(102),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: matches.asMap().entries.map((entry) {
              final index = entry.key;
              final match = entry.value;
              final isLast = index == matches.length - 1;
              return Column(
                children: [
                  _buildMatchCard(
                    match: match,
                    scheduleProvider: scheduleProvider,
                    matchProvider: matchProvider,
                  ),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard({
    required MatchModel match,
    required ScheduleProvider scheduleProvider,
    required MatchProvider matchProvider,
  }) {
    final isFinished = match.status == 'finished';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1829),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFinished
              ? const Color(0xFF4CAF50).withAlpha(77)
              : const Color(0xFFD4AF37).withAlpha(25),
        ),
        boxShadow: isFinished
            ? [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(25),
            blurRadius: 8,
          )
        ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            DateFormat('EEE, dd MMM • HH:mm', 'id_ID').format(match.date),
            style: TextStyle(
              color: Colors.white.withAlpha(128),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      match.homeTeamName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '🏠 Home',
                      style: TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFinished)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${match.homeScore} - ${match.awayScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      color: Color(0xFF0A0E1A),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      match.awayTeamName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '✈️ Away',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isFinished) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0A0E1A),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _showScoreInputDialog(
                    context,
                    match,
                    scheduleProvider,
                    matchProvider,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Input Skor',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  '✅ Selesai',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showScoreInputDialog(
      BuildContext context,
      MatchModel match,
      ScheduleProvider scheduleProvider,
      MatchProvider matchProvider,
      ) {
    final homeScoreController = TextEditingController();
    final awayScoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0F1829),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFD4AF37).withAlpha(77),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚽ INPUT SKOR',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.homeTeamName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'vs',
                    style: TextStyle(
                      color: Colors.white.withAlpha(102),
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.awayTeamName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextField(
                      controller: homeScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFD4AF37).withAlpha(25),
                        hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    ':',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: awayScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFD4AF37).withAlpha(25),
                        hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0A0E1A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final homeScore = int.tryParse(homeScoreController.text) ?? 0;
                        final awayScore = int.tryParse(awayScoreController.text) ?? 0;

                        scheduleProvider.updateMatchResult(match.id, homeScore, awayScore);

                        final newMatch = match.copyWith(
                          homeScore: homeScore,
                          awayScore: awayScore,
                          status: 'finished',
                        );

                        try {
                          await matchProvider.addMatch(newMatch);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('✅ Skor disimpan & klasemen terupdate!'),
                                  ],
                                ),
                                backgroundColor: Color(0xFF4CAF50),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}