import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Provider & Model yang benar
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';

class AddPersonelDialog extends StatefulWidget {
  const AddPersonelDialog({super.key});

  @override
  State<AddPersonelDialog> createState() => _AddPersonelDialogState();
}

class _AddPersonelDialogState extends State<AddPersonelDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _idTugasController = TextEditingController(); // Ganti NRP -> ID Tugas
  final _jabatanController = TextEditingController();
  final _telpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController(); // Tambahan Username (Wajib buat login)

  // State Dropdown (Default '3' = View Only)
  String _selectedRole = '3'; 

  @override
  void dispose() {
    _nameController.dispose();
    _idTugasController.dispose();
    _jabatanController.dispose();
    _telpController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Tutup dialog dulu agar UX lebih cepat
      Navigator.pop(context);

      try {
        // Buat Object UserModel Baru
        // ID dikosongkan (0) karena auto-increment di DB
        final newUser = UserModel(
          id: 0, 
          namaLengkap: _nameController.text,
          idTugas: _idTugasController.text,
          username: _usernameController.text,
          idJabatan: 0, 
          role: _selectedRole, // Kirim '1', '2', atau '3'
          noTelp: _telpController.text.isNotEmpty ? _telpController.text : "-",
          fotoProfil: "", // Kosongkan dulu
        );

        // Panggil Provider untuk Add Data
        await context.read<PersonelProvider>().addPersonel(newUser, _passwordController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Berhasil menambah personel"),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal: $e"),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      actionsPadding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      title: const Row(
        children: [
          Icon(Icons.person_add_alt_1, color: AppColors.greenPrimary, size: 28),
          SizedBox(width: 12),
          Text(
            "Tambah Personel",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.slate800,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: "Nama Lengkap",
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _usernameController,
                  label: "Username",
                  icon: Icons.account_circle_outlined,
                  validator: (v) => v!.isEmpty ? "Username wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _idTugasController,
                  label: "ID Tugas / NRP",
                  icon: Icons.badge_outlined,
                  isNumber: true,
                  validator: (v) => v!.isEmpty ? "ID Tugas wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _jabatanController,
                  label: "Jabatan (Teks)",
                  icon: Icons.work_outline,
                  validator: (v) => v!.isEmpty ? "Jabatan wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _telpController,
                  label: "Nomor Telepon",
                  icon: Icons.phone_android_outlined,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                
                // Dropdown Role String
                _buildDropdownField(),
                
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: "Password Awal",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) =>
                      v!.length < 6 ? "Minimal 6 karakter" : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.slate300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                    color: AppColors.slate600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(
        color: AppColors.slate800,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.slate500, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.slate400, size: 22),
        filled: true,
        fillColor: AppColors.slate50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.greenPrimary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      style: const TextStyle(
        color: AppColors.slate800,
        fontWeight: FontWeight.w500,
        fontFamily: 'Roboto',
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.slate400),
      decoration: InputDecoration(
        labelText: "Role Akses",
        labelStyle: const TextStyle(color: AppColors.slate500, fontSize: 14),
        prefixIcon: const Icon(Icons.security_outlined,
            color: AppColors.slate400, size: 22),
        filled: true,
        fillColor: AppColors.slate50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.greenPrimary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Item Dropdown Manual sesuai Logic Database ('1','2','3')
      items: const [
        DropdownMenuItem(value: '1', child: Text("ADMINISTRATOR")),
        DropdownMenuItem(value: '2', child: Text("OPERATOR")),
        DropdownMenuItem(value: '3', child: Text("VIEW ONLY")),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() => _selectedRole = val);
        }
      },
    );
  }
}