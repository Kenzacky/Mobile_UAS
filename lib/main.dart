import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/team_provider.dart';
import 'providers/match_provider.dart';
import 'providers/standing_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/top_scorers_provider.dart';
import 'providers/european_leagues_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/european_leagues_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ PENTING: Initialize intl SEBELUM Firebase
  try {
    await initializeDateFormatting('id_ID', null);
    Intl.defaultLocale = 'id_ID';
  } catch (e) {
    debugPrint('Intl initialization error: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Team Provider
        ChangeNotifierProvider(create: (_) => TeamProvider()),

        // Match Provider
        ChangeNotifierProvider(create: (_) => MatchProvider()),

        // Schedule Provider
        ChangeNotifierProxyProvider<TeamProvider, ScheduleProvider>(
          create: (context) => ScheduleProvider(
            Provider.of<TeamProvider>(context, listen: false),
          ),
          update: (context, teamProvider, previous) =>
          previous ?? ScheduleProvider(teamProvider),
        ),

        // Standing Provider
        ChangeNotifierProxyProvider2<TeamProvider, MatchProvider,
            StandingProvider>(
          create: (context) => StandingProvider(
            Provider.of<TeamProvider>(context, listen: false),
            Provider.of<MatchProvider>(context, listen: false),
          ),
          update: (context, teamProvider, matchProvider, previous) =>
          previous ?? StandingProvider(teamProvider, matchProvider),
        ),

        // Statistics Provider
        ChangeNotifierProxyProvider2<MatchProvider, TeamProvider,
            StatisticsProvider>(
          create: (context) => StatisticsProvider(
            Provider.of<MatchProvider>(context, listen: false),
            Provider.of<TeamProvider>(context, listen: false),
          ),
          update: (context, matchProvider, teamProvider, previous) =>
          previous ?? StatisticsProvider(matchProvider, teamProvider),
        ),

        // Top Scorers Provider
        ChangeNotifierProxyProvider<MatchProvider, TopScorersProvider>(
          create: (context) => TopScorersProvider(
            Provider.of<MatchProvider>(context, listen: false),
          ),
          update: (context, matchProvider, previous) =>
          previous ?? TopScorersProvider(matchProvider),
        ),

        // European Leagues Provider
        ChangeNotifierProvider(
          create: (_) => EuropeanLeaguesProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'LigaKita',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/european-leagues': (context) => const EuropeanLeaguesScreen(),
        },
      ),
    );
  }
}
