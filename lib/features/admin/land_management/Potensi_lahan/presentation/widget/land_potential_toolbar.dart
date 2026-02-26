import 'package:flutter/material.dart';

class LandPotentialToolbar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onAddTap;

  const LandPotentialToolbar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onAddTap,
  });

  @override
  State<LandPotentialToolbar> createState() => _LandPotentialToolbarState();
}

class _LandPotentialToolbarState extends State<LandPotentialToolbar> {
  // Controller untuk mengontrol teks dan menghapusnya
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // ==============================
          // 1. SEARCH BAR
          // ==============================
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
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Memicu perubahan UI untuk tombol X
                  setState(() {});
                  widget.onSearchChanged(value);
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Cari Data Lahan",
                  hintStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black87,
                    size: 28,
                  ),
                  // Tombol X untuk menghapus teks (Muncul jika teks tidak kosong)
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged("");
                              setState(
                                () {},
                              ); // Menghilangkan tombol X setelah hapus
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ==============================
          // 2. TOMBOL FILTER
          // ==============================
          _buildActionButton(
            icon: Icons.filter_alt,
            color: const Color(0xFF0097B2),
            onTap: widget.onFilterTap,
          ),

          const SizedBox(width: 12),

          // ==============================
          // 3. TOMBOL TAMBAH
          // ==============================
          _buildActionButton(
            icon: Icons.add,
            color: const Color(0xFF00C853),
            onTap: widget.onAddTap,
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk tombol kotak (Filter & Tambah)
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color,
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(child: Icon(icon, color: Colors.white, size: 28)),
        ),
      ),
    );
  }
}
