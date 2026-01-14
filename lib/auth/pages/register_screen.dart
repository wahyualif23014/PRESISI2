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
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _satkerController = TextEditingController();

  // Dropdown Role
  String? _selectedRole;
  final List<String> _roles = ['ADMIN', 'USER', 'POLRES', 'POLSEK'];

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success = await auth.register(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
      nama: _namaController.text.trim(),
      role: _selectedRole ?? 'USER',
      satuanKerja: _satkerController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil! Silakan Login."), backgroundColor: Colors.green),
      );
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? "Registrasi Gagal"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: Consumer<AuthProvider>( // Bungkus body dengan Consumer untuk loading state
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add, size: 60, color: Colors.orange),
                  const SizedBox(height: 20),
                  
                  // Nama Lengkap
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextFormField(
                    controller: _passController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                    validator: (v) => (v != null && v.length < 6) ? "Password min 6 karakter" : null,
                  ),
                  const SizedBox(height: 15),

                  // Dropdown Role
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: "Pilih Role", border: OutlineInputBorder()),
                    items: _roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRole = val),
                    validator: (v) => v == null ? "Pilih salah satu role" : null,
                  ),
                  const SizedBox(height: 15),

                  // Satuan Kerja
                  TextFormField(
                    controller: _satkerController,
                    decoration: const InputDecoration(labelText: "Satuan Kerja (Misal: POLDA JATIM)", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? "Satuan kerja wajib diisi" : null,
                  ),
                  const SizedBox(height: 30),

                  // Tombol Daftar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("DAFTAR SEKARANG"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}