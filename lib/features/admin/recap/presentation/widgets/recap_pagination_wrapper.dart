import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import 'recap_data_row.dart';

class RecapPaginationWrapper extends StatefulWidget {
  final Map<String, List<RecapModel>> groupedData;
  final Function(String, bool) onToggle; // Tambahkan ini

  const RecapPaginationWrapper({
    super.key,
    required this.groupedData,
    required this.onToggle, // Tambahkan ini
  });

  @override
  State<RecapPaginationWrapper> createState() => _RecapPaginationWrapperState();
}

class _RecapPaginationWrapperState extends State<RecapPaginationWrapper> {
  final int _itemsPerPage = 15;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> polresKeys = widget.groupedData.keys.toList();
    final int totalItems = polresKeys.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();

    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex =
        (startIndex + _itemsPerPage < totalItems)
            ? startIndex + _itemsPerPage
            : totalItems;

    if (totalItems == 0) {
      return const Center(child: Text("Tidak ada data rekapitulasi."));
    }

    final List<String> currentKeys = polresKeys.sublist(startIndex, endIndex);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey<int>(_currentPage),
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        itemCount: currentKeys.length + 1,
        itemBuilder: (context, index) {
          if (index == currentKeys.length) {
            return _buildPaginationControls(totalPages);
          }

          final String polresName = currentKeys[index];
          final List<RecapModel> items = widget.groupedData[polresName]!;

          return RecapPolresSection(
            polresName: polresName,
            itemsInPolres: items,
            onToggle: widget.onToggle, // Gunakan widget.onToggle
          );
        },
      ),
    );
  }

  // Widget Navigasi (Responsif / Anti-Error)
  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TOMBOL PREV (Kiri - Flexible)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _NavButton(
                label: "Sebelumnya",
                icon: Icons.arrow_back_rounded,
                isEnabled: _currentPage > 0,
                onTap: () => setState(() => _currentPage--),
                isLeft: true,
              ),
            ),
          ),

          // INDIKATOR HALAMAN (Tengah)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5), // Light Purple
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_currentPage + 1} / $totalPages",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF673AB7),
              ),
            ),
          ),

          // TOMBOL NEXT (Kanan - Flexible)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: _NavButton(
                label: "Selanjutnya",
                icon: Icons.arrow_forward_rounded,
                isEnabled: _currentPage < totalPages - 1,
                onTap: () => setState(() => _currentPage++),
                isLeft: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;
  final bool isLeft;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isEnabled,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        isEnabled ? const Color(0xFF673AB7) : Colors.grey.shade300;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLeft) Icon(icon, size: 16, color: color),
              if (isLeft) const SizedBox(width: 4),

              // Menggunakan Flexible agar teks mengecil/terpotong jika layar sempit
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),

              if (!isLeft) const SizedBox(width: 4),
              if (!isLeft) Icon(icon, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
