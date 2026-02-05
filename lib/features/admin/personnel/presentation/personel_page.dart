import 'package:KETAHANANPANGAN/features/admin/personnel/data/model/personel_model.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'widgets/personel_card.dart';
import 'widgets/personel_toolbar.dart'; // Import Toolbar Anda

class PersonelPage extends ConsumerWidget {
  const PersonelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil state dari provider
    final personelAsync = ref.watch(personelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F9),
      body: Column(
        children: [
          const PersonelToolbar(),

          // 3. List Data Personel
          Expanded(
            child: personelAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              
              // ERROR STATE
              error: (e, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan memuat data\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(personelProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),

              // DATA LOADED STATE
              data: (personelList) {
                if (personelList.isEmpty) {
                  return _buildEmptyState();
                }

                // Render List View
                return RefreshIndicator(
                  onRefresh: () => ref.read(personelProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics: const AlwaysScrollableScrollPhysics(), // Agar bisa refresh meski data sedikit
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOGIC ACTIONS (Edit & Delete)
  // Note: Add Logic sudah ada di dalam PersonelToolbar -> AddPersonelDialog
  // ==========================================

  void _navigateToDetail(BuildContext context, Personel personel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Detail: ${personel.namaLengkap}")),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Personel personel) {
    // Controller diisi data lama
    final nameController = TextEditingController(text: personel.namaLengkap);
    final jabatanController = TextEditingController(text: personel.jabatan);
    final phoneController = TextEditingController(text: personel.noTelp ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Personel"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
              ),
              TextField(
                controller: jabatanController,
                decoration: const InputDecoration(labelText: "Jabatan"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "No Telp"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              try {
                // Buat object update (ID & NRP tetap)
                final updated = Personel(
                  id: personel.id,
                  namaLengkap: nameController.text,
                  nrp: personel.nrp,
                  jabatan: jabatanController.text,
                  role: personel.role,
                  noTelp: phoneController.text,
                  fotoProfil: personel.fotoProfil,
                );

                await ref.read(personelProvider.notifier).updatePersonel(updated);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil diperbarui")),
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
            child: const Text("Simpan"),
          ),
        ],
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
            child: const Text("Batal"),
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