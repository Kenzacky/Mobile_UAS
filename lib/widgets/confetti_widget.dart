import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiWidget extends StatefulWidget {
  final Duration duration;
  final bool autoStart;

  const ConfettiWidget({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.autoStart = true,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Confetto> _confetti = [];
  final Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: widget.duration)
      ..addListener(_update);

    if (widget.autoStart) {
      _start();
    }
  }

  void _start() {
    _animationController.forward();
    _generateConfetti();
  }

  void _generateConfetti() {
    for (int i = 0; i < 50; i++) {
      _confetti.add(
        Confetto(
          x: _random.nextDouble(),
          y: 0,
          vx: _random.nextDouble() - 0.5,
          vy: _random.nextDouble() * 0.5 + 0.2,
          angle: _random.nextDouble() * 2 * math.pi,
          color: _getRandomColor(),
          size: _random.nextDouble() * 8 + 4,
        ),
      );
    }
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFFD4AF37), // Gold
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFFFE66D), // Yellow
      const Color(0xFF95E1D3), // Mint
      const Color(0xFFC7CEEA), // Lavender
      const Color(0xFF00D2FC), // Cyan
      const Color(0xFFFF006E), // Pink
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _update() {
    setState(() {
      for (var c in _confetti) {
        c.y += c.vy;
        c.x += c.vx;
        c.vy += 0.01; // gravity
        c.vx *= 0.99; // air resistance
        c.angle += 0.05;

        // Boundaries
        if (c.x < 0) c.x = 1;
        if (c.x > 1) c.x = 0;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConfettiPainter(_confetti),
      child: Container(),
    );
  }
}

class Confetto {
  double x;
  double y;
  double vx;
  double vy;
  double angle;
  Color color;
  double size;

  Confetto({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.angle,
    required this.color,
    required this.size,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetto> confetti;

  ConfettiPainter(this.confetti);

  @override
  void paint(Canvas canvas, Size size) {
    for (var c in confetti) {
      canvas.save();
      canvas.translate(c.x * size.width, c.y * size.height);
      canvas.rotate(c.angle);

      final paint = Paint()
        ..color = c.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset.zero, c.size / 2, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

import 'dart:math';
