import 'package:flutter/material.dart';

class WinnerBadge extends StatefulWidget {
  final String teamName;
  final int position; // 1, 2, 3
  final String? logoUrl;
  final int points;

  const WinnerBadge({
    super.key,
    required this.teamName,
    required this.position,
    this.logoUrl,
    required this.points,
  });

  @override
  State<WinnerBadge> createState() => _WinnerBadgeState();
}

class _WinnerBadgeState extends State<WinnerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getMedalColor() {
    switch (widget.position) {
      case 1:
        return const Color(0xFFD4AF37); // Gold
      case 2:
        return const Color(0xFFB0B8C8); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  String _getMedalEmoji() {
    switch (widget.position) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏅';
    }
  }

  String _getPositionText() {
    switch (widget.position) {
      case 1:
        return 'JUARA 🎉';
      case 2:
        return 'RUNNER UP';
      case 3:
        return 'PODIUM';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getMedalColor().withOpacity(0.2),
                    _getMedalColor().withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getMedalColor(),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getMedalColor().withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getMedalEmoji(),
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.teamName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPositionText(),
                    style: TextStyle(
                      color: _getMedalColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getMedalColor(),
                          _getMedalColor().withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.points} Poin',
                      style: const TextStyle(
                        color: Color(0xFF0A0E1A),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
