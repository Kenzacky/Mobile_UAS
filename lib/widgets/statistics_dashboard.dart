import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import 'animated_stat_card.dart';

class StatisticsDashboard extends StatelessWidget {
  const StatisticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (ctx, statsProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F1829), Color(0xFF132040)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.assessment_rounded,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'STATISTIK LIGA',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${statsProvider.totalMatches} Matches',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  AnimatedStatCard(
                    label: 'Total Goals',
                    value: statsProvider.totalGoals.toString(),
                    color: const Color(0xFF4CAF50),
                    icon: Icons.sports_soccer,
                  ),
                  AnimatedStatCard(
                    label: 'Avg Goals/Match',
                    value: statsProvider.averageGoalsPerMatch
                        .toStringAsFixed(1),
                    color: const Color(0xFF2196F3),
                    icon: Icons.show_chart,
                  ),
                  AnimatedStatCard(
                    label: 'Total Wins',
                    value: statsProvider.totalWins.toString(),
                    color: const Color(0xFF4CAF50),
                    icon: Icons.emoji_events,
                  ),
                  AnimatedStatCard(
                    label: 'Total Draws',
                    value: statsProvider.totalDraws.toString(),
                    color: const Color(0xFFFFC107),
                    icon: Icons.handshake,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Highest scoring match
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B6B).withOpacity(0.1),
                      const Color(0xFFFF6B6B).withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B6B).withOpacity(0.3),
                            const Color(0xFFFF6B6B).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.fire_truck_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Highest Scoring Match',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${statsProvider.highestScoringMatch} Goals',
                            style: const TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Goal distribution
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1829),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Goal Distribution',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _GoalDistributionBar(
                      label: '0-1 Goals',
                      count: statsProvider.goalDistribution[0],
                      total: statsProvider.totalMatches,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 10),
                    _GoalDistributionBar(
                      label: '2-3 Goals',
                      count: statsProvider.goalDistribution[1],
                      total: statsProvider.totalMatches,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 10),
                    _GoalDistributionBar(
                      label: '4-5 Goals',
                      count: statsProvider.goalDistribution[2],
                      total: statsProvider.totalMatches,
                      color: const Color(0xFFFFC107),
                    ),
                    const SizedBox(height: 10),
                    _GoalDistributionBar(
                      label: '6-7 Goals',
                      count: statsProvider.goalDistribution[3],
                      total: statsProvider.totalMatches,
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 10),
                    _GoalDistributionBar(
                      label: '8+ Goals',
                      count: statsProvider.goalDistribution[4],
                      total: statsProvider.totalMatches,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoalDistributionBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _GoalDistributionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0.0 : count / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
