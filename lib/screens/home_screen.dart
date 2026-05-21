// lib/screens/home_screen.dart (ULTRA MODERN VERSION - FIXED)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/standing_provider.dart';
import '../providers/team_provider.dart';
import 'standing_screen.dart';
import 'schedule_screen.dart';
import 'statistics_screen.dart';
import 'team_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF0A1020),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderBackground(),
                collapseMode: CollapseMode.parallax,
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Tab Navigation
            Container(
              color: const Color(0xFF0A1020),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1829),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withAlpha(30), // withOpacity -> withAlpha
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withAlpha(51), // 0.2*255
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    labelColor: const Color(0xFF0A0E1A),
                    unselectedLabelColor: Colors.white.withAlpha(115), // 0.45*255
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabs: const [
                      Tab(icon: Icon(Icons.home_rounded, size: 18), text: 'Home'),
                      Tab(icon: Icon(Icons.emoji_events_rounded, size: 18), text: 'Klasemen'),
                      Tab(icon: Icon(Icons.calendar_today_rounded, size: 18), text: 'Jadwal'),
                      Tab(icon: Icon(Icons.assessment_rounded, size: 18), text: 'Statistik'),
                      Tab(icon: Icon(Icons.groups_rounded, size: 18), text: 'Tim'),
                    ],
                  ),
                ),
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboard(),
                  const StandingScreen(),
                  const ScheduleScreen(),
                  const StatisticsScreen(),
                  const TeamListScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A1020),
            const Color(0xFF132040),
            Colors.green[900] ?? const Color(0xFF1B5E20),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header Top
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFA8892A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withAlpha(102), // 0.4*255
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 28,
                        color: Color(0xFF0A0E1A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                          ).createShader(bounds),
                          child: const Text(
                            'LIGAKITA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        Text(
                          'League Management Pro',
                          style: TextStyle(
                            color: const Color(0xFFD4AF37).withAlpha(153), // 0.6*255
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withAlpha(77), // 0.3*255
                      ),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white.withAlpha(153), // 0.6*255
                      size: 18,
                    ),
                  ),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
          ),
          // Quick Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Consumer<StandingProvider>(
              builder: (ctx, standingProvider, _) {
                final standings = standingProvider.standings;
                if (standings.isEmpty) {
                  return const SizedBox.shrink();
                }
                final topTeam = standings[0];
                final totalMatches = standings.fold<int>(
                  0,
                      (sum, team) => sum + team.played,
                );
                final totalGoals = standings.fold<int>(
                  0,
                      (sum, team) => sum + team.goalsFor,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Teams', standings.length.toString()),
                    _buildStatCard('Matches', totalMatches.toString()),
                    _buildStatCard('Goals', totalGoals.toString()),
                    _buildStatCard('Leader', topTeam.teamName.split(' ').first),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(153), // 0.6*255
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNextMatchCard(),
          const SizedBox(height: 24),
          _buildTopTeamsCard(),
          const SizedBox(height: 24),
          _buildQuickActionsCard(),
          const SizedBox(height: 24),
          _buildRecentMatchesCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNextMatchCard() {
    return Consumer2<ScheduleProvider, TeamProvider>(
      builder: (ctx, scheduleProvider, teamProvider, _) {
        final upcoming = scheduleProvider.getUpcomingMatches();
        if (upcoming.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1829),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withAlpha(30),
              ),
            ),
            child: Center(
              child: Text(
                'Semua pertandingan selesai',
                style: TextStyle(
                  color: Colors.white.withAlpha(128),
                ),
              ),
            ),
          );
        }
        final nextMatch = upcoming.first;
        final homeTeam = teamProvider.getTeamById(nextMatch.homeTeamId);
        final awayTeam = teamProvider.getTeamById(nextMatch.awayTeamId);
        final homeTeamName = homeTeam?.name ?? 'Unknown';
        final awayTeamName = awayTeam?.name ?? 'Unknown';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD4AF37).withAlpha(25), // 0.1*255
                const Color(0xFFD4AF37).withAlpha(5),  // 0.02*255
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withAlpha(51),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withAlpha(25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔔 PERTANDINGAN BERIKUTNYA',
                style: TextStyle(
                  color: const Color(0xFFD4AF37),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          homeTeamName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🏠 HOME',
                          style: TextStyle(
                            color: Colors.cyan.withAlpha(179),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            color: Color(0xFF0A0E1A),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          awayTeamName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '✈️ AWAY',
                          style: TextStyle(
                            color: Colors.red.withAlpha(179),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0A0E1A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _tabController.animateTo(2);
                  },
                  child: const Text(
                    'Lihat Jadwal Lengkap',
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
      },
    );
  }

  Widget _buildTopTeamsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1829),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withAlpha(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 10),
              const Text(
                'TOP TEAMS',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<StandingProvider>(
            builder: (ctx, standingProvider, _) {
              final standings = standingProvider.standings.take(3).toList();
              if (standings.isEmpty) {
                return Text(
                  'Belum ada data',
                  style: TextStyle(color: Colors.white.withAlpha(128)),
                );
              }
              return Column(
                children: List.generate(standings.length, (index) {
                  final team = standings[index];
                  const medals = ['🥇', '🥈', '🥉'];
                  const colors = [Color(0xFFD4AF37), Color(0xFFB0B8C8), Color(0xFFCD7F32)];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Text(medals[index], style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            team.teamName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colors[index].withAlpha(179),
                                colors[index].withAlpha(128),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${team.points} Pts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.calendar_today_rounded,
            label: 'Jadwal',
            onTap: () => _tabController.animateTo(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.assessment_rounded,
            label: 'Statistik',
            onTap: () => _tabController.animateTo(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.groups_rounded,
            label: 'Tim',
            onTap: () => _tabController.animateTo(4),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD4AF37).withAlpha(25),
              const Color(0xFFD4AF37).withAlpha(5),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD4AF37).withAlpha(51),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMatchesCard() {
    return Consumer2<ScheduleProvider, TeamProvider>(
      builder: (ctx, scheduleProvider, teamProvider, _) {
        final played = scheduleProvider.getPlayedMatches().take(3).toList();
        if (played.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1829),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withAlpha(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_rounded, color: Color(0xFFD4AF37), size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'RECENT MATCHES',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: played.map((match) {
                  final homeTeam = teamProvider.getTeamById(match.homeTeamId);
                  final awayTeam = teamProvider.getTeamById(match.awayTeamId);
                  final homeTeamName = homeTeam?.name ?? 'Unknown';
                  final awayTeamName = awayTeam?.name ?? 'Unknown';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                homeTeamName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                awayTeamName,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(153),
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${match.homeScore} - ${match.awayScore}',
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1829),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color(0xFFD4AF37).withAlpha(51),
          ),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.white.withAlpha(128), fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}