import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'standing_screen.dart';
import 'team_list_screen.dart';
import 'real_league_screen.dart';
import 'match_list_screen.dart'; // akan kita buat

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // ← sekarang ada 4 tab
      child: Scaffold(
        backgroundColor: const Color(0xFF060B18),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A1020),
          elevation: 0,
          centerTitle: false,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFA8892A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_soccer,
                  size: 18,
                  color: Color(0xFF0A0E1A),
                ),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                ).createShader(bounds),
                child: const Text(
                  'LIGAKITA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 18,
                ),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF0F1829),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                      ),
                    ),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: Text(
                      'Yakin ingin keluar dari aplikasi?',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Batal',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Color(0xFFD4AF37)),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1829),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.12),
                ),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: const Color(0xFF0A0E1A),
                unselectedLabelColor: Colors.white.withOpacity(0.45),
                labelStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(icon: Icon(Icons.emoji_events_rounded, size: 18), text: 'Klasemen'),
                  Tab(icon: Icon(Icons.groups_rounded, size: 18), text: 'Tim'),
                  Tab(icon: Icon(Icons.public_rounded, size: 18), text: 'Liga Asli'),
                  Tab(icon: Icon(Icons.sports_soccer_rounded, size: 18), text: 'Pertandingan'),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            StandingScreen(),
            TeamListScreen(),
            RealLeagueScreen(),
            MatchListScreen(), // ← halaman daftar pertandingan
          ],
        ),
      ),
    );
  }
}