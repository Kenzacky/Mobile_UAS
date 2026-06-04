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
  // Kunci untuk validasi form login
  final _formKey = GlobalKey<FormState>();
  // Controller untuk input email
  final _emailController = TextEditingController();
  // Controller untuk input password
  final _passwordController = TextEditingController();
  // Flag untuk toggle antara login dan register
  bool _isLogin = true;
  // Flag untuk menampilkan loading indicator saat submit
  bool _isLoading = false;
  // Flag untuk show/hide password
  bool _obscurePassword = true;

  // Animation controller untuk fade dan slide animation
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    // Inisialisasi animation controller dengan durasi 900ms
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Fade in animation
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    // Slide in animation dari bawah
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    // Mulai animasi
    _animController.forward();
  }

  @override
  void dispose() {
    // Bersihkan resources
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fungsi untuk parse error dari Firebase menjadi pesan yang user-friendly
  String _parseFirebaseError(dynamic e) {
    final msg = e.toString();
    // Jika email tidak ditemukan atau kredensial tidak valid
    if (msg.contains('user-not-found') || msg.contains('invalid-credential')) {
      return 'Email atau password salah. Silakan coba lagi.';
    }
    // Jika password salah
    else if (msg.contains('wrong-password')) {
      return 'Password salah. Silakan coba lagi.';
    }
    // Jika email sudah terdaftar
    else if (msg.contains('email-already-in-use')) {
      return 'Email sudah terdaftar. Silakan login.';
    }
    // Jika password terlalu lemah
    else if (msg.contains('weak-password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    }
    // Jika format email tidak valid
    else if (msg.contains('invalid-email')) {
      return 'Format email tidak valid.';
    }
    // Jika tidak ada koneksi internet
    else if (msg.contains('network-request-failed')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }
    // Jika terlalu banyak percobaan login gagal
    else if (msg.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    // Error umum
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  /// Fungsi untuk handle submit form login/register
  Future<void> _submit() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) return;

    // Set loading state
    setState(() => _isLoading = true);
    // Ambil auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Cek apakah user ingin login atau register
      if (_isLogin) {
        // Lakukan login
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Lakukan register
        await authProvider.register(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      // Jika berhasil, tunggu sebentar untuk memastikan state Firebase sudah settle
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Navigate ke home screen
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      // Tampilkan error message jika ada error
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
      // Set loading state kembali ke false
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background decorations - Circular gradient di kanan atas
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
          // Background decorations - Border circle di kiri bawah
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
          // Main form content
          Center(
            child: SingleChildScrollView(
              // Prevent white space di bawah dengan ClampingScrollPhysics
              physics: const ClampingScrollPhysics(),
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
                        // ===== LOGO & TITLE SECTION =====
                        Center(
                          child: Column(
                            children: [
                              // Logo circular dengan gradient
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
                              // App name dengan gradient text
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
                              // Subtitle
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

                        // ===== FORM SECTION LABEL =====
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

                        // ===== EMAIL INPUT FIELD =====
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          // Validator untuk email
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

                        // ===== PASSWORD INPUT FIELD =====
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          // Tombol untuk toggle show/hide password
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
                          // Validator untuk password
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // ===== SUBMIT BUTTON =====
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: _isLoading
                          // Tampilkan loading indicator jika sedang loading
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
                          // Tampilkan button normal jika tidak loading
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

                        // ===== TOGGLE LOGIN/REGISTER =====
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Toggle antara mode login dan register
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

  /// Widget builder untuk text input field yang reusable
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
        // Icon di sebelah kiri
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        // Widget di sebelah kanan (biasanya tombol show/hide password)
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0F1829),
        // Border ketika input tidak fokus
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
          ),
        ),
        // Border ketika input fokus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        // Border ketika ada error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
        // Border ketika fokus dan ada error
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB00020), width: 1.5),
        ),
        // Style untuk text error
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
      ),
    );
  }
}