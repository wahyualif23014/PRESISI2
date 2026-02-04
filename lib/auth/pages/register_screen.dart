import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers untuk data sesuai Backend Go
  final _namaController = TextEditingController();
  final _nrpController = TextEditingController(); 
  final _jabatanController = TextEditingController();
  final _passController = TextEditingController();

  // Warna Tema (Konsisten dengan Login)
  final Color _primaryGold = const Color(0xFFC0A100);
  final Color _btnGreen = const Color(0xFF10B981);

  @override
  void dispose() {
    _namaController.dispose();
    _nrpController.dispose();
    _jabatanController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- LOGIC INTEGRASI GO BACKEND ---
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Tutup Keyboard
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();

    // Panggil fungsi register di Provider
    // Mengirim data sesuai struct JSON Go Backend
    final String? error = await auth.register(
      nama: _namaController.text.trim(),
      nrp: _nrpController.text.trim(),
      jabatan: _jabatanController.text.trim(),
      password: _passController.text.trim(),
      // Default Role untuk pendaftar umum (Sesuaikan dengan ENUM di Go: polsek/polres/view)
      role: 'polsek', 
    );

    if (!mounted) return;

    if (error == null) {
      // --- SUKSES ---
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi Berhasil! Silakan tunggu validasi Admin untuk Login."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      // Kembali ke Login Screen
      Navigator.pop(context); 
    } else {
      // --- GAGAL ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error), // Pesan error asli dari Backend (misal: NRP sudah ada)
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Layer
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/background.png'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. Overlay Layer
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // 3. Form Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Header ---
                    _RegisterHeader(primaryGold: _primaryGold),
                    
                    const SizedBox(height: 30),

                    // --- Input Nama Lengkap ---
                    _CustomLabelInput(
                      label: "Nama Lengkap",
                      hint: "Masukan Nama Lengkap Anda",
                      controller: _namaController,
                      primaryColor: _primaryGold,
                      validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    // --- Input NRP ---
                    _CustomLabelInput(
                      label: "No NRP",
                      hint: "Masukan NRP Anda Disini",
                      controller: _nrpController,
                      primaryColor: _primaryGold,
                      inputType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "NRP wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    // --- Input Jabatan ---
                    _CustomLabelInput(
                      label: "Jabatan",
                      hint: "Contoh: Kanit Reskrim",
                      controller: _jabatanController,
                      primaryColor: _primaryGold,
                      validator: (v) => v!.isEmpty ? "Jabatan wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    // --- Input Password ---
                    _CustomLabelInput(
                      label: "Kata Sandi",
                      hint: "Buat Kata Sandi",
                      controller: _passController,
                      primaryColor: _primaryGold,
                      isPassword: true,
                      validator: (v) => (v != null && v.length < 6) ? "Min 6 karakter" : null,
                    ),

                    const SizedBox(height: 30),

                    // --- Action Buttons ---
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Column(
                          children: [
                            // Tombol Simpan
                            _ActionButton(
                              text: "Daftar Sekarang",
                              color: _primaryGold,
                              isLoading: auth.isLoading,
                              onPressed: _handleRegister,
                            ),
                            
                            const SizedBox(height: 15),
                            
                            // Tombol Kembali ke Login
                            _ActionButton(
                              text: "Sudah Punya Akun? Login",
                              color: _btnGreen,
                              isLoading: false, // Tombol back tidak perlu loading
                              onPressed: auth.isLoading ? null : () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
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

// =========================================================
// WIDGET UI COMPONENTS (Konsisten dengan Login Screen)
// =========================================================

class _RegisterHeader extends StatelessWidget {
  final Color primaryGold;
  const _RegisterHeader({required this.primaryGold});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/image/logo.png', 
          height: 80, // Sedikit lebih kecil dari login agar muat
          errorBuilder: (context, error, stackTrace) => 
              const Icon(Icons.shield, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 15),
        const Text(
          "Registrasi Akun",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Lengkapi data diri Anda dengan benar",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
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
    required this.label,
    required this.hint,
    required this.controller,
    required this.primaryColor,
    this.isPassword = false,
    this.inputType = TextInputType.text,
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15, // Sedikit lebih kecil agar compact
          ),
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
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}