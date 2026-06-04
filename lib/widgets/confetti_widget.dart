import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom Confetti Animation Widget - Tanpa External Package
/// Membuat animasi kembang api/confetti celebration
class ConfettiWidget extends StatefulWidget {
  final bool autoStart;
  final Duration duration;
  final VoidCallback? onComplete;
  final int particleCount;
  final List<Color> colors;

  const ConfettiWidget({
    super.key,
    this.autoStart = true,
    this.duration = const Duration(seconds: 4),
    this.onComplete,
    this.particleCount = 40,
    this.colors = const [
      Color(0xFFD4AF37),
      Color(0xFFFF6B6B),
      Color(0xFF4CAF50),
      Color(0xFF00BCD4),
      Color(0xFFFFD700),
      Color(0xFF9C27B0),
    ],
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.autoStart) {
      _controller.forward();
    }

    _controller.addListener(() {
      if (!_controller.isAnimating && _controller.isCompleted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            progress: _progressAnimation.value,
            numberOfParticles: widget.particleCount,
            colors: widget.colors,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom Painter untuk animasi Confetti dengan Physics
class ConfettiPainter extends CustomPainter {
  final double progress;
  final int numberOfParticles;
  final List<Color> colors;

  ConfettiPainter({
    required this.progress,
    required this.numberOfParticles,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Seed untuk consistency

    for (var i = 0; i < numberOfParticles; i++) {
      final angle = (i / numberOfParticles) * (2 * math.pi);

      // Distance dengan acceleration
      final distance = progress * 300;

      // X position dengan spread
      final x = size.width / 2 +
          distance * math.cos(angle) +
          random.nextDouble() * 20 - 10;

      // Y position dengan gravity effect
      final y = size.height / 4 +
          (distance * math.sin(angle)) +
          (progress * progress * 200);

      // Size dengan fade out
      final particleSize = 4 * (1 - progress);

      // Opacity dengan fade out
      final opacity = (1 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw circle
      if (particleSize > 0) {
        canvas.drawCircle(Offset(x, y), particleSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
