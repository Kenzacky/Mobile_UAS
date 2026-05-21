import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../providers/top_scorers_provider.dart';
import '../widgets/statistics_dashboard.dart';
import '../widgets/top_scorers_widget.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StatisticsProvider(
            Provider.of<MatchProvider>(context, listen: false),
            Provider.of<TeamProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TopScorersProvider(
            Provider.of<MatchProvider>(context, listen: false),
          ),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF060B18),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TopScorersWidget(),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: StatisticsDashboard(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
