import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/match_provider.dart';
import '../services/monte_carlo_simulation.dart';
import '../models/match.dart';  // ← penting

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  bool _isLoading = false;
  Map<String, SimulationResult>? _results;

  Future<void> _runSimulation() async {
    setState(() => _isLoading = true);

    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);

    final teams = teamProvider.teams;
    final allMatches = matchProvider.matches;
    final playedMatches = allMatches.where((m) => m.isPlayed).toList();
    final remainingMatches = <MatchModel>[]; // belum ada jadwal

    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada tim untuk diprediksi')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final simulation = MonteCarloSimulation(
      teams: teams,
      playedMatches: playedMatches,
      remainingMatches: remainingMatches,
    );

    final results = await simulation.run();
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediksi Peluang')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results == null
          ? Center(
        child: ElevatedButton(
          onPressed: _runSimulation,
          child: const Text('Mulai Prediksi (1000 skenario)'),
        ),
      )
          : ListView.builder(
        itemCount: _results!.length,
        itemBuilder: (ctx, i) {
          final result = _results!.values.elementAt(i);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              title: Text(result.teamName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: result.championshipPercent / 100,
                    color: Colors.green,
                  ),
                  Text('Juara: ${result.championshipPercent.toStringAsFixed(1)}%'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: result.relegationPercent / 100,
                    color: Colors.red,
                  ),
                  Text('Degradasi: ${result.relegationPercent.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}