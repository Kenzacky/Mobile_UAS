import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller untuk mengontrol animasi splash screen
  late AnimationController _controller;
  // Fade animation - membuat logo dan text tampil perlahan
  late Animation<double> _fadeAnim;
  // Scale animation - membuat logo membesar
  late Animation<double> _scaleAnim;
  // Slide animation - membuat content bergerak dari atas ke bawah
  late Animation<double> _slideAnim;
  // Flag untuk prevent duplicate navigation
  bool _navigationDone = false;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animation controller dengan durasi 1800ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Fade animation - mulai dari 0 sampai 0.6 durasi controller
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    // Scale animation - membuat logo scale dari 0.6 ke 1.0
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Slide animation - membuat content slide dari 30 pixel ke 0
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Mulai animasi
    _controller.forward();

    // Tunggu 2.5 detik (lebih lama dari durasi animasi) baru check user state
    // Ini memastikan splash screen sudah selesai ditampilkan
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted || _navigationDone) return;

      // Ambil current user dari Firebase
      final user = FirebaseAuth.instance.currentUser;
      _navigationDone = true;

      // Jika user sudah login, navigasi ke home
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      // Jika user belum login, navigasi ke login screen
      else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    // Bersihkan animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: Stack(
        children: [
          // ===== BACKGROUND DECORATIONS =====
          // Radial gradient glow effect di tengah
          Positioned.fill(
            child: Center(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Decorative ring di kanan atas
          Positioned(
            top: -70,
            right: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.07),
                  width: 45,
                ),
              ),
            ),
          ),
          // Decorative ring di kiri bawah
          Positioned(
            bottom: -90,
            left: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1A3A6B).withOpacity(0.35),
                  width: 55,
                ),
              ),
            ),
          ),
          // ===== MAIN ANIMATED CONTENT =====
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ===== ANIMATED LOGO =====
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFD4AF37),
                                  Color(0xFFF5D76E),
                                  Color(0xFFA8892A),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(0.45),
                                  blurRadius: 35,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sports_soccer,
                              size: 58,
                              color: Color(0xFF0A0E1A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // ===== APP NAME =====
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
                          ).createShader(bounds),
                          child: const Text(
                            'LIGAKITA',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ===== TAGLINE =====
                        Text(
                          'Manajemen Liga Profesional',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 64),
                        // ===== LOADING DOTS =====
                        _LoadingDots(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk animasi 3 dots yang bergerak
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  // List of animation controllers untuk 3 dots
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    // Buat 3 animation controller dengan delay yang berbeda
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      // Setiap dot memiliki delay 200ms
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    // Bersihkan semua animation controllers
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Color berubah dari transparent ke opaque berdasarkan animation value
              color: Color.lerp(
                const Color(0xFFD4AF37).withOpacity(0.25),
                const Color(0xFFD4AF37),
                _controllers[i].value,
              ),
            ),
          ),
        );
      }),
    );
  }
}