import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import 'add_match_screen.dart';

class MatchListScreen extends StatelessWidget {
  const MatchListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchProvider = Provider.of<MatchProvider>(context);
    final teamProvider = Provider.of<TeamProvider>(context);
    final matches = matchProvider.matches;

    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMatchScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFD4AF37),
      ),
      body: matches.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              'Belum ada pertandingan',
              style: TextStyle(color: Colors.white38),
            ),
            SizedBox(height: 8),
            Text(
              'Tekan + untuk mencatat pertandingan baru',
              style: TextStyle(color: Colors.white24),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: matches.length,
        itemBuilder: (ctx, i) {
          final match = matches[i];
          final homeTeam = teamProvider.getTeamById(match.homeTeamId);
          final awayTeam = teamProvider.getTeamById(match.awayTeamId);
          if (homeTeam == null || awayTeam == null) return const SizedBox.shrink();
          return Card(
            color: const Color(0xFF0F1829),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: const Color(0xFFD4AF37).withAlpha(20)), // ganti withOpacity
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.sports_soccer, color: Color(0xFFD4AF37)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      homeTeam.name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${match.homeScore} - ${match.awayScore}',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      awayTeam.name,
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${match.date.day}/${match.date.month}/${match.date.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddMatchScreen(match: match)),
                    );
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Hapus pertandingan?'),
                        content: const Text('Data pertandingan akan dihapus secara permanen'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await matchProvider.deleteMatch(match.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pertandingan dihapus')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}