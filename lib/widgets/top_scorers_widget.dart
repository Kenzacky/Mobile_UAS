import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/top_scorers_provider.dart';

class TopScorersWidget extends StatelessWidget {
  const TopScorersWidget({super.key});

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFD4AF37); // Gold
      case 1:
        return const Color(0xFFB0B8C8); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white.withOpacity(0.3);
    }
  }

  String _getMedalEmoji(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '⚽';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TopScorersProvider>(
      builder: (ctx, scorersProvider, _) {
        final scorers = scorersProvider.topScorers;

        if (scorers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1829),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.12),
              ),
            ),
            child: Center(
              child: Text(
                'Belum ada data pencetak gol',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1829),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sports_soccer_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'TOP SCORERS',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${scorers.length} Players',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scorers.take(10).length,
                itemBuilder: (ctx, index) {
                  final scorer = scorers[index];
                  final medalColor = _getMedalColor(index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedTopScorerCard(
                      index: index,
                      rank: index + 1,
                      playerName: scorer.name,
                      goals: scorer.goals,
                      medalColor: medalColor,
                      medalEmoji: _getMedalEmoji(index),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnimatedTopScorerCard extends StatefulWidget {
  final int index;
  final int rank;
  final String playerName;
  final int goals;
  final Color medalColor;
  final String medalEmoji;

  const AnimatedTopScorerCard({
    super.key,
    required this.index,
    required this.rank,
    required this.playerName,
    required this.goals,
    required this.medalColor,
    required this.medalEmoji,
  });

  @override
  State<AnimatedTopScorerCard> createState() => _AnimatedTopScorerCardState();
}

class _AnimatedTopScorerCardState extends State<AnimatedTopScorerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      ),
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.medalColor.withOpacity(0.08),
                widget.medalColor.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.medalColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      widget.medalColor.withOpacity(0.3),
                      widget.medalColor.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: widget.medalColor,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${widget.rank}',
                  style: TextStyle(
                    color: widget.medalColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Player name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.medalEmoji} Top Scorer',
                      style: TextStyle(
                        color: widget.medalColor.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Goals badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.medalColor.withOpacity(0.7),
                      widget.medalColor.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⚽ ${widget.goals}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
