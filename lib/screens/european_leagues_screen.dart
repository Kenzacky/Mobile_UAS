import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/european_leagues_provider.dart';
import '../services/european_leagues_service.dart';

/// Screen untuk menampilkan European Top Leagues
/// Cross-platform: Android, iOS, Windows, Web
class EuropeanLeaguesScreen extends StatefulWidget {
  const EuropeanLeaguesScreen({super.key});

  @override
  State<EuropeanLeaguesScreen> createState() => _EuropeanLeaguesScreenState();
}

class _EuropeanLeaguesScreenState extends State<EuropeanLeaguesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EuropeanLeaguesProvider>().fetchAllLeagueData();
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
      appBar: AppBar(
        title: const Text('🏆 European Leagues'),
        elevation: 0,
        backgroundColor: Colors.green[700],
      ),
      body: Consumer<EuropeanLeaguesProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // League Selector
              Container(
                color: Colors.green[700],
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.availableLeagues.length,
                    itemBuilder: (context, index) {
                      final league = provider.availableLeagues[index];
                      final isSelected =
                          league.code == provider.selectedLeagueCode;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            provider.selectLeague(league.code);
                            _tabController.index = 0;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Colors.white
                                : Colors.green[600],
                            foregroundColor: isSelected
                                ? Colors.green[700]
                                : Colors.white,
                          ),
                          child: Text(
                            league.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Tab Bar
              Container(
                color: Colors.green[600],
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '📊 Standings'),
                    Tab(text: '📅 Upcoming'),
                    Tab(text: '✅ Results'),
                    Tab(text: '⚽ Top Scorers'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.green[100],
                ),
              ),

              // Tab Content
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('❌ ${provider.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.fetchAllLeagueData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    // Standings Tab
                    _buildStandingsTab(context, provider),

                    // Upcoming Matches Tab
                    _buildUpcomingTab(context, provider),

                    // Completed Matches Tab
                    _buildResultsTab(context, provider),

                    // Top Scorers Tab
                    _buildTopScorersTab(context, provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<EuropeanLeaguesProvider>().refreshData();
        },
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStandingsTab(
      BuildContext context,
      EuropeanLeaguesProvider provider,
      ) {
    if (provider.standings.isEmpty) {
      return const Center(child: Text('No standings data'));
    }

    return ListView.builder(
      itemCount: provider.standings.length,
      itemBuilder: (context, index) {
        final standing = provider.standings[index];
        final position = index + 1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('$position'),
            ),
            title: Text(standing.teamName),
            subtitle: Text('Pts: ${standing.points} | GP: ${standing.playedGames}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${standing.won}W'),
                Text('${standing.draw}D'),
                Text('${standing.lost}L'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingTab(
      BuildContext context,
      EuropeanLeaguesProvider provider,
      ) {
    if (provider.upcomingMatches.isEmpty) {
      return const Center(child: Text('No upcoming matches'));
    }

    return ListView.builder(
      itemCount: provider.upcomingMatches.length,
      itemBuilder: (context, index) {
        final match = provider.upcomingMatches[index];
        final homeTeam = match['homeTeam']['name'];
        final awayTeam = match['awayTeam']['name'];
        final utcDate = match['utcDate'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('$homeTeam vs $awayTeam'),
            subtitle: Text(utcDate),
            trailing: const Icon(Icons.schedule),
          ),
        );
      },
    );
  }

  Widget _buildResultsTab(
      BuildContext context,
      EuropeanLeaguesProvider provider,
      ) {
    if (provider.completedMatches.isEmpty) {
      return const Center(child: Text('No completed matches'));
    }

    return ListView.builder(
      itemCount: provider.completedMatches.length,
      itemBuilder: (context, index) {
        final match = provider.completedMatches[index];
        final homeTeam = match['homeTeam']['name'];
        final awayTeam = match['awayTeam']['name'];
        final score = match['score']['fullTime'];
        final homeScore = score['home'];
        final awayScore = score['away'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('$homeTeam vs $awayTeam'),
            subtitle: Text('Score: $homeScore - $awayScore'),
            trailing: const Icon(Icons.check_circle),
          ),
        );
      },
    );
  }

  Widget _buildTopScorersTab(
      BuildContext context,
      EuropeanLeaguesProvider provider,
      ) {
    if (provider.topScorers.isEmpty) {
      return const Center(child: Text('No scorers data'));
    }

    return ListView.builder(
      itemCount: provider.topScorers.length,
      itemBuilder: (context, index) {
        final scorer = provider.topScorers[index];
        final playerName = scorer['player']['name'];
        final teamName = scorer['team']['name'];
        final goals = scorer['goals'];
        final position = index + 1;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('$position'),
            ),
            title: Text(playerName),
            subtitle: Text(teamName),
            trailing: Text(
              '$goals ⚽',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
