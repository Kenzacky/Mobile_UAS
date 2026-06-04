import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/standing_provider.dart';
import '../providers/season_provider.dart';
import '../models/standing.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/winner_badge.dart';
import '../widgets/animated_stat_card.dart';

class ChampionCelebrationScreen extends StatefulWidget {
  final TeamStanding champion;

  const ChampionCelebrationScreen({
    super.key,
    required this.champion,
  });

  @override
  State<ChampionCelebrationScreen> createState() =>
      _ChampionCelebrationScreenState();
}

class _ChampionCelebrationScreenState extends State<ChampionCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _pulseController;
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _completeSeasonAndShowWinner(BuildContext context) async {
    try {
      final seasonProvider =
      Provider.of<SeasonProvider>(context, listen: false);

      // Complete season dengan data pemenang
      await seasonProvider.completeCurrentSeason(
        winnerId: widget.champion.teamId,
        winnerName: widget.champion.teamName,
        statistics: {
          'totalMatches': widget.champion.played,
          'championPoints': widget.champion.points,
          'championGoals': widget.champion.goalsFor,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Season selesai! Klasemen direset untuk season baru.',
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back setelah delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F1829),
                  Color(0xFF1a2a4a),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Champion Badge dengan animasi
                  ScaleTransition(
                    scale: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _celebrationController,
                        curve: const Interval(0, 0.4,
                            curve: Curves.elasticOut),
                      ),
                    ),
                    child: WinnerBadge(
                      teamName: widget.champion.teamName,
                      position: 1,
                      logoUrl: widget.champion.logoUrl,
                      points: widget.champion.points,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Celebration message
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _celebrationController,
                        curve: const Interval(0.3, 0.7,
                            curve: Curves.easeOut),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🎊 SELAMAT! 🎊',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.champion.teamName} adalah\nJUARA MUSIM INI!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Stats cards
                  FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _celebrationController,
                        curve: const Interval(0.5, 1,
                            curve: Curves.easeOut),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedStatCard(
                                label: 'Pertandingan',
                                value: '${widget.champion.played}',
                                color: const Color(0xFFD4AF37),
                                icon: Icons.sports_soccer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedStatCard(
                                label: 'Kemenangan',
                                value: '${widget.champion.won}',
                                color: const Color(0xFF4CAF50),
                                icon: Icons.emoji_events,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedStatCard(
                                label: 'Goal Pencetak',
                                value: '${widget.champion.goalsFor}',
                                color: const Color(0xFF00BCD4),
                                icon: Icons.whatshot,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedStatCard(
                                label: 'Total Poin',
                                value: '${widget.champion.points}',
                                color: const Color(0xFFD4AF37),
                                icon: Icons.star,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Buttons
                  ScaleTransition(
                    scale: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _celebrationController,
                        curve: const Interval(0.7, 1,
                            curve: Curves.easeOut),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Confetti button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF0A0E1A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 8,
                            ),
                            onPressed: () {
                              setState(() {
                                _showConfetti = true;
                              });
                              Future.delayed(const Duration(seconds: 5), () {
                                if (mounted) {
                                  setState(() {
                                    _showConfetti = false;
                                  });
                                }
                              });
                            },
                            icon: const Icon(Icons.celebration, size: 24),
                            label: const Text(
                              '🎉 RAYAKAN LAGI!',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Season selesai button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              _completeSeasonAndShowWinner(context);
                            },
                            icon: const Icon(Icons.check_circle, size: 24),
                            label: const Text(
                              'SELESAI MUSIM INI',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Back button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFD4AF37),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFFD4AF37),
                            ),
                            label: const Text(
                              'KEMBALI',
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti animation
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: ConfettiWidget(
                  autoStart: true,
                  duration: const Duration(seconds: 5),
                  particleCount: 40,
                  colors: const [
                    Color(0xFFD4AF37),
                    Color(0xFFFF6B6B),
                    Color(0xFF4CAF50),
                    Color(0xFF00BCD4),
                    Color(0xFFFFD700),
                    Color(0xFF9C27B0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
