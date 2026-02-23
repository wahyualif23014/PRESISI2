import 'package:flutter/material.dart';
import '../../data/model/land_potential_model.dart';
import 'land_detail_dialog.dart';

// WIDGET GROUP (HEADER KABUPATEN)
class KabupatenExpansionTile extends StatelessWidget {
  final String kabupatenName;
  final List<LandPotentialModel> itemsInKabupaten;
  final Function(LandPotentialModel) onEdit;
  final Function(LandPotentialModel) onDelete;

  const KabupatenExpansionTile({
    super.key,
    required this.kabupatenName,
    required this.itemsInKabupaten,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedBackgroundColor: const Color(0xFF9FA8DA),
        backgroundColor: const Color(0xFFC5CAE9),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          kabupatenName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        iconColor: Colors.black54,
        collapsedIconColor: Colors.black54,
        children:
            itemsInKabupaten.map((data) {
              return LandPotentialCard(
                data: data,
                onEdit: () => onEdit(data),
                onDelete: () => onDelete(data),
              );
            }).toList(),
      ),
    );
  }
}

// WIDGET CARD (ISI DATA)
class LandPotentialCard extends StatelessWidget {
  final LandPotentialModel data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LandPotentialCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  // --- FUNGSI UNTUK MENAMPILKAN DIALOG DETAIL ---
  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LandDetailDialog(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // --- SEKARANG BISA DIKLIK DI SELURUH AREA KARTU ---
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KOLOM 1: INFO PERSONEL
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("POLISI PENGGERAK"),
                  const SizedBox(height: 2),
                  _buildName(
                    data.policeName.isNotEmpty ? data.policeName : "-",
                  ),
                  _buildPhone(data.policePhone),

                  const SizedBox(height: 8),
                  Divider(
                    color: Colors.grey.shade400,
                    height: 1,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 8),

                  _buildLabel("PENANGGUNG JAWAB"),
                  const SizedBox(height: 2),
                  _buildName(data.picName.isNotEmpty ? data.picName : "-"),
                  _buildPhone(data.picPhone),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // KOLOM 2: ALAMAT
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("ALAMAT LAHAN"),
                  const SizedBox(height: 4),
                  Text(
                    data.alamatLahan.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "DESA ${data.desa}",
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // KOLOM 3: STATUS & AKSI
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color:
                            data.statusValidasi == 'TERVALIDASI'
                                ? Colors.green
                                : Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data.statusValidasi == 'TERVALIDASI'
                          ? 'TERVALIDASI'
                          : 'BELUM TERVALIDASI',
                      style: TextStyle(
                        color:
                            data.statusValidasi == 'TERVALIDASI'
                                ? Colors.green
                                : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TOMBOL LIHAT DETAIL (IKON PERTAMA)
                        _buildIconButton(
                          Icons.list_alt_rounded,
                          Colors.teal,
                          () => _showDetail(context),
                        ),
                        _buildVerticalDivider(),
                        _buildIconButton(
                          Icons.edit_rounded,
                          Colors.blue,
                          onEdit,
                        ),
                        _buildVerticalDivider(),
                        _buildIconButton(
                          Icons.delete_outline_rounded,
                          Colors.red,
                          onDelete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 9,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
  Widget _buildName(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
  Widget _buildPhone(String text) =>
      Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600]));
  Widget _buildVerticalDivider() =>
      Container(width: 1, height: 20, color: Colors.grey.shade300);
  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(icon, size: 18, color: color),
        ),
      );
}
