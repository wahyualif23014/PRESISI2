import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/presentation/widgets/add_personel_dialog.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/providers/personel_provider.dart';

class PersonelToolbar extends StatelessWidget {
  const PersonelToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => context.read<PersonelProvider>().filterPersonel(value),
            decoration: InputDecoration(
              hintText: 'Cari nama, NRP, atau jabatan...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Personel'),
                  onPressed: () => showDialog(context: context, builder: (_) => const AddPersonelDialog()),
                ),
              ),
              const SizedBox(width: 8),
              // IconButton(
              //   onPressed: () => context.read<PersonelProvider>().fetchPersonel(),
              //   icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
              //   style: IconButton.styleFrom(
              //     backgroundColor: const Color(0xFFF1F5F9),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}