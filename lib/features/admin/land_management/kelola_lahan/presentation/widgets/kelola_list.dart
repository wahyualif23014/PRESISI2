import 'package:flutter/material.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';

class KelolaRegionExpansionGroup extends StatelessWidget {
  final String title;
  final List<LandManagementItemModel> items;
  final VoidCallback onRefresh;

  const KelolaRegionExpansionGroup({
    super.key,
    required this.title,
    required this.items,
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
          title.toUpperCase(),
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
            items.map((data) {
              return KelolaItemDetailCard(item: data, onRefresh: onRefresh);
            }).toList(),
      ),
    );
  }
}

class KelolaItemDetailCard extends StatelessWidget {
  final LandManagementItemModel item;
  final VoidCallback onRefresh;

  const KelolaItemDetailCard({
    super.key,
    required this.item,
    required this.onRefresh,
  });

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A237E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.assignment, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        "DETAIL DATA LAHAN & TANAM",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection(
                          "Informasi Lokasi & Lahan",
                          Icons.location_on,
                          [
                            _dataRow("Kepolisian Resor", item.polresName),
                            _dataRow("Kepolisian Sektor", item.polsekName),
                            _dataRow("Alamat Lahan", item.alamatLahan),
                            _dataRow("Wilayah", item.wilayahLahan),
                            _dataRow("Jenis Lahan", item.jenisLahanName),
                            _dataRow(
                              "Luas Lahan",
                              "${item.landArea} Ha",
                              isLast: true,
                            ),
                          ],
                        ),
                        _buildDetailSection(
                          "Informasi Personel",
                          Icons.groups,
                          [
                            _dataRow(
                              "Polisi Penggerak",
                              "${item.policeName}\n(${item.policePhone})",
                            ),
                            _dataRow(
                              "Penanggung Jawab",
                              "${item.picName}\n(${item.picPhone})",
                            ),
                            _dataRow("Jumlah Poktan", item.jmlPoktan),
                            _dataRow(
                              "Jumlah Petani",
                              "${item.jmlPetani} Orang",
                              isLast: true,
                            ),
                          ],
                        ),
                        _buildDetailSection("Data Tanam", Icons.grass, [
                          _dataRow("Komoditi", item.komoditiName),
                          _dataRow("Tanggal Tanam", item.tglTanam),
                          _dataRow("Luas Tanam", "${item.luasTanamDetail} Ha"),
                          _dataRow("Jenis Bibit", item.jenisBibit),
                          _dataRow(
                            "Kebutuhan Bibit",
                            "${item.kebutuhanBibit} Kg",
                          ),
                          _dataRow("Estimasi Panen", item.estPanen),
                          _dataRow("Keterangan Lahan", item.keterangan),
                          _dataRow("Keterangan Lain", item.keteranganLain),
                          _dataRow("Catatan Tanam", item.keteranganTanam),
                          _dataRow(
                            "Dokumen Pendukung",
                            item.dokumenPendukung.isEmpty
                                ? "Tidak ada file"
                                : item.dokumenPendukung,
                            isLast: true,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "TUTUP",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UpdateTanamDialog(item: item, onSuccess: onRefresh),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Hapus Data?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "Apakah Anda yakin ingin menghapus data lahan ini?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "BATAL",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await LandManagementRepository().deleteLahan(
                    item.id,
                  );
                  if (success) onRefresh();
                },
                child: const Text(
                  "HAPUS",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> rows) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1A237E)),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A237E),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String val, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                " : ",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  val.trim().isEmpty ? "-" : val,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 6),
            Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isValidated =
        item.status == 'VALIDATED' || item.status == 'TERVALIDASI';

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
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLabel("POLISI PENGGERAK"),
                  _buildName(
                    item.policeName.isNotEmpty ? item.policeName : "-",
                  ),
                  _buildPhone(item.policePhone),
                  const SizedBox(height: 8),
                  Divider(
                    color: Colors.grey.shade400,
                    height: 1,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 8),
                  _buildLabel("PENANGGUNG JAWAB"),
                  _buildName(item.picName.isNotEmpty ? item.picName : "-"),
                  _buildPhone(item.picPhone),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLabel("ALAMAT LAHAN"),
                  Text(
                    item.alamatLahan.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.wilayahLahan,
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "KOMODITI: ${item.komoditiName}",
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mencegah overflow horizontal pada layar kecil
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionIcon(
                            Icons.visibility,
                            Colors.blue,
                            () => _showDetail(context),
                          ),
                          _buildVerticalDivider(),
                          _buildActionIcon(
                            Icons.edit_rounded,
                            Colors.orange.shade700,
                            () => _showUpdateDialog(context),
                          ),
                          _buildVerticalDivider(),
                          _buildActionIcon(
                            Icons.delete_outline_rounded,
                            Colors.red,
                            () => _showDeleteDialog(context),
                          ),
                        ],
                      ),
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
        // Padding dikurangi agar tidak memakan terlalu banyak space
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, size: 18, color: onTap == null ? Colors.grey : color),
      ),
    );
  }
}

class UpdateTanamDialog extends StatefulWidget {
  final LandManagementItemModel item;
  final VoidCallback onSuccess;
  const UpdateTanamDialog({
    super.key,
    required this.item,
    required this.onSuccess,
  });

  @override
  State<UpdateTanamDialog> createState() => _UpdateTanamDialogState();
}

class _UpdateTanamDialogState extends State<UpdateTanamDialog> {
  late TextEditingController tglTanamController;
  late TextEditingController luasTanamController;
  late TextEditingController jenisBibitController;
  late TextEditingController kebutuhanBibitController;
  late TextEditingController estAwalController;
  late TextEditingController estAkhirController;
  late TextEditingController dokumenController;
  late TextEditingController keteranganController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tglTanamController = TextEditingController(text: widget.item.tglTanam);
    luasTanamController = TextEditingController(
      text: widget.item.luasTanamDetail.toString(),
    );
    jenisBibitController = TextEditingController(text: widget.item.jenisBibit);
    kebutuhanBibitController = TextEditingController(
      text: widget.item.kebutuhanBibit.toString(),
    );
    estAwalController = TextEditingController(text: widget.item.estAwalPanen);
    estAkhirController = TextEditingController(text: widget.item.estAkhirPanen);
    dokumenController = TextEditingController(
      text: widget.item.dokumenPendukung,
    );
    keteranganController = TextEditingController(
      text: widget.item.keteranganTanam,
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => isLoading = true);
    final data = {
      "tgl_tanam": tglTanamController.text,
      "luas_tanam": double.tryParse(luasTanamController.text) ?? 0.0,
      "jenis_bibit": jenisBibitController.text,
      "kebutuhan_bibit": double.tryParse(kebutuhanBibitController.text) ?? 0.0,
      "est_awal_panen": estAwalController.text,
      "est_akhir_panen": estAkhirController.text,
      "dokumen_pendukung": dokumenController.text,
      "keterangan": keteranganController.text,
    };

    final success = await LandManagementRepository().updateTanam(
      widget.item.id,
      data,
    );
    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context);
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFB8C00),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_calendar, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  "UPDATE DATA TANAM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInputField(
                    "Tanggal Tanam (YYYY-MM-DD)",
                    tglTanamController,
                    Icons.calendar_today,
                  ),
                  _buildInputField(
                    "Luas Tanam (Ha)",
                    luasTanamController,
                    Icons.square_foot,
                    isNumber: true,
                  ),
                  _buildInputField(
                    "Jenis Bibit",
                    jenisBibitController,
                    Icons.grass,
                  ),
                  _buildInputField(
                    "Kebutuhan Bibit (Kg)",
                    kebutuhanBibitController,
                    Icons.scale,
                    isNumber: true,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          "Est. Panen Awal",
                          estAwalController,
                          Icons.date_range,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInputField(
                          "Est. Panen Akhir",
                          estAkhirController,
                          Icons.event_available,
                        ),
                      ),
                    ],
                  ),
                  _buildInputField(
                    "Dokumen Pendukung",
                    dokumenController,
                    Icons.file_present,
                  ),
                  _buildInputField(
                    "Keterangan Lain",
                    keteranganController,
                    Icons.note_alt,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "BATAL",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFB8C00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              "SIMPAN",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFFFB8C00)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFB8C00)),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }
}
