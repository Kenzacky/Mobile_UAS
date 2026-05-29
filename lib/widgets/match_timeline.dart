import 'package:flutter/material.dart';
import '../models/match_event.dart';

class MatchTimeline extends StatelessWidget {
  final String matchTitle;
  final List<MatchEvent> events;
  final String homeTeamId;
  final String awayTeamId;

  const MatchTimeline({
    super.key,
    required this.matchTitle,
    required this.events,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  Color _getTeamColor(String teamId) {
    return teamId == homeTeamId
        ? const Color(0xFF4ECDC4)
        : const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1829),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37).withAlpha(31), // 0.12*255
          ),
        ),
        child: Center(
          child: Text(
            'Belum ada kejadian dalam pertandingan',
            style: TextStyle(
              color: Colors.white.withAlpha(128), // 0.5*255
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withAlpha(31), // 0.12*255
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
              const SizedBox(width: 10),
              const Text(
                'MATCH TIMELINE',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '${events.length} Events',
                style: TextStyle(
                  color: Colors.white.withAlpha(102), // 0.4*255
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            events.length,
                (index) {
              final event = events[index];
              final isLast = index == events.length - 1;
              final teamColor = _getTeamColor(event.teamId);

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              teamColor.withAlpha(77), // 0.3*255
                              teamColor.withAlpha(26), // 0.1*255
                            ],
                          ),
                          border: Border.all(
                            color: teamColor,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            event.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Event details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.playerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getEventDescription(event),
                              style: TextStyle(
                                color: Colors.white.withAlpha(128), // 0.5*255
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Minute badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              teamColor.withAlpha(179), // 0.7*255
                              teamColor.withAlpha(128), // 0.5*255
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${event.minute}'",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 19, top: 8, bottom: 8),
                      child: Container(
                        width: 2,
                        height: 24,
                        color: teamColor.withAlpha(77), // 0.3*255
                      ),
                    )
                  else
                    const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _getEventDescription(MatchEvent event) {
    switch (event.type) {
      case 'goal':
        return 'Goal';
      case 'yellowCard':
        return 'Yellow Card';
      case 'redCard':
        return 'Red Card';
      case 'substitution':
        return 'Substitution';
      default:
        return event.description ?? 'Event';
    }
  }
}
