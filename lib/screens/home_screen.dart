import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/standing_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/top_scorers_provider.dart';
import '../providers/team_provider.dart';
import '../providers/match_provider.dart';
import 'standing_screen.dart';
import 'team_list_screen.dart';
import 'real_league_screen.dart';
import 'schedule_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1020),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFA8892A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 22,
                color: Color(0xFF0A0E1A),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
                      fontSize: 22,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                Text(
                  'Professional League',
                  style: TextStyle(
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  content: Text(
                    'Yakin ingin keluar dari aplikasi?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.w700,
                        ),
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
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1829),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
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
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  labelColor: const Color(0xFF0A0E1A),
                  unselectedLabelColor: Colors.white.withOpacity(0.45),
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.emoji_events_rounded, size: 18),
                      text: 'Klasemen',
                    ),
                    Tab(
                      icon: Icon(Icons.calendar_today_rounded, size: 18),
                      text: 'Jadwal',
                    ),
                    Tab(
                      icon: Icon(Icons.assessment_rounded, size: 18),
                      text: 'Statistik',
                    ),
                    Tab(
                      icon: Icon(Icons.groups_rounded, size: 18),
                      text: 'Tim',
                    ),
                    Tab(
                      icon: Icon(Icons.sports_soccer_rounded, size: 18),
                      text: 'Match',
                    ),
                    Tab(
                      icon: Icon(Icons.public_rounded, size: 18),
                      text: 'Liga Asli',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Klasemen
          _buildTabContent(
            index: 0,
            child: StandingScreen(),
          ),
          // Tab 2: Jadwal
          _buildTabContent(
            index: 1,
            child: ScheduleScreen(),
          ),
          // Tab 3: Statistik
          _buildTabContent(
            index: 2,
            child: StatisticsScreen(),
          ),
          // Tab 4: Tim
          _buildTabContent(
            index: 3,
            child: TeamListScreen(),
          ),
          // Tab 5: Match (diganti ke schedule screen)
          _buildTabContent(
            index: 4,
            child: ScheduleScreen(),
          ),
          // Tab 6: Liga Asli
          _buildTabContent(
            index: 5,
            child: RealLeagueScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required int index,
    required Widget child,
  }) {
    return AnimatedOpacity(
      opacity: _currentTabIndex == index ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: _currentTabIndex == index
          ? child
          : SizedBox.expand(
              child: Container(
                color: const Color(0xFF060B18),
              ),
            ),
    );
  }
}
