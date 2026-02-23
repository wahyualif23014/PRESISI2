import 'package:flutter/material.dart';

class RecapHeaderSection extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onPrintTap;

  const RecapHeaderSection({
    Key? key,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onPrintTap,
  }) : super(key: key);

  @override
  State<RecapHeaderSection> createState() => _RecapHeaderSectionState();
}

class _RecapHeaderSectionState extends State<RecapHeaderSection> {
  final TextEditingController _searchController = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchChanged('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // SEARCH BAR
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
                onChanged: widget.onSearchChanged,
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
                      _showClearButton
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

          // FILTER BUTTON
          _buildActionButton(
            icon: Icons.filter_list_alt, // Icon lebih modern
            color: const Color(0xFF0097B2),
            onTap: widget.onFilterTap,
          ),

          const SizedBox(width: 12),

          // DOWNLOAD BUTTON
          _buildActionButton(
            icon: Icons.download_rounded,
            color: const Color(0xFFFF9100),
            onTap: widget.onPrintTap,
          ),
        ],
      ),
    );
  }

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
