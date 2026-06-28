import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';

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
    // 1. Group by Kecamatan (Polsek)
    Map<String, List<LandPotentialModel>> groupedByKecamatan = {};
    for (var item in itemsInKabupaten) {
      String kecName = item.kecamatan.isEmpty || item.kecamatan == '-' 
          ? "KECAMATAN TIDAK TERDATA" 
          : "KECAMATAN ${item.kecamatan.toUpperCase()}";
      groupedByKecamatan.putIfAbsent(kecName, () => []).add(item);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedBackgroundColor: const Color(0xFF9FA8DA),
        backgroundColor: const Color(0xFFC5CAE9),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Text(
          kabupatenName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        iconColor: Colors.black54,
        collapsedIconColor: Colors.black54,
        children: groupedByKecamatan.entries.map((kecEntry) {
          return KecamatanExpansionGroup(
            kecamatanName: kecEntry.key,
            items: kecEntry.value,
            onEdit: onEdit,
            onDelete: onDelete,
            onRefresh: onRefresh,
          );
        }).toList(),
      ),
    );
  }
}

class KecamatanExpansionGroup extends StatelessWidget {
  final String kecamatanName;
  final List<LandPotentialModel> items;
  final Function(LandPotentialModel) onEdit;
  final Function(LandPotentialModel) onDelete;
  final VoidCallback onRefresh;

  const KecamatanExpansionGroup({
    super.key,
    required this.kecamatanName,
    required this.items,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Group by Desa
    Map<String, List<LandPotentialModel>> groupedByDesa = {};
    for (var item in items) {
      String desaName = item.desa.isEmpty || item.desa == '-' 
          ? "DESA TIDAK TERDATA" 
          : "DESA ${item.desa.toUpperCase()}";
      groupedByDesa.putIfAbsent(desaName, () => []).add(item);
    }

    return Container(
      color: Colors.white,
      child: ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.grey.shade50,
        title: Text(
          kecamatanName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF1A237E),
          ),
        ),
        children: groupedByDesa.entries.map((desaEntry) {
          double totalLuas = 0;
          for (var item in desaEntry.value) {
            totalLuas += item.luasLahan;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      desaEntry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      "Total Potensi: ${totalLuas.toStringAsFixed(2)} Ha",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: desaEntry.value.map((data) {
                  return LandPotentialCard(
                    data: data,
                    onEdit: () => onEdit(data),
                    onDelete: () => onDelete(data),
                    onRefresh: onRefresh,
                  );
                }).toList(),
              ),
            ],
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
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isProcessing = false;

  bool _checkIsValidated() {
    final v = widget.data.namaValidator.trim();
    return !(v == "" || v == "null" || v == "-" || v == "0");
  }

  Future<bool> _checkLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }

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
    final isLoggedIn = await _checkLogin();

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sesi login tidak ditemukan. Silakan login ulang"),
        ),
      );
      return;
    }

    // Konversi ID string menjadi int yang valid
    int landId = int.tryParse(widget.data.id.toString()) ?? 0;

    if (landId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ID lahan tidak valid")));
      return;
    }

    setState(() => _isProcessing = true);

    // Hanya kirimkan landId bertipe int
    bool success = await _service.toggleValidation(landId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !_checkIsValidated()
                ? "Data berhasil divalidasi"
                : "Validasi berhasil dibatalkan",
          ),
          backgroundColor: !_checkIsValidated() ? Colors.green : Colors.orange,
        ),
      );

      widget.onRefresh();
    }

    setState(() => _isProcessing = false);
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
    final bool isValidated = _checkIsValidated() || widget.data.statusValidasi == '2';
    final bool isRejected = widget.data.statusValidasi == '3' || widget.data.statusValidasi.toLowerCase().contains('tolak');

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
                        color: isValidated ? Colors.green : (isRejected ? Colors.red : Colors.orange),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isValidated ? 'TERVALIDASI' : (isRejected ? 'DITOLAK' : 'BELUM TERVALIDASI'),
                      style: TextStyle(
                        color: isValidated ? Colors.green : (isRejected ? Colors.red : Colors.orange),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isValidated || isRejected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isValidated ? widget.data.infoValidasi : "Menunggu perbaikan data",
                        style: const TextStyle(
                          fontSize: 7,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  const SizedBox(height: 12),
                  
                  // Role Checking
                  Builder(builder: (context) {
                    final auth = context.watch<AuthProvider>();
                    final isPolsek = (auth.user?.tingkatDetail?.nama ?? '').toUpperCase().contains('POLSEK');
                    final isRejected = widget.data.statusValidasi.toLowerCase().contains('tolak') || widget.data.statusValidasi == '2';
                    final canEditOrDelete = !isPolsek || isRejected;

                    // Jika Polsek dan sudah divalidasi atau belum ditolak, tidak tampilkan tombol action
                    if (isPolsek && !isRejected) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isPolsek) ...[
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
                          ],
                          if (canEditOrDelete) ...[
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
                          ]
                        ],
                      ),
                    );
                  }),
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
