import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';

import 'widgets/personel_card.dart';
import 'widgets/personel_toolbar.dart';

class PersonelPage extends StatefulWidget {
  const PersonelPage({super.key});

  @override
  State<PersonelPage> createState() => _PersonelPageState();
}

class _PersonelPageState extends State<PersonelPage> {
  @override
  void initState() {
    super.initState();
    // Fetch data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonelProvider>().fetchPersonel();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer dari package:provider
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F9),
      body: Column(
        children: [
          const PersonelToolbar(),

          Expanded(
            child: Consumer<PersonelProvider>(
              builder: (context, provider, child) {
                // 1. Loading State
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error State
                if (provider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan:\n${provider.errorMessage}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => provider.fetchPersonel(),
                          child: const Text("Coba Lagi"),
                        )
                      ],
                    ),
                  );
                }

                // 3. Empty State
                if (provider.personelList.isEmpty) {
                  return _buildEmptyState();
                }

                // 4. Data List State
                return RefreshIndicator(
                  onRefresh: () => provider.fetchPersonel(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: provider.personelList.length,
                    separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final UserModel user = provider.personelList[index];
                      
                      return PersonelCard(
                        personel: user, 
                        onTap: () => _navigateToDetail(context, user),
                        onEdit: () => _showEditDialog(context, user),
                        onDelete: () => _onDelete(context, user),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Belum ada data personel",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, UserModel user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Detail: ${user.namaLengkap}")),
    );
  }


  void _showEditDialog(BuildContext context, UserModel user) {
    // 1. Setup Controller
    final nameController = TextEditingController(text: user.namaLengkap);
    

    final jabatanController = TextEditingController(text: user.jabatanDetail?.namaJabatan ?? '');
    
    final phoneController = TextEditingController(text: user.noTelp);
    
    // 2. Setup Variable State untuk Role (Default ambil dari data lama '1','2', atau '3')
    String selectedRole = user.role; 

    final formKey = GlobalKey<FormState>();
    const primaryDark = Color(0xFF1E293B); 
    const inputFillColor = Color(0xFFF8FAFC); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              elevation: 8,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // A. HEADER SOLID
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        color: primaryDark,
                        child: Row(
                          children: [
                            const Icon(Icons.edit_document, color: Colors.white, size: 24),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                "Perbarui Data & Akses",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(ctx),
                              child: Icon(Icons.close, color: Colors.white.withOpacity(0.7)),
                            )
                          ],
                        ),
                      ),

                      // B. FORM BODY
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("INFORMASI UTAMA"),
                              const SizedBox(height: 8),
                              
                              _buildStyledField(
                                controller: nameController,
                                hint: "Nama Lengkap",
                                icon: Icons.person_outline,
                                fillColor: inputFillColor,
                              ),
                              const SizedBox(height: 16),
                              
                              // Catatan: Idealnya ini Dropdown ID Jabatan
                              _buildStyledField(
                                controller: jabatanController,
                                hint: "Jabatan (Teks)",
                                icon: Icons.work_outline,
                                fillColor: inputFillColor,
                              ),

                              const SizedBox(height: 24),
                              _buildLabel("HAK AKSES (ROLE)"),
                              const SizedBox(height: 8),

                              // --- DROPDOWN ROLE (STRING) ---
                              Container(
                                decoration: BoxDecoration(
                                  color: inputFillColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedRole,
                                  decoration: InputDecoration(
                                    labelText: "Pilih Role",
                                    prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: Colors.grey.shade500, size: 22),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  // Item Dropdown Manual sesuai Logic Database
                                  items: const [
                                    DropdownMenuItem(value: '1', child: Text("ADMINISTRATOR")),
                                    DropdownMenuItem(value: '2', child: Text("OPERATOR")),
                                    DropdownMenuItem(value: '3', child: Text("VIEW ONLY")),
                                  ],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedRole = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                              // ---------------------

                              const SizedBox(height: 24),
                              _buildLabel("KONTAK"),
                              const SizedBox(height: 8),

                              _buildStyledField(
                                controller: phoneController,
                                hint: "Nomor Telepon",
                                icon: Icons.phone_android_rounded,
                                inputType: TextInputType.phone,
                                fillColor: inputFillColor,
                              ),

                              const SizedBox(height: 32),

                              // C. ACTION BUTTONS
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: Colors.grey.shade300),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text("Batal", style: TextStyle(color: Colors.grey.shade700)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  Expanded(
                                    flex: 2, 
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryDark,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        if (!formKey.currentState!.validate()) return;
                                        Navigator.pop(ctx);

                                        try {
                                          // Update data menggunakan UserModel
                                          final updatedUser = UserModel(
                                            id: user.id,
                                            namaLengkap: nameController.text,
                                            idTugas: user.idTugas, // ID Tugas biasanya tidak diedit di sini
                                            username: user.username,
                                            idJabatan: user.idJabatan, // Harusnya ID Jabatan, sementara pakai yg lama
                                            role: selectedRole, // Role Baru ('1','2','3')
                                            noTelp: phoneController.text,
                                            fotoProfil: user.fotoProfil,
                                            jabatanDetail: user.jabatanDetail,
                                          );

                                          await context.read<PersonelProvider>().updatePersonel(updatedUser);

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text("Data berhasil diperbarui"),
                                                backgroundColor: Colors.green[700],
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text(
                                        "Simpan Perubahan",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget Helper Field Text
  Widget _buildStyledField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color fillColor,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) => value == null || value.isEmpty ? "$hint tidak boleh kosong" : null,
      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 1.2,
      ),
    );
  }

  void _onDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Yakin ingin menghapus ${user.namaLengkap}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<PersonelProvider>().deletePersonel(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data telah dihapus")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal hapus: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}