import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/personel_provider.dart';
import '../data/model/personel_model.dart'; // Pastikan import model benar
import './widgets/personel_card.dart';
import './widgets/personel_section_header.dart';
import './widgets/personel_toolbar.dart';

class PersonelPage extends ConsumerWidget {
  const PersonelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch data yang sudah dikelompokkan
    final groupedAsync = ref.watch(personelGroupedProvider);

    return Column(
      children: [
        // 1. Toolbar (Search & Filter)
        const PersonelToolbar(),

        // 2. List Data
        Expanded(
          child: groupedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Terjadi kesalahan: $e')),
            data: (groupedMap) {
              // Handle Empty State
              if (groupedMap.isEmpty) {
                return _buildEmptyState();
              }

              // Render List
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // Menggunakan physics agar scroll terasa natural di iOS/Android
                physics: const BouncingScrollPhysics(), 
                children: groupedMap.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Unit Kerja
                      PersonelSectionHeader(title: entry.key),
                      const SizedBox(height: 8),

                      // List Personel dalam Unit tersebut
                      ...entry.value.map((personel) => PersonelCard(
                        personel: personel,
                        // Navigasi ke Detail
                        onTap: () => _navigateToDetail(context, personel),
                        // Logika Edit
                        onEdit: () => _onEdit(context, personel),
                        // Logika Hapus
                        onDelete: () => _onDelete(context, ref, personel),
                      )),
                      
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW HELPERS (UI Components)
  // ==========================================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Tidak ada data personel",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LOGIC ACTIONS
  // ==========================================

  void _navigateToDetail(BuildContext context, Personel personel) {
    // TODO: Implementasi Navigasi ke halaman detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Melihat detail: ${personel.namaLengkap}")),
    );
  }

  void _onEdit(BuildContext context, Personel personel) {
    // TODO: Buka Dialog atau Halaman Edit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Edit data: ${personel.namaLengkap}")),
    );
  }

  void _onDelete(BuildContext context, WidgetRef ref, Personel personel) {
    // Tampilkan Dialog Konfirmasi sebelum hapus (Best Practice)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Personel?"),
        content: Text(
          "Anda yakin ingin menghapus data '${personel.namaLengkap}'? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              
              // Panggil Provider untuk hapus data
              // Pastikan model Personel Anda punya field 'id'
              await ref.read(personelProvider.notifier).delete(personel.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil dihapus")),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}