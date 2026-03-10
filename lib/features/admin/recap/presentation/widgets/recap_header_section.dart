import 'dart:async';
import 'package:flutter/material.dart';

class RecapHeaderSection extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final Function(String selection) onDownloadExcel;
  final List<Map<String, String>> polresOptions;

  const RecapHeaderSection({
    super.key,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onDownloadExcel,
    required this.polresOptions,
  });

  @override
  State<RecapHeaderSection> createState() => _RecapHeaderSectionState();
}

class _RecapHeaderSectionState extends State<RecapHeaderSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Menangani input pencarian dengan jeda 500ms (Debounce)
  void _onInputChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(query);
    });
    setState(() {});
  }

  // Menghapus teks pencarian
  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {});
    FocusScope.of(context).unfocus();
  }

  // Menampilkan menu pilihan download (Bottom Sheet)
  void _showDownloadMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Download Rekap Excel",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pilih data yang ingin kamu unduh:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Opsi Download Semua Data
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFF9100),
                  child: Icon(Icons.all_inclusive, color: Colors.white),
                ),
                title: const Text(
                  "Semua Data Wilayah",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Unduh rekap seluruh kabupaten"),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDownloadExcel("ALL");
                },
              ),
              const Divider(),

              // Daftar Kabupaten Spesifik
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Text(
                  "Pilih Kabupaten Spesifik:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.polresOptions.length,
                  itemBuilder: (context, index) {
                    final item = widget.polresOptions[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.map_outlined,
                        color: Colors.grey,
                      ),
                      title: Text(item['name'] ?? ""),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onDownloadExcel(item['id'] ?? "");
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Bar Pencarian
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF673AB7).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onInputChanged,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: "Cari Wilayah, Polsek...",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF673AB7),
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: _clearSearch,
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Filter
          _buildActionButton(
            icon: Icons.filter_list_alt,
            color: const Color(0xFF0097B2),
            onTap: widget.onFilterTap,
          ),
          const SizedBox(width: 12),

          // Tombol Download
          _buildActionButton(
            icon: Icons.download_rounded,
            color: const Color(0xFFFF9100),
            onTap: _showDownloadMenu,
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat tombol aksi (Filter/Download)
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          elevation: 4,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Icon(icon, size: 26),
      ),
    );
  }
}
