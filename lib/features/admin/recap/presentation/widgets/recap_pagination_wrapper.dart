import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import '../widgets/recap_data_row.dart';

class RecapPaginationWrapper extends StatefulWidget {
  final List<RecapModel> allItems;
  final Map<String, List<RecapModel>> groupedData;
  final Function(String, bool) onToggle;
  final Future<void> Function() onRefresh;

  const RecapPaginationWrapper({
    super.key,
    required this.allItems,
    required this.groupedData,
    required this.onToggle,
    required this.onRefresh,
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

    if (totalItems == 0) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(child: Text("Tidak ada data rekapitulasi.")),
          ],
        ),
      );
    }

    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex =
        (startIndex + _itemsPerPage < totalItems)
            ? startIndex + _itemsPerPage
            : totalItems;

    final List<String> currentKeys = polresKeys.sublist(startIndex, endIndex);
    final Map<String, List<RecapModel>> paginatedGroups = {
      for (var key in currentKeys) key: widget.groupedData[key]!,
    };

    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: RecapPage(
              key: ValueKey<int>(_currentPage),
              allItems: widget.allItems,
              polresGroups: paginatedGroups,
              onRefresh: widget.onRefresh,
            ),
          ),
        ),
        _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _NavButton(
                label: "Prev",
                icon: Icons.arrow_back_rounded,
                isEnabled: _currentPage > 0,
                onTap: () => setState(() => _currentPage--),
                isLeft: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
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
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: _NavButton(
                label: "Next",
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

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeft) Icon(icon, size: 16, color: color),
            if (isLeft) const SizedBox(width: 4),
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
    );
  }
}
