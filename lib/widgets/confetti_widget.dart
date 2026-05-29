import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiWidget extends StatefulWidget {
  final Duration duration;
  final bool autoStart;
  final VoidCallback? onComplete;

  const ConfettiWidget({
    super.key,
    this.duration = const Duration(seconds: 4),
    this.autoStart = true,
    this.onComplete,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Confetto> _confetti = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // 🔧 Perbaikan: tambahkan vsync: this
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )
      ..addListener(_update)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });

    if (widget.autoStart) {
      _start();
    }
  }

  void _start() {
    _generateConfetti();
    _animationController.forward();
  }

  void _generateConfetti() {
    for (int i = 0; i < 60; i++) {
      _confetti.add(
        Confetto(
          x: _random.nextDouble(),
          y: -0.1,
          vx: (_random.nextDouble() - 0.5) * 0.8,
          vy: _random.nextDouble() * 0.3 + 0.4,
          angle: _random.nextDouble() * 2 * math.pi,
          angularVelocity: (_random.nextDouble() - 0.5) * 0.3,
          color: _getRandomColor(),
          size: _random.nextDouble() * 10 + 4,
          shape: _random.nextInt(3),
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
      const Color(0xFF11C76F), // Green
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _update() {
    setState(() {
      for (var c in _confetti) {
        c.y += c.vy;
        c.x += c.vx;
        c.vy += 0.015; // gravity
        c.vx *= 0.98; // air resistance
        c.angle += c.angularVelocity;
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
    return SizedBox.expand(
      child: CustomPaint(
        painter: ConfettiPainter(_confetti),
      ),
    );
  }
}

class Confetto {
  double x;
  double y;
  double vx;
  double vy;
  double angle;
  double angularVelocity;
  Color color;
  double size;
  int shape; // 0: circle, 1: square, 2: star

  Confetto({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.angle,
    required this.angularVelocity,
    required this.color,
    required this.size,
    required this.shape,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<Confetto> confetti;

  ConfettiPainter(this.confetti);

  @override
  void paint(Canvas canvas, Size size) {
    for (var c in confetti) {
      if (c.y > 1) continue; // Skip if below screen

      canvas.save();
      canvas.translate(c.x * size.width, c.y * size.height);
      canvas.rotate(c.angle);

      final paint = Paint()
        ..color = c.color
        ..style = PaintingStyle.fill;

      switch (c.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, c.size / 2, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size),
            paint,
          );
          break;
        case 2: // Star
          _drawStar(canvas, c.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    final radius = size / 2;
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5;
      final r = i % 2 == 0 ? radius : radius / 2;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}