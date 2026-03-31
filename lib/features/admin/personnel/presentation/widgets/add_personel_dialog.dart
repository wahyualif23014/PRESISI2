import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
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
  final _nrpController = TextEditingController();
  final _telpController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // State for selections
  UserRole _selectedRole = UserRole.view;
  String? _selectedTingkatKode; 
  int? _selectedJabatanId;      
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    // Memastikan data master siap saat dialog muncul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonelProvider>().fetchDropdownData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nrpController.dispose();
    _telpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA SUBMIT AMAN ---
  void _submit() async {
    // 1. Validasi Form Dasar
    if (!_formKey.currentState!.validate()) return;

    // 2. Validasi Pilihan Dropdown
    if (_selectedTingkatKode == null || _selectedJabatanId == null) {
      _showSnackBar("Pilih Unit Kerja dan Jabatan!", Colors.orange);
      return;
    }

    // 3. Validasi Panjang Password (Min 6 Karakter sesuai Backend)
    if (_passwordController.text.length < 6) {
      _showSnackBar("Kata sandi minimal 6 karakter!", Colors.orange);
      return;
    }

    // 4. Konstruksi Model
    final newUser = UserModel(
      id: 0, // ID 0 karena akan di-generate oleh MySQL
      namaLengkap: _nameController.text.trim(),
      nrp: _nrpController.text.trim(),
      noTelp: _telpController.text.trim(),
      idTugas: _selectedTingkatKode!,
      idJabatan: _selectedJabatanId,
      role: _selectedRole,
    );

    try {
      // 5. Eksekusi melalui Provider
      await context.read<PersonelProvider>().addPersonel(
        newUser, 
        _passwordController.text
      );

      if (mounted) {
        _showSnackBar("Personel berhasil didaftarkan", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error: $e", Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E293B); 
    const accentColor = Color(0xFF10B981);  

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Consumer<PersonelProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(primaryColor),
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
                            hint: "Nama sesuai data kepegawaian",
                            icon: Icons.person_outline_rounded,
                          ),
                          _buildField(
                            controller: _telpController,
                            label: "Nomor WhatsApp",
                            hint: "0812xxxxxxxx",
                            icon: Icons.phone_android_rounded,
                            inputType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle("STRUKTUR TUGAS"),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _nrpController,
                            label: "NRP / Username",
                            hint: "Gunakan NRP sebagai username",
                            icon: Icons.badge_outlined,
                          ),

                          // Dropdown Unit Kerja
                          _buildDropdown<String>(
                            label: "Unit Kerja / Tingkat",
                            hint: "Pilih Unit",
                            value: _selectedTingkatKode,
                            icon: Icons.account_balance_outlined,
                            items: provider.tingkatOptions.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['kode'].toString(),
                                child: Text(item['nama'] ?? "", overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedTingkatKode = val),
                          ),

                          // Dropdown Jabatan
                          _buildDropdown<int>(
                            label: "Jabatan",
                            hint: "Pilih Jabatan",
                            value: _selectedJabatanId,
                            icon: Icons.work_outline_rounded,
                            items: provider.jabatanOptions.map((item) {
                              return DropdownMenuItem<int>(
                                value: int.tryParse(item['id'].toString()),
                                child: Text(item['nama'] ?? ""),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedJabatanId = val),
                          ),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle("AKSES & KEAMANAN"),
                          const SizedBox(height: 12),
                          _buildRoleDropdown(),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _passwordController,
                            label: "Kata Sandi",
                            hint: "Kombinasi huruf & angka",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActions(context, accentColor, provider.isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- UI HELPER COMPONENTS ---

  Widget _buildHeader(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: primary,
      child: Row(
        children: [
          const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text("Registrasi Personel", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(Icons.close, color: Colors.white70)
          )
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
        validator: (v) => v == null ? "Wajib dipilih" : null,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller, 
    required String label, 
    required String hint, 
    required IconData icon, 
    bool isPassword = false, 
    TextInputType? inputType
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _isObscure : false,
        keyboardType: inputType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, size: 18), 
            onPressed: () => setState(() => _isObscure = !_isObscure)
          ) : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return _buildDropdown<UserRole>(
      label: "Hak Akses",
      hint: "Pilih Role",
      value: _selectedRole,
      icon: Icons.admin_panel_settings_outlined,
      items: UserRole.values.where((e) => e != UserRole.unknown).map((role) {
        return DropdownMenuItem(
          value: role, 
          child: Text(role.label.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedRole = val!),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.blueGrey.shade400, letterSpacing: 1.2));
  }

  Widget _buildActions(BuildContext context, Color accent, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text("Batal"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent, 
                padding: const EdgeInsets.symmetric(vertical: 16), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Simpan Personel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}