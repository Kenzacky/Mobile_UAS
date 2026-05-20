import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../providers/team_provider.dart';
import '../providers/match_provider.dart';
import '../models/match.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ScheduleProvider, TeamProvider, MatchProvider>(
      builder: (ctx, scheduleProvider, teamProvider, matchProvider, _) {
        final upcomingMatches = scheduleProvider.getUpcomingMatches();

        if (upcomingMatches.isEmpty) {
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
                    Icons.calendar_month_rounded,
                    size: 44,
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Semua Pertandingan Selesai',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jadwal liga sudah lengkap dimainkan',
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
              // Header
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
                      '${upcomingMatches.length} Matches',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Upcoming matches
              ...upcomingMatches.map((match) {
                final homeTeam = teamProvider.getTeamById(match.homeTeamId);
                final awayTeam = teamProvider.getTeamById(match.awayTeamId);

                if (homeTeam == null || awayTeam == null) {
                  return const SizedBox.shrink();
                }

                return _ScheduleCard(
                  match: match,
                  homeTeam: homeTeam,
                  awayTeam: awayTeam,
                  onUpdateScore: () {
                    _showScoreInputDialog(
                      context,
                      match,
                      homeTeam.name,
                      awayTeam.name,
                      scheduleProvider,
                      matchProvider,
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showScoreInputDialog(
    BuildContext context,
    MatchModel match,
    String homeTeamName,
    String awayTeamName,
    ScheduleProvider scheduleProvider,
    MatchProvider matchProvider,
  ) {
    final homeScoreController = TextEditingController();
    final awayScoreController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1829),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Input Skor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$homeTeamName vs $awayTeamName',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Row(
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '-',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            onPressed: () async {
              final homeScore = int.tryParse(homeScoreController.text) ?? 0;
              final awayScore = int.tryParse(awayScoreController.text) ?? 0;

              // Update schedule
              scheduleProvider.updateMatchResult(
                match.id,
                homeScore,
                awayScore,
              );

              // Create match model dan save ke matchProvider
              final newMatch = MatchModel(
                id: match.id,
                homeTeamId: match.homeTeamId,
                awayTeamId: match.awayTeamId,
                homeScore: homeScore,
                awayScore: awayScore,
                date: match.date,
                isPlayed: true,
              );

              try {
                await matchProvider.addMatch(newMatch);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Skor berhasil diinput & klasemen terupdate!'),
                      backgroundColor: Color(0xFF4CAF50),
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
                color: Color(0xFF0A0E1A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final MatchModel match;
  final dynamic homeTeam;
  final dynamic awayTeam;
  final VoidCallback onUpdateScore;

  const _ScheduleCard({
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.onUpdateScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1829),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Date
          Text(
            DateFormat('EEE, dd MMM yyyy • HH:mm', 'id_ID')
                .format(match.date),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Match
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (homeTeam.logoUrl != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            homeTeam.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.sports_soccer,
                              size: 20,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.sports_soccer,
                        size: 30,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      homeTeam.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'HOME',
                      style: TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              // VS
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD4AF37),
                            Color(0xFFF5D76E),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: Color(0xFF0A0E1A),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Away team
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (awayTeam.logoUrl != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.2),
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            awayTeam.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.sports_soccer,
                              size: 20,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.sports_soccer,
                        size: 30,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      awayTeam.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'AWAY',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Input score button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0A0E1A),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: onUpdateScore,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text(
                'Input Skor',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
