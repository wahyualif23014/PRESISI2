import 'package:KETAHANANPANGAN/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/personel_model.dart';
import '../../data/model/role_enum.dart';
import '../../providers/personel_provider.dart';

class AddPersonelDialog extends ConsumerStatefulWidget {
  const AddPersonelDialog({super.key});

  @override
  ConsumerState<AddPersonelDialog> createState() => _AddPersonelDialogState();
}

class _AddPersonelDialogState extends ConsumerState<AddPersonelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nrpController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _telpController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.view;

  @override
  void dispose() {
    _nameController.dispose();
    _nrpController.dispose();
    _jabatanController.dispose();
    _telpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        final newPersonel = Personel(
          id: 0,
          namaLengkap: _nameController.text,
          nrp: _nrpController.text,
          jabatan: _jabatanController.text,
          role: _selectedRole,
          noTelp: _telpController.text.isNotEmpty ? _telpController.text : null,
          fotoProfil: null,
        );

        await ref
            .read(personelProvider.notifier)
            .add(newPersonel, _passwordController.text);

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
                  controller: _nrpController,
                  label: "NRP",
                  icon: Icons.badge_outlined,
                  isNumber: true,
                  validator: (v) => v!.isEmpty ? "NRP wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _jabatanController,
                  label: "Jabatan",
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
    return DropdownButtonFormField<UserRole>(
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
      items: UserRole.values.map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(role.label.toUpperCase()),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedRole = val!),
    );
  }
}

