import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/team.dart';
import '../models/standing.dart'; // IMPORT TeamStanding
import '../providers/team_provider.dart';
import '../providers/match_provider.dart';
import '../providers/standing_provider.dart';
import 'head_to_head_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;
  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  List<FlSpot> _weeklyPointsSpots = [];

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  void _loadPerformanceData() {
    final matches = Provider.of<MatchProvider>(context, listen: false).matches
        .where((m) => m.isPlayed)
        .toList();
    // Urutkan berdasarkan tanggal
    final sortedMatches = List.of(matches)..sort((a, b) => a.date.compareTo(b.date));

    // Kelompokkan per minggu (setiap 7 hari, mulai dari tanggal pertama)
    final Map<DateTime, int> weeklyPoints = {};
    for (var match in sortedMatches) {
      if (match.homeTeamId == widget.team.id || match.awayTeamId == widget.team.id) {
        final DateTime weekStart = DateTime(match.date.year, match.date.month, match.date.day - match.date.weekday);
        int points = 0;
        if (match.homeTeamId == widget.team.id) {
          if (match.homeScore > match.awayScore) points = 3;
          else if (match.homeScore == match.awayScore) points = 1;
        } else {
          if (match.awayScore > match.homeScore) points = 3;
          else if (match.homeScore == match.awayScore) points = 1;
        }
        weeklyPoints[weekStart] = (weeklyPoints[weekStart] ?? 0) + points;
      }
    }
    final List<FlSpot> spots = [];
    int index = 0;
    weeklyPoints.forEach((week, points) {
      spots.add(FlSpot(index.toDouble(), points.toDouble()));
      index++;
    });
    setState(() {
      _weeklyPointsSpots = spots;
    });
  }

  @override
  Widget build(BuildContext context) {
    final standingProvider = Provider.of<StandingProvider>(context);
    TeamStanding? teamStanding;
    try {
      teamStanding = standingProvider.standings.firstWhere((s) => s.teamId == widget.team.id);
    } catch (e) {
      teamStanding = TeamStanding(teamId: widget.team.id, teamName: widget.team.name, logoUrl: widget.team.logoUrl);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.team.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: widget.team.id,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.team.logoUrl != null ? NetworkImage(widget.team.logoUrl!) : null,
                  child: widget.team.logoUrl == null ? const Icon(Icons.sports_soccer, size: 50) : null,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildStatCards(teamStanding),
            const SizedBox(height: 24),
            const Text('Grafik Poin per Minggu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _weeklyPointsSpots.isEmpty
                ? const Center(child: Text('Belum ada data pertandingan'))
                : SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weeklyPointsSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showHeadToHeadDialog(context),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Bandingkan dengan tim lain'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(TeamStanding standing) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn('Pertandingan', standing.played.toString()),
                _statColumn('Menang', standing.won.toString()),
                _statColumn('Seri', standing.draw.toString()),
                _statColumn('Kalah', standing.lost.toString()),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statColumn('Gol Masuk', standing.goalsFor.toString()),
                _statColumn('Gol Kebobolan', standing.goalsAgainst.toString()),
                _statColumn('Selisih', standing.goalDifference.toString()),
                _statColumn('Poin', standing.points.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showHeadToHeadDialog(BuildContext context) {
    final teams = Provider.of<TeamProvider>(context, listen: false).teams;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pilih tim lawan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: teams.length,
            itemBuilder: (ctx, idx) {
              final t = teams[idx];
              if (t.id == widget.team.id) return const SizedBox.shrink();
              return ListTile(
                title: Text(t.name),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HeadToHeadScreen(teamA: widget.team, teamB: t),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}