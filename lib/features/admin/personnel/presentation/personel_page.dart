import 'package:KETAHANANPANGAN/features/admin/personnel/data/model/personel_model.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/data/model/role_enum.dart'; // Pastikan import Enum Role ada
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/personel_card.dart';
import 'widgets/personel_toolbar.dart';

class PersonelPage extends ConsumerWidget {
  const PersonelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personelAsync = ref.watch(personelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F9),
      body: Column(
        children: [
          const PersonelToolbar(),

          // List Data Personel
          Expanded(
            child: personelAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Terjadi kesalahan\n$e', textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: () => ref.refresh(personelProvider),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
              data: (personelList) {
                if (personelList.isEmpty) return _buildEmptyState();

                return RefreshIndicator(
                  onRefresh: () => ref.read(personelProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: personelList.length,
                    separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final personel = personelList[index];
                      return PersonelCard(
                        personel: personel,
                        onTap: () => _navigateToDetail(context, personel),
                        onEdit: () => _showEditDialog(context, ref, personel),
                        onDelete: () => _onDelete(context, ref, personel),
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

  void _navigateToDetail(BuildContext context, Personel personel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Detail: ${personel.namaLengkap}")),
    );
  }

  // =========================================================================
  // FOKUS OPTIMALISASI UI & LOGIC ROLE DI SINI
  // =========================================================================
  void _showEditDialog(BuildContext context, WidgetRef ref, Personel personel) {
    // 1. Setup Controller
    final nameController = TextEditingController(text: personel.namaLengkap);
    final jabatanController = TextEditingController(text: personel.jabatan);
    final phoneController = TextEditingController(text: personel.noTelp ?? "");
    
    // 2. Setup Variable State untuk Role (Default ambil dari data lama)
    UserRole selectedRole = personel.role;

    final formKey = GlobalKey<FormState>();

    // Palet Warna
    const primaryDark = Color(0xFF1E293B); 
    const inputFillColor = Color(0xFFF8FAFC); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // PENTING: Gunakan StatefulBuilder agar Dropdown bisa berubah saat dipilih
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              elevation: 8,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
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
                                  letterSpacing: 0.5,
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
                              
                              _buildStyledField(
                                controller: jabatanController,
                                hint: "Jabatan",
                                icon: Icons.work_outline,
                                fillColor: inputFillColor,
                              ),

                              const SizedBox(height: 24),
                              _buildLabel("HAK AKSES (ROLE)"), // Label Section Baru
                              const SizedBox(height: 8),

                              // --- DROPDOWN ROLE ---
                              Container(
                                decoration: BoxDecoration(
                                  color: inputFillColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonFormField<UserRole>(
                                  value: selectedRole,
                                  decoration: InputDecoration(
                                    labelText: "Pilih Role",
                                    labelStyle: TextStyle(color: Colors.grey.shade600),
                                    prefixIcon: Icon(Icons.admin_panel_settings_outlined, color: Colors.grey.shade500, size: 22),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  items: UserRole.values.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role.label.toUpperCase(), // Pastikan enum punya .label atau .name
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (UserRole? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedRole = newValue; // Update State Lokal Dialog
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
                                          final updated = Personel(
                                            id: personel.id,
                                            namaLengkap: nameController.text,
                                            nrp: personel.nrp,
                                            jabatan: jabatanController.text,
                                            role: selectedRole, // <--- UPDATE ROLE BARU DI SINI
                                            noTelp: phoneController.text,
                                            fotoProfil: personel.fotoProfil,
                                          );

                                          await ref.read(personelProvider.notifier).updatePersonel(updated);

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text("Data & Role berhasil diperbarui"),
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
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E293B), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
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

  void _onDelete(BuildContext context, WidgetRef ref, Personel personel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Yakin ingin menghapus ${personel.namaLengkap}?"),
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
                await ref.read(personelProvider.notifier).delete(personel.id);
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