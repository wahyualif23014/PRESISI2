import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; 
import '../../router/route_names.dart';
import '../provider/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Hanya butuh Controller untuk NRP dan Password
  final _nrpController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Warna tema (Emas Gelap)
  final Color _primaryGold = const Color(0xFFC0A100);

  @override
  void dispose() {
    _nrpController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- LOGIC LOGIN ---
  void _handleLogin() async {
    // 1. Validasi Input UI
    if (!_formKey.currentState!.validate()) return;

    // 2. Tutup Keyboard agar rapi
    FocusScope.of(context).unfocus();

    // 3. Panggil Auth Provider
    final auth = context.read<AuthProvider>();

    // 4. Request Login ke Backend (Cukup NRP & Password)
    final String? errorMessage = await auth.login(
      _nrpController.text.trim(),
      _passController.text.trim(),
    );

    if (!mounted) return;

    // 5. Cek Hasil
    if (errorMessage == null) {
      // --- SUKSES ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Berhasil. Halo, ${auth.user?.namaLengkap ?? 'User'}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigasi ke Dashboard
      context.go(RouteNames.dashboard); 
    } else {
      // --- GAGAL ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), // Pesan error dari backend
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Overlay Gelap
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // 3. Form Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Header ---
                    _LoginHeader(primaryGold: _primaryGold),

                    const SizedBox(height: 40),

                    // --- Input NRP ---
                    _CustomLabelInput(
                      label: "No NRP",
                      hint: "Masukan NRP Anda Disini",
                      controller: _nrpController,
                      primaryColor: _primaryGold,
                      inputType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'NRP wajib diisi' : null,
                    ),

                    const SizedBox(height: 20),

                    // --- Input Password ---
                    _CustomLabelInput(
                      label: "Kata Sandi",
                      hint: "Masukan Password Anda Disini",
                      controller: _passController,
                      primaryColor: _primaryGold,
                      isPassword: true,
                      validator: (val) => val!.isEmpty ? 'Password wajib diisi' : null,
                    ),

                    const SizedBox(height: 40),

                    // --- Tombol Aksi ---
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Column(
                          children: [
                            _LoginButton(
                              text: "Login",
                              isLoading: auth.isLoading,
                              onPressed: _handleLogin,
                              color: _primaryGold,
                              textColor: Colors.white,
                              isFilled: true,
                            ),
                            const SizedBox(height: 15),
                            _LoginButton(
                              text: "Register",
                              isLoading: false,
                              onPressed: auth.isLoading ? null : _navigateToRegister,
                              color: _primaryGold,
                              textColor: _primaryGold,
                              isFilled: false,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- Lupa Password ---
                    TextButton(
                      onPressed: () {
                        // TODO: Implementasi Lupa Password nanti
                      },
                      child: Text(
                        "Lupa Kata Sandi",
                        style: TextStyle(
                          color: _primaryGold,
                          decoration: TextDecoration.underline,
                          decorationColor: _primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PENDUKUNG (Konsisten dengan Register) ---

class _LoginHeader extends StatelessWidget {
  final Color primaryGold;
  const _LoginHeader({required this.primaryGold});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/image/logo.png',
          height: 100,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.shield, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          "Selamat Datang",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          "SIKAP PRESISI Polda Jawa Timur",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ],
    );
  }
}

class _CustomLabelInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color primaryColor;
  final bool isPassword;
  final TextInputType inputType;
  final String? Function(String?)? validator;

  const _CustomLabelInput({
    required this.label, required this.hint, required this.controller,
    required this.primaryColor, this.isPassword = false, this.inputType = TextInputType.text,
    this.validator,
  });

  @override
  State<_CustomLabelInput> createState() => _CustomLabelInputState();
}

class _CustomLabelInputState extends State<_CustomLabelInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.inputType,
          style: const TextStyle(color: Colors.white),
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: widget.primaryColor, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final bool isFilled;
  final bool isLoading;

  const _LoginButton({
    required this.text, required this.onPressed, required this.color,
    required this.textColor, required this.isFilled, required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isFilled
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            ),
    );
  }
}