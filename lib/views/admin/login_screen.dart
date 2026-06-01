import 'package:flutter/material.dart';

class LoginAdminScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback? onBack;

  const LoginAdminScreen({
    super.key,
    required this.onLoginSuccess,
    this.onBack,
  });

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulasi delay jaringan untuk UX premium
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        final email = _emailController.text.trim();
        final password = _passwordController.text;

        if (email == 'admin@aksestbc.gov.id' && password == 'admin123') {
          // Login Sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Login berhasil! Selamat datang Admin.'),
                ],
              ),
              backgroundColor: const Color(0xFF007B7A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          widget.onLoginSuccess();
        } else {
          // Login Gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Email atau kata sandi salah.'),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBack != null 
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                onPressed: widget.onBack,
              )
            : const SizedBox(width: 16),
        titleSpacing: widget.onBack != null ? 0 : 20,
        title: const Text(
          'AksesTBC',
          style: TextStyle(
            color: Color(0xFF007B7A),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient / Symmetrical modern pattern
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEBF3FF), // Light premium blue at the top
                  Color(0xFFF8FAFC), // Fades to white-grey at the bottom
                ],
                stops: [0.0, 0.4],
              ),
            ),
          ),

          // Main content scroll view
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0.0, 30.0 * (1.0 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 450),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x0F0F172A), // 6% opacity of 0xFF0F172A
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Icon Shield
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0F2F1), // Teal accent light
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Shield base
                                  const Icon(
                                    Icons.shield,
                                    size: 40,
                                    color: Color(0xFF007B7A),
                                  ),
                                  // Inner user profile silhouette icon
                                  Positioned(
                                    bottom: 21,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 14,
                                    child: Container(
                                      width: 16,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Title and Subtitle
                          const Center(
                            child: Text(
                              'Login Admin',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Silakan masuk untuk mengelola sistem.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Email Label & Field
                          const Text(
                            'Email Institusi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                              hintText: 'admin@aksestbc.gov.id',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF007B7A), width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email institusi wajib diisi';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Label & Field
                          const Text(
                            'Kata Sandi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 22,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              hintText: '••••••••',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), letterSpacing: 2),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF007B7A), width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kata sandi wajib diisi';
                              }
                              if (value.length < 6) {
                                return 'Kata sandi minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur reset kata sandi sedang dalam pengembangan.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lupa Kata Sandi?',
                                style: TextStyle(
                                  color: Color(0xFF007B7A),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006D6C), // Deep premium teal
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'Login Admin',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.login,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          const Divider(
                            color: Color(0xFFF1F5F9),
                            thickness: 1.5,
                          ),
                          const SizedBox(height: 16),

                          // Encrypted Connection Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.shield,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Koneksi Terenkripsi',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
