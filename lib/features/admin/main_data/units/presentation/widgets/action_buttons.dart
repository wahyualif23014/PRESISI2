import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onFilter;

  const ActionButtons({super.key, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onFilter,
        icon: const Icon(Icons.filter_list, size: 20),
        label: const Text("FILTER DATA"),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF102C57),
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}