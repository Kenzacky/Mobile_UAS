import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/team.dart';
import '../providers/match_provider.dart';

class HeadToHeadScreen extends StatelessWidget {
  final Team teamA;
  final Team teamB;
  const HeadToHeadScreen({super.key, required this.teamA, required this.teamB});

  @override
  Widget build(BuildContext context) {
    final matches = Provider.of<MatchProvider>(context).matches.where((m) => m.isPlayed).toList();
    int winA = 0, winB = 0, draw = 0, goalsA = 0, goalsB = 0;
    for (var m in matches) {
      if ((m.homeTeamId == teamA.id && m.awayTeamId == teamB.id) ||
          (m.homeTeamId == teamB.id && m.awayTeamId == teamA.id)) {
        final bool isHomeA = m.homeTeamId == teamA.id;
        final int scoreA = isHomeA ? m.homeScore : m.awayScore;
        final int scoreB = isHomeA ? m.awayScore : m.homeScore;
        goalsA += scoreA;
        goalsB += scoreB;
        if (scoreA > scoreB) {
          winA++;
        } else if (scoreA < scoreB) {
          winB++;
        } else {
          draw++;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(title: Text('${teamA.name} vs ${teamB.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Total Pertemuan: ${winA + winB + draw}'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statBox(teamA.name, winA, Colors.green),
                        _statBox('Seri', draw, Colors.grey),
                        _statBox(teamB.name, winB, Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Gol:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('$teamA.name: $goalsA', style: const TextStyle(fontSize: 18)),
                        Text('$teamB.name: $goalsB', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(toY: goalsA.toDouble(), color: Colors.green, width: 20),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(toY: goalsB.toDouble(), color: Colors.orange, width: 20),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  return Text(value.toInt() == 0 ? teamA.name : teamB.name);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(count.toString(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }
}