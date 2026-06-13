import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

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
  String? _selectedPolresKode; 
  String? _selectedPolsekKode; 
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
    if (_selectedPolresKode == null || _selectedJabatanId == null) {
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
      idTugas: _selectedPolsekKode ?? _selectedPolresKode!,
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

                          // Dropdown Unit Kerja (Hirarki)
                          Builder(builder: (context) {
                            // 1. Ambil List Polres (Parent)
                            final parentUnits = provider.tingkatOptions.where((item) {
                              final nama = item['nama']?.toString().toLowerCase() ?? '';
                              if (nama.contains('polres') || nama.contains('polda') || nama.contains('mabes') || nama.contains('polresta')) return true;
                              if (nama.contains('polsek')) return false;
                              return !nama.contains(',');
                            }).toList();

                            // 2. Ambil List Polsek (Child) berdasarkan Polres yang dipilih
                            List<dynamic> childUnits = [];
                            if (_selectedPolresKode != null) {
                              final selectedParent = parentUnits.firstWhere(
                                (p) => p['kode'].toString() == _selectedPolresKode, 
                                orElse: () => null
                              );
                              if (selectedParent != null) {
                                // Cek apakah data sudah nested dari API
                                if (selectedParent['daftar_polsek'] != null) {
                                  childUnits = List<dynamic>.from(selectedParent['daftar_polsek']);
                                } else if (selectedParent['polsek'] != null) {
                                  childUnits = List<dynamic>.from(selectedParent['polsek']);
                                } else {
                                  // Fallback ke pencarian flat list
                                  final parentName = selectedParent['nama'].toString().toLowerCase().replaceAll('polres ', '').replaceAll('polrestabes ', '').replaceAll('polresta ', '').trim();
                                  final parentKode = selectedParent['kode'].toString();
                                  
                                  childUnits = provider.tingkatOptions.where((item) {
                                    if (item == selectedParent) return false;
                                    
                                    final nama = item['nama']?.toString().toLowerCase() ?? '';
                                    final kode = item['kode']?.toString() ?? '';
                                    
                                    // Cek relasi ID
                                    if (item['parent_id']?.toString() == parentKode) return true;
                                    if (item['id_polres']?.toString() == parentKode) return true;
                                    
                                    // Cek relasi Kode Prefix
                                    if (kode.length > parentKode.length && kode.startsWith(parentKode)) return true;
                                    
                                    // Cek relasi Nama
                                    if (nama.contains(parentName) && nama.contains('polsek')) return true;
                                    
                                    return false;
                                  }).toList();
                                }
                              }
                            }

                            return Column(
                              children: [
                                _buildSearchableDropdown<dynamic>(
                                  label: "Kesatuan / Polres",
                                  hint: "Pilih Polres",
                                  value: parentUnits.firstWhere(
                                    (p) => p['kode'].toString() == _selectedPolresKode, 
                                    orElse: () => null
                                  ),
                                  icon: Icons.account_balance_outlined,
                                  items: parentUnits,
                                  itemAsString: (item) => item['nama']?.toString() ?? "",
                                  compareFn: (i1, i2) => i1['kode'] == i2['kode'],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedPolresKode = val['kode'].toString();
                                        _selectedPolsekKode = null; // Reset Polsek jika Polres berubah
                                      });
                                    }
                                  },
                                ),
                                if (childUnits.isNotEmpty)
                                  _buildSearchableDropdown<dynamic>(
                                    label: "Polsek (Opsional)",
                                    hint: "Pilih Polsek",
                                    value: childUnits.firstWhere(
                                      (p) => p['kode'].toString() == _selectedPolsekKode, 
                                      orElse: () => null
                                    ),
                                    icon: Icons.local_police_outlined,
                                    items: [
                                      {'kode': null, 'nama': "-- Polres / Satker Pusat --"},
                                      ...childUnits
                                    ],
                                    itemAsString: (item) {
                                      String n = item['nama']?.toString() ?? "";
                                      return n.split(',')[0].trim();
                                    },
                                    compareFn: (i1, i2) => i1['kode'] == i2['kode'],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedPolsekKode = val['kode']?.toString());
                                      }
                                    },
                                    isOptional: true,
                                  ),
                              ],
                            );
                          }),

                          // Dropdown Jabatan
                          _buildSearchableDropdown<dynamic>(
                            label: "Jabatan",
                            hint: "Pilih Jabatan",
                            value: provider.jabatanOptions.firstWhere(
                              (p) => p['id'].toString() == _selectedJabatanId?.toString(), 
                              orElse: () => null
                            ),
                            icon: Icons.work_outline_rounded,
                            items: provider.jabatanOptions,
                            itemAsString: (item) => item['nama_jabatan'] ?? item['nama'] ?? "",
                            compareFn: (i1, i2) => i1['id'] == i2['id'],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedJabatanId = int.tryParse(val['id'].toString()));
                              }
                            },
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

  Widget _buildSearchableDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemAsString,
    required ValueChanged<T?> onChanged,
    bool Function(T, T)? compareFn,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownSearch<T>(
        selectedItem: value,
        compareFn: compareFn ?? (i1, i2) => itemAsString(i1) == itemAsString(i2),
        items: (filter, loadProps) {
          if (filter.isEmpty) return items;
          return items.where((item) => itemAsString(item).toLowerCase().contains(filter.toLowerCase())).toList();
        },
        itemAsString: itemAsString,
        onChanged: onChanged,
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          searchDelay: Duration(milliseconds: 100),
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: "Ketik untuk mencari...",
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
        validator: isOptional ? null : (v) => v == null ? "Wajib dipilih" : null,
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