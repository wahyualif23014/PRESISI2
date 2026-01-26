import 'package:flutter/material.dart';

class LandFilterDialog extends StatefulWidget {
  const LandFilterDialog({super.key});

  @override
  State<LandFilterDialog> createState() => _LandFilterDialogState();
}

class _LandFilterDialogState extends State<LandFilterDialog> {
  bool _cbKabupaten = false;
  bool _cbKecamatan = false;
  bool _cbDesa = false;
  bool _cbBelumTervalidasi = false;
  bool _cbTervalidasi = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        width: 340, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter Data Kelola Lahan",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Data",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF00C853)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Kategori Filter",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel("Wilayah"),
                      _buildCheckboxItem("Kabupaten", _cbKabupaten, (val) => setState(() => _cbKabupaten = val!)),
                      _buildCheckboxItem("Kecamatan", _cbKecamatan, (val) => setState(() => _cbKecamatan = val!)),
                      _buildCheckboxItem("Desa", _cbDesa, (val) => setState(() => _cbDesa = val!)),
                    ],
                  ),
                ),
                
                Container(
                  width: 1,
                  height: 120,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel("Status"),
                      _buildCheckboxItem("Belum Tervalidasi", _cbBelumTervalidasi, (val) => setState(() => _cbBelumTervalidasi = val!), maxLines: 2),
                      _buildCheckboxItem("Tervalidasi", _cbTervalidasi, (val) => setState(() => _cbTervalidasi = val!)),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Apply Filter",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                Container(
                  width: 1.5,
                  height: 24,
                  color: Colors.black87, 
                ),
                const SizedBox(width: 8),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _cbKabupaten = false;
                      _cbKecamatan = false;
                      _cbDesa = false;
                      _cbBelumTervalidasi = false;
                      _cbTervalidasi = false;
                      _searchController.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF0097B2),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(String label, bool value, ValueChanged<bool?> onChanged, {int maxLines = 1}) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                activeColor: const Color(0xFF00C853),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87, 
                  fontSize: 13,
                  height: 1.2, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}