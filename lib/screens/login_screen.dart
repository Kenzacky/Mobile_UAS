import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // FIX: Parse pesan error Firebase dengan benar
  String _parseFirebaseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('user-not-found') || msg.contains('invalid-credential')) {
      return 'Email atau password salah. Silakan coba lagi.';
    } else if (msg.contains('wrong-password')) {
      return 'Password salah. Silakan coba lagi.';
    } else if (msg.contains('email-already-in-use')) {
      return 'Email sudah terdaftar. Silakan login.';
    } else if (msg.contains('weak-password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    } else if (msg.contains('invalid-email')) {
      return 'Format email tidak valid.';
    } else if (msg.contains('network-request-failed')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    } else if (msg.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isLogin) {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authProvider.register(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(_parseFirebaseError(e))),
              ],
            ),
            backgroundColor: const Color(0xFFB00020),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1A3A6B).withOpacity(0.35),
                  width: 50,
                ),
              ),
            ),
          ),
          // Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo & Title
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
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
                                      color: const Color(0xFFD4AF37)
                                          .withOpacity(0.35),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sports_soccer,
                                  size: 40,
                                  color: Color(0xFF0A0E1A),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFFD4AF37),
                                        Color(0xFFF5D76E),
                                      ],
                                    ).createShader(bounds),
                                child: const Text(
                                  'LIGAKITA',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 7,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isLogin ? 'Selamat datang kembali' : 'Buat akun baru',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.4),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 44),

                        // Section label
                        Text(
                          _isLogin ? 'LOGIN' : 'DAFTAR',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4AF37),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                !value.contains('@') ||
                                !value.contains('.')) {
                              return 'Masukkan email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white.withOpacity(0.4),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                      () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: _isLoading
                              ? const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: Color(0xFFD4AF37),
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                              : DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD4AF37),
                                  Color(0xFFF5D76E),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37)
                                      .withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _isLogin ? 'MASUK' : 'DAFTAR SEKARANG',
                                style: const TextStyle(
                                  color: Color(0xFF0A0E1A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Toggle login/register
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() => _isLogin = !_isLogin);
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                children: [
                                  TextSpan(
                                    text: _isLogin
                                        ? 'Belum punya akun? '
                                        : 'Sudah punya akun? ',
                                  ),
                                  const TextSpan(
                                    text: 'Klik di sini',
                                    style: TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0F1829),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB00020), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
      ),
    );
  }
}