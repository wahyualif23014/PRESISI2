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
  
  // Controllers
  final _namaController = TextEditingController();
  final _nrpController = TextEditingController(); // Menggantikan Email
  final _jabatanController = TextEditingController(); // Menggantikan Satker
  final _passController = TextEditingController();

  // Warna Tema
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

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    // Mapping data sesuai input UI baru ke fungsi register yang lama
    final success = await auth.register(
      email: _nrpController.text.trim(), // NRP digunakan sebagai identitas login
      password: _passController.text.trim(),
      nama: _namaController.text.trim(),
      role: 'USER', // Default role user biasa
      satuanKerja: _jabatanController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Registrasi Gagal"), backgroundColor: Colors.red),
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
                    _RegisterHeader(primaryGold: _primaryGold),
                    
                    const SizedBox(height: 30),

                    _CustomLabelInput(
                      label: "Nama Lengkap",
                      hint: "Masukan Nama Lengkap Anda",
                      controller: _namaController,
                      primaryColor: _primaryGold,
                      validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    _CustomLabelInput(
                      label: "No NRP",
                      hint: "Masukan NRP Anda Disini",
                      controller: _nrpController,
                      primaryColor: _primaryGold,
                      inputType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "NRP wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    _CustomLabelInput(
                      label: "Jabatan",
                      hint: "Masukan Jabatan Anda",
                      controller: _jabatanController,
                      primaryColor: _primaryGold,
                      validator: (v) => v!.isEmpty ? "Jabatan wajib diisi" : null,
                    ),

                    const SizedBox(height: 15),

                    _CustomLabelInput(
                      label: "Kata Sandi",
                      hint: "Masukan Kata Sandi Anda Disini",
                      controller: _passController,
                      primaryColor: _primaryGold,
                      isPassword: true,
                      validator: (v) => (v != null && v.length < 6) ? "Min 6 karakter" : null,
                    ),

                    const SizedBox(height: 30),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Column(
                          children: [
                            _ActionButton(
                              text: "Simpan",
                              color: _primaryGold,
                              isLoading: auth.isLoading,
                              onPressed: _handleRegister,
                            ),
                            
                            const SizedBox(height: 15),
                            
                            _ActionButton(
                              text: "Sudah Punya Akun? Login Di sini",
                              color: _btnGreen,
                              isLoading: false,
                              onPressed: () => Navigator.pop(context),
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
// WIDGET UI COMPONENTS
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
          height: 100,
          errorBuilder: (context, error, stackTrace) => 
              const Icon(Icons.shield, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 20),
        const Text(
          "Selamat Datang",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "SIKAP PRESISI Polda Jawa Timur",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
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
            fontSize: 16,
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
      height: 50,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}