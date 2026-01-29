import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/commodities/data/models/commodity_model.dart';

class CommodityListItem extends StatelessWidget {
  final CommodityModel item;
  final VoidCallback onToggleSelection;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const CommodityListItem({
    super.key,
    required this.item,
    required this.onToggleSelection,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // 1. CHECKBOX
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: item.isSelected,
              onChanged: (val) => onToggleSelection(),
              activeColor: Colors.purple, // Sesuaikan tema app
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          
          // 2. NAMA KOMODITI
          Expanded(
            child: Text(
              item.name, // "AKASIA"
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // 3. TOMBOL AKSI (Edit & Delete)
          Row(
            children: [
              // Edit Icon (Biru)
              InkWell(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.edit_square, size: 16, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              
              // Delete Icon (Merah)
              InkWell(
                onTap: onDeleteTap,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.delete, size: 16, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}