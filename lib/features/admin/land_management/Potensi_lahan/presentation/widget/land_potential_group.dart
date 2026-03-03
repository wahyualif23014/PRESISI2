import 'package:flutter/material.dart';
import '../../data/model/land_potential_model.dart';
import '../../data/service/land_potential_service.dart';
import 'land_detail_dialog.dart';

class KabupatenExpansionTile extends StatelessWidget {
  final String kabupatenName;
  final List<LandPotentialModel> itemsInKabupaten;
  final Function(LandPotentialModel) onEdit;
  final Function(LandPotentialModel) onDelete;
  final VoidCallback onRefresh;

  const KabupatenExpansionTile({
    super.key,
    required this.kabupatenName,
    required this.itemsInKabupaten,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
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
                onRefresh: onRefresh,
              );
            }).toList(),
      ),
    );
  }
}

class LandPotentialCard extends StatefulWidget {
  final LandPotentialModel data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const LandPotentialCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<LandPotentialCard> createState() => _LandPotentialCardState();
}

class _LandPotentialCardState extends State<LandPotentialCard> {
  final LandPotentialService _service = LandPotentialService();
  bool _isProcessing = false;

  bool _checkIsValidated() {
    final v = widget.data.namaValidator.trim();
    if (v == "" || v == "null" || v == "-" || v == "0") {
      return false;
    }
    return true;
  }

  // Fungsi untuk menampilkan Dialog Konfirmasi (Notifikasi)
  Future<void> _showConfirmDialog(bool isCurrentlyValidated) async {
    final title = isCurrentlyValidated ? "Batalkan Validasi" : "Validasi Data";
    final message =
        isCurrentlyValidated
            ? "Apakah kamu yakin ingin membatalkan validasi data lahan ini?"
            : "Apakah kamu yakin ingin memvalidasi data lahan ini? Nama kamu akan tercatat sebagai penvalidasi.";

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrentlyValidated ? Colors.orange : Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context);
                _handleToggleValidation();
              },
              child: Text(
                isCurrentlyValidated ? "YA, BATALKAN" : "YA, VALIDASI",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleToggleValidation() async {
    setState(() => _isProcessing = true);

    // Backend akan otomatis menyimpan Nama (Fajri) & ID (23171) berdasarkan Token Login
    bool success = await _service.toggleValidation(widget.data.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_checkIsValidated()
                ? "Data Berhasil divalidasi"
                : "Validasi Telah dibatalkan",
          ),
          backgroundColor: !_checkIsValidated() ? Colors.green : Colors.orange,
        ),
      );
      widget
          .onRefresh(); // Refresh untuk menarik Nama Penvalidasi terbaru dari DB
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  void _showDetail(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => LandDetailDialog(data: widget.data),
    );
    if (result == true) {
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isValidated = _checkIsValidated();

    return InkWell(
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
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("POLISI PENGGERAK"),
                  _buildName(
                    widget.data.policeName.isNotEmpty
                        ? widget.data.policeName
                        : "-",
                  ),
                  _buildPhone(widget.data.policePhone),
                  const SizedBox(height: 8),
                  Divider(
                    color: Colors.grey.shade400,
                    height: 1,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 8),
                  _buildLabel("PENANGGUNG JAWAB"),
                  _buildName(
                    widget.data.picName.isNotEmpty ? widget.data.picName : "-",
                  ),
                  _buildPhone(widget.data.picPhone),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("ALAMAT LAHAN"),
                  Text(
                    widget.data.alamatLahan.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "DESA ${widget.data.desa}",
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                  Text(
                    "KOMODITI: ${widget.data.komoditi}",
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                        color: isValidated ? Colors.green : Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isValidated ? 'TERVALIDASI' : 'BELUM TERVALIDASI',
                      style: TextStyle(
                        color: isValidated ? Colors.green : Colors.orange,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Menampilkan siapa yang memvalidasi di bawah badge (jika sudah divalidasi)
                  if (isValidated)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.data.infoValidasi,
                        style: const TextStyle(
                          fontSize: 7,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.right,
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
                        _buildActionIcon(
                          _isProcessing
                              ? Icons.hourglass_empty
                              : (isValidated
                                  ? Icons.unpublished_rounded
                                  : Icons.check_circle_rounded),
                          isValidated ? Colors.orange : Colors.green,
                          _isProcessing
                              ? null
                              : () => _showConfirmDialog(isValidated),
                        ),
                        _buildVerticalDivider(),
                        _buildActionIcon(
                          Icons.edit_rounded,
                          Colors.blue,
                          widget.onEdit,
                        ),
                        _buildVerticalDivider(),
                        _buildActionIcon(
                          Icons.delete_outline_rounded,
                          Colors.red,
                          widget.onDelete,
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
      fontSize: 8,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
    ),
  );
  Widget _buildName(String text) => Text(
    text,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
  Widget _buildPhone(String text) =>
      Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[600]));
  Widget _buildVerticalDivider() =>
      Container(width: 1, height: 20, color: Colors.grey.shade300);

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(icon, size: 18, color: onTap == null ? Colors.grey : color),
      ),
    );
  }
}
