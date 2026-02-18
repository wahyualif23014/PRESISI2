import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/auth/models/unit_model.dart'; // Import JabatanModel
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';

class AddPersonelDialog extends StatefulWidget {
  const AddPersonelDialog({super.key});

  @override
  State<AddPersonelDialog> createState() => _AddPersonelDialogState();
}

class _AddPersonelDialogState extends State<AddPersonelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _idTugasController = TextEditingController();
  final _jabatanIdController = TextEditingController();
  final _telpController = TextEditingController();
  final _passwordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.view;
  bool _isObscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _nrpController.dispose();
    _idTugasController.dispose();
    _jabatanIdController.dispose();
    _telpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E293B); // Slate 800
    const accentColor = Color(0xFF10B981);  // Emerald 500

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Header Dialog ---
            Container(
              padding: const EdgeInsets.all(20),
              color: primaryColor,
              child: Row(
                children: [
                  const Icon(Icons.person_add_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    "Registrasi Personel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  )
                ],
              ),
            ),

            // --- Form Content ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("INFORMASI PERSONAL"),
                      const SizedBox(height: 12),
                      _buildField(
                        controller: _nameController,
                        label: "Nama Lengkap",
                        hint: "Masukkan nama sesuai KTP/NRP",
                        icon: Icons.person_outline_rounded,
                      ),
                      _buildField(
                        controller: _telpController,
                        label: "Nomor WhatsApp",
                        hint: "Contoh: 081234567xxx",
                        icon: Icons.phone_android_rounded,
                        inputType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle("STRUKTUR TUGAS"),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              controller: _nrpController,
                              label: "NRP / Username",
                              hint: "Username login",
                              icon: Icons.badge_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField(
                              controller: _idTugasController,
                              label: "Kode Unit",
                              hint: "Contoh: 11",
                              icon: Icons.account_balance_outlined,
                            ),
                          ),
                        ],
                      ),
                      _buildField(
                        controller: _jabatanIdController,
                        label: "ID Jabatan",
                        hint: "Gunakan angka ID jabatan",
                        icon: Icons.work_outline_rounded,
                        isNumber: true,
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle("AKSES & KEAMANAN"),
                      const SizedBox(height: 12),
                      _buildRoleDropdown(primaryColor),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _passwordController,
                        label: "Kata Sandi",
                        hint: "Minimal 6 karakter",
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Action Buttons ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Batal", style: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Simpan Personel",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Mapping Jabatan dari ID Input
    final jabatanId = int.tryParse(_jabatanIdController.text) ?? 0;
    
    final newUser = UserModel(
      id: 0,
      namaLengkap: _nameController.text,
      nrp: _nrpController.text,
      noTelp: _telpController.text,
      idTugas: _idTugasController.text,
      role: _selectedRole,
      jabatanDetail: JabatanModel(id: jabatanId, namaJabatan: ""), // Akan diisi lengkap oleh Backend
    );

    try {
      await context.read<PersonelProvider>().addPersonel(newUser, _passwordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Personel berhasil didaftarkan"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.blueGrey.shade400,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isNumber = false,
    TextInputType? inputType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        keyboardType: isNumber ? TextInputType.number : inputType,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, size: 18),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          ),
        ),
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
      ),
    );
  }

  Widget _buildRoleDropdown(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<UserRole>(
        value: _selectedRole,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: "Hak Akses Aplikasi",
          prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 20),
        ),
        items: UserRole.values.where((e) => e != UserRole.unknown).map((role) {
          return DropdownMenuItem(
            value: role, 
            child: Text(
              role.label.toUpperCase(), 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedRole = val!),
      ),
    );
  }
}