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
  // Pastikan Flutter binding sudah di-initialize sebelum Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal lokal (Indonesia)
  // PENTING: Harus sebelum Firebase initialize
  try {
    await initializeDateFormatting('id_ID', null);
    Intl.defaultLocale = 'id_ID';
  } catch (e) {
    debugPrint('Intl initialization error: $e');
  }

  // Inisialisasi Firebase dengan konfigurasi platform
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
      // Mendefinisikan semua providers yang digunakan di seluruh aplikasi
      providers: [
        // Auth Provider: Mengelola state login/register pengguna
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Team Provider: Mengelola data tim
        ChangeNotifierProvider(create: (_) => TeamProvider()),

        // Match Provider: Mengelola data pertandingan
        ChangeNotifierProvider(create: (_) => MatchProvider()),

        // Schedule Provider: Mengelola jadwal pertandingan (bergantung pada TeamProvider)
        ChangeNotifierProxyProvider<TeamProvider, ScheduleProvider>(
          create: (context) => ScheduleProvider(
            Provider.of<TeamProvider>(context, listen: false),
          ),
          update: (context, teamProvider, previous) =>
          previous ?? ScheduleProvider(teamProvider),
        ),

        // Standing Provider: Mengelola klasemen (bergantung pada TeamProvider & MatchProvider)
        ChangeNotifierProxyProvider2<TeamProvider, MatchProvider,
            StandingProvider>(
          create: (context) => StandingProvider(
            Provider.of<TeamProvider>(context, listen: false),
            Provider.of<MatchProvider>(context, listen: false),
          ),
          update: (context, teamProvider, matchProvider, previous) =>
          previous ?? StandingProvider(teamProvider, matchProvider),
        ),

        // Statistics Provider: Mengelola statistik (bergantung pada MatchProvider & TeamProvider)
        ChangeNotifierProxyProvider2<MatchProvider, TeamProvider,
            StatisticsProvider>(
          create: (context) => StatisticsProvider(
            Provider.of<MatchProvider>(context, listen: false),
            Provider.of<TeamProvider>(context, listen: false),
          ),
          update: (context, matchProvider, teamProvider, previous) =>
          previous ?? StatisticsProvider(matchProvider, teamProvider),
        ),

        // Top Scorers Provider: Mengelola data top pencetak gol (bergantung pada MatchProvider)
        ChangeNotifierProxyProvider<MatchProvider, TopScorersProvider>(
          create: (context) => TopScorersProvider(
            Provider.of<MatchProvider>(context, listen: false),
          ),
          update: (context, matchProvider, previous) =>
          previous ?? TopScorersProvider(matchProvider),
        ),

        // European Leagues Provider: Mengelola data liga Eropa
        ChangeNotifierProvider(
          create: (_) => EuropeanLeaguesProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'LigaKita',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          // Set warna background default untuk semua scaffold
          scaffoldBackgroundColor: const Color(0xFF060B18),
        ),
        // Route awal ketika aplikasi dibuka
        initialRoute: '/',
        // Mendefinisikan semua route aplikasi
        routes: {
          '/': (context) => const SplashScreen(),          // Splash/Loading screen
          '/login': (context) => const LoginScreen(),      // Login & Register screen
          '/home': (context) => const HomeScreen(),        // Home/Dashboard screen
          '/european-leagues': (context) => const EuropeanLeaguesScreen(), // European leagues screen
        },
      ),
    );
  }
}