import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/presentation/widgets/add_personel_dialog.dart';

import '../../providers/personel_provider.dart';

class PersonelToolbar extends ConsumerWidget {
  const PersonelToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // BARIS 1: SEARCH BAR (Full Width)
          // ==========================================
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari nama, NRP, atau jabatan...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade50, // Background abu sangat muda
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            onChanged: (value) {
              // Panggil fungsi search di provider
              ref.read(personelProvider.notifier).search(value);
            },
          ),

          const SizedBox(height: 16),

          // ==========================================
          // BARIS 2: ACTIONS & PAGINATION
          // ==========================================
          Row(
            children: [
              // --- Dropdown Jumlah Data ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: 10,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 10, child: Text('Show 10')),
                      DropdownMenuItem(value: 25, child: Text('Show 25')),
                      DropdownMenuItem(value: 50, child: Text('Show 50')),
                    ],
                    onChanged: (val) {
                      // Todo: Implementasi update limit pagination
                    },
                  ),
                ),
              ),

              const Spacer(),
              const SizedBox(width: 8),

              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A7C4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // --- BAGIAN INI YANG DIUBAH ---
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        // Memanggil Widget Dialog UI yang sudah dibuat
                        return const AddPersonelDialog();
                      },
                    );
                  },
                  // -----------------------------
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () {
                    // Logic Bulk Delete atau Reset
                  },
                  child: const Icon(Icons.delete_outline, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
