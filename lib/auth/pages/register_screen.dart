import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // --- CONTROLLERS ---
  final _namaController = TextEditingController();
  final _idTugasController = TextEditingController(); // Field Baru: ID Tugas
  final _usernameController = TextEditingController(); // Field Baru: Username (Ganti NRP)
  final _phoneController = TextEditingController();
  final _jabatanController = TextEditingController(); // Input ID Jabatan (Angka)
  final _passController = TextEditingController();

  final Color _primaryGold = const Color(0xFFC0A100);
  final Color _btnGreen = const Color(0xFF10B981);

  @override
  void dispose() {
    _namaController.dispose();
    _idTugasController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- LOGIC REGISTER ---
  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // VALIDASI KHUSUS: Pastikan ID Jabatan adalah Angka
    // Karena Backend Go meminta (uint64/int), bukan string.
    final int? idJabatanInt = int.tryParse(_jabatanController.text.trim());
    if (idJabatanInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ID Jabatan harus berupa angka (Contoh: 1, 11)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tutup Keyboard
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();

    // Panggil Provider (Sesuai parameter terbaru)
    final String? error = await auth.register(
      namaLengkap: _namaController.text.trim(),
      idTugas: _idTugasController.text.trim(),   // Parameter Baru
      username: _usernameController.text.trim(), // Parameter Baru
      idJabatan: idJabatanInt,                   // Kirim sebagai Integer
      password: _passController.text.trim(),
      noTelp: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      // --- SUKSES ---
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi Berhasil! Silakan Login."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context); // Kembali ke Login
    } else {
      // --- GAGAL ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer agar loading state terupdate realtime
    final isLoading = context.select<AuthProvider, bool>((p) => p.isLoading);

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
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AuthHeader(primaryGold: _primaryGold, title: "Registrasi Akun"),
                    
                    const SizedBox(height: 30),

                    // INPUT 1: NAMA LENGKAP
                    _CustomLabelInput(
                      label: "Nama Lengkap",
                      hint: "Masukan Nama Lengkap",
                      controller: _namaController,
                      primaryColor: _primaryGold,
                      validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    // INPUT 2: ID TUGAS (BARU)
                    _CustomLabelInput(
                      label: "ID Tugas",
                      hint: "Masukan ID Tugas",
                      controller: _idTugasController,
                      primaryColor: _primaryGold,
                      validator: (v) => v!.isEmpty ? "ID Tugas wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    // INPUT 3: USERNAME (PENGGANTI NRP)
                    _CustomLabelInput(
                      label: "Username / NRP",
                      hint: "Masukan Username",
                      controller: _usernameController,
                      primaryColor: _primaryGold,
                      validator: (v) => v!.isEmpty ? "Username wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    // INPUT 4: NOMOR TELEPON
                    _CustomLabelInput(
                      label: "Nomor Telepon",
                      hint: "Contoh: 08123456789",
                      controller: _phoneController,
                      primaryColor: _primaryGold,
                      inputType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? "No Telp wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    // INPUT 5: ID JABATAN (ANGKA - WAJIB INT)
                    _CustomLabelInput(
                      label: "ID Jabatan (Angka)",
                      hint: "Masukan ID (Cth: 1)",
                      controller: _jabatanController,
                      primaryColor: _primaryGold,
                      inputType: TextInputType.number, // Wajib Angka
                      validator: (v) {
                        if (v!.isEmpty) return "ID Jabatan wajib diisi";
                        if (int.tryParse(v) == null) return "Harus angka valid";
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // INPUT 6: PASSWORD
                    _CustomLabelInput(
                      label: "Kata Sandi",
                      hint: "Buat Kata Sandi",
                      controller: _passController,
                      primaryColor: _primaryGold,
                      isPassword: true,
                      validator: (v) => (v != null && v.length < 6) ? "Min 6 karakter" : null,
                    ),

                    const SizedBox(height: 30),

                    // TOMBOL REGISTER
                    Column(
                      children: [
                        _ActionButton(
                          text: "Daftar Sekarang",
                          color: _primaryGold,
                          textColor: Colors.white,
                          isFilled: true,
                          isLoading: isLoading,
                          onPressed: _handleRegister,
                        ),
                        const SizedBox(height: 15),
                        _ActionButton(
                          text: "Sudah Punya Akun? Login",
                          color: _btnGreen,
                          textColor: Colors.white,
                          isFilled: true,
                          isLoading: false,
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                        ),
                      ],
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
// WIDGET UI COMPONENTS (TIDAK BERUBAH)
// =========================================================

class _AuthHeader extends StatelessWidget {
  final Color primaryGold;
  final String title;
  const _AuthHeader({required this.primaryGold, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/image/logo.png', 
          height: 90,
          errorBuilder: (context, error, stackTrace) => 
              const Icon(Icons.shield, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 5),
        const Text(
          "SIKAP PRESISI Polda Jawa Timur",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
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
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

class _ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool isFilled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text, required this.color, required this.textColor,
    required this.isFilled, required this.isLoading, required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: isFilled
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ),
    );
  }
}