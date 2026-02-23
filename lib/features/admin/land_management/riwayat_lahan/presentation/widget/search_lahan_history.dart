import 'package:flutter/material.dart';

class SearchLahanHistory extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const SearchLahanHistory({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                return TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "Cari Wilayah Riwayat",
                    hintStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.black87),
                    suffixIcon:
                        value.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                controller.clear();
                                onChanged("");
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF0097B2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Filter",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
