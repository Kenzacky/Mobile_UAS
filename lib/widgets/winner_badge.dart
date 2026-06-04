import 'package:flutter/material.dart';

/// Widget untuk menampilkan badge juara
class WinnerBadge extends StatefulWidget {
  final String teamName;
  final int position;
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
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotateAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD4AF37),
                Color(0xFFF5D76E),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy Icon
              const Text(
                '🏆',
                style: TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),

              // Position Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'JUARA ${widget.position}',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Team Name
              Text(
                widget.teamName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0A0E1A),
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),

              // Points
              Text(
                '${widget.points} Poin',
                style: TextStyle(
                  color: const Color(0xFF0A0E1A).withOpacity(0.7),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Celebratory Text
              const Text(
                '✨ Selamat! ✨',
                style: TextStyle(
                  color: Color(0xFF0A0E1A),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
