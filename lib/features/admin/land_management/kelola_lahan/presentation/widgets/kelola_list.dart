import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/update_tanam_page.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/presentation/widgets/kelola_stages.dart';

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
                        _buildDetailSection("Data Panen", Icons.eco, [
                          _dataRow("Luas Panen", "${item.luasPanen} Ha"),
                          _dataRow("Total Panen", "${item.hasilPanen} Ton"),
                          _dataRow("Tanggal Panen", item.tglPanen.isEmpty ? "-" : item.tglPanen),
                          _dataRow("Catatan Panen", item.keteranganPanen.isEmpty ? "-" : item.keteranganPanen),
                          _dataRow(
                            "Dokumen Pendukung",
                            item.dokumenPanen.isEmpty
                                ? "Tidak ada file"
                                : item.dokumenPanen,
                            isLast: true,
                          ),
                        ]),
                        _buildDetailSection("Data Serapan (Distribusi)", Icons.local_shipping, [
                          _dataRow("Distribusi Ke", item.distribusiKe.isEmpty ? "-" : item.distribusiKe),
                          _dataRow("Total Distribusi", "${item.totalDistribusi} Ton"),
                          _dataRow("Tanggal Distribusi", item.tglDistribusi.isEmpty ? "-" : item.tglDistribusi),
                          _dataRow("Catatan Distribusi", item.keteranganDistribusi.isEmpty ? "-" : item.keteranganDistribusi),
                          _dataRow(
                            "Dokumen Pendukung",
                            item.dokumenDistribusi.isEmpty
                                ? "Tidak ada file"
                                : item.dokumenDistribusi,
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
      builder:
          (context) => UpdateTanamDialog(
            item: item,
            onSuccess: () {
              // INI PENTING: Panggil onRefresh() agar data ditarik ulang dari server
              onRefresh();
            },
          ),
    );
  }

  void _showPanenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UpdatePanenDialog(
        item: item,
        onSuccess: () {
          onRefresh();
        },
      ),
    );
  }

  void _showSerapanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UpdateSerapanDialog(
        item: item,
        onSuccess: () {
          onRefresh();
        },
      ),
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
    final bool isRejected = item.status.toUpperCase().contains('TOLAK') || item.status == '2';
    final auth = context.watch<AuthProvider>();
    final isPolsek = (auth.user?.tingkatDetail?.nama ?? '').toUpperCase().contains('POLSEK');
    final canEditOrDelete = !isPolsek || isRejected;

    // Badges color mapping
    Color badgeBg;
    Color badgeText;
    String statusLabel;
    if (isValidated) {
      badgeBg = const Color(0xFFE8F5E9);
      badgeText = const Color(0xFF2E7D32);
      statusLabel = "TERVALIDASI";
    } else if (isRejected) {
      badgeBg = const Color(0xFFFFEBEE);
      badgeText = const Color(0xFFC62828);
      statusLabel = "DITOLAK";
    } else {
      badgeBg = const Color(0xFFFFF3E0);
      badgeText = const Color(0xFFE65100);
      statusLabel = "BELUM TERVALIDASI";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: Lahan Name & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "LAHAN: ${item.alamatLahan.toUpperCase()}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A237E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: badgeText,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 10),
              
              // Body Grid: 2 Columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: Police & PIC info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("POLISI PENGGERAK"),
                        const SizedBox(height: 2),
                        _buildName(item.policeName.isNotEmpty ? item.policeName : "-"),
                        _buildPhone(item.policePhone),
                        const SizedBox(height: 8),
                        _buildLabel("PENANGGUNG JAWAB"),
                        const SizedBox(height: 2),
                        _buildName(item.picName.isNotEmpty ? item.picName : "-"),
                        _buildPhone(item.picPhone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column: Area, Wilayah, and Komoditi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("WILAYAH LAHAN"),
                        const SizedBox(height: 2),
                        Text(
                          item.wilayahLahan,
                          style: const TextStyle(fontSize: 10, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _buildLabel("LUAS & KOMODITAS"),
                        const SizedBox(height: 2),
                        Text(
                          "${item.landArea} Ha",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.komoditiName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Timeline Wizard
              _buildCardWorkflowTimeline(context),
              
              // Action Footer Row
              _buildActionFooter(context, canEditOrDelete, isValidated),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, size: 18, color: onTap == null ? Colors.grey : color),
      ),
    );
  }

  Widget _buildCardWorkflowTimeline(BuildContext context) {
    // 1. Lahan Status
    final bool isLahanOk = item.status == 'VALIDATED' || item.status == 'TERVALIDASI';

    // 2. Tanam Status
    final bool hasTanam = item.idTanam.isNotEmpty && item.idTanam != "0";
    final bool isTanamOk = hasTanam && item.statusTanam == '3';
    final bool isTanamPending = hasTanam && !isTanamOk;

    // 3. Panen Status
    final bool hasPanen = item.idPanen.isNotEmpty && item.idPanen != "0";
    final bool isPanenOk = hasPanen && item.statusPanen == '3';
    final bool isPanenPending = hasPanen && !isPanenOk;

    // 4. Distribusi/Serapan Status
    final bool hasSerapan = item.idSerapan.isNotEmpty && item.idSerapan != "0";
    final bool isSerapanOk = hasSerapan && item.statusSerapan == '3';
    final bool isSerapanPending = hasSerapan && !isSerapanOk;

    final auth = context.read<AuthProvider>();
    final role = auth.user?.role?.toString().toLowerCase() ?? '';
    final bool isAdminOrPolres = role.contains('admin') || (auth.user?.tingkatDetail?.nama ?? '').toUpperCase().contains('POLRES');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ALUR TAHAPAN LAHAN (WIZARD)",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                  letterSpacing: 0.5,
                ),
              ),
              if (isAdminOrPolres)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "AKSES VALIDATOR",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lahan Node
              _buildTimelineNode(
                "Lahan",
                isLahanOk ? _NodeState.ok : _NodeState.pending,
                onValidate: null,
              ),
              _buildTimelineConnector(isLahanOk),

              // Tanam Node
              _buildTimelineNode(
                "Tanam",
                isTanamOk
                    ? _NodeState.ok
                    : (isTanamPending ? _NodeState.pending : _NodeState.empty),
                onValidate: (isTanamPending && isAdminOrPolres)
                    ? () async {
                        final success = await LandManagementRepository().validateTanam(item.idTanam);
                        if (success) onRefresh();
                      }
                    : null,
              ),
              _buildTimelineConnector(isTanamOk),

              // Panen Node
              _buildTimelineNode(
                "Panen",
                isPanenOk
                    ? _NodeState.ok
                    : (isPanenPending ? _NodeState.pending : _NodeState.empty),
                onValidate: (isPanenPending && isAdminOrPolres)
                    ? () async {
                        final success = await LandManagementRepository().validatePanen(item.idPanen);
                        if (success) onRefresh();
                      }
                    : null,
              ),
              _buildTimelineConnector(isPanenOk),

              // Serapan Node
              _buildTimelineNode(
                "Serapan",
                isSerapanOk
                    ? _NodeState.ok
                    : (isSerapanPending ? _NodeState.pending : _NodeState.empty),
                onValidate: (isSerapanPending && isAdminOrPolres)
                    ? () async {
                        final success = await LandManagementRepository().validateSerapan(item.idSerapan);
                        if (success) onRefresh();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(String label, _NodeState state, {VoidCallback? onValidate}) {
    Color color;
    IconData icon;
    if (state == _NodeState.ok) {
      color = const Color(0xFF2E7D32);
      icon = Icons.check_circle;
    } else if (state == _NodeState.pending) {
      color = const Color(0xFFEF6C00);
      icon = Icons.pending;
    } else {
      color = Colors.grey.shade300;
      icon = Icons.radio_button_unchecked;
    }

    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: state == _NodeState.empty ? Colors.grey : color,
            ),
          ),
          if (onValidate != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 20,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color(0xFFEF6C00).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: onValidate,
                child: const Text(
                  "VALIDASI",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF6C00),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? const Color(0xFF2E7D32) : Colors.grey.shade300,
        margin: const EdgeInsets.only(top: 10),
      ),
    );
  }

  Widget _buildActionFooter(BuildContext context, bool canEditOrDelete, bool isValidated) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Primary workflow stage actions
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFooterButton(
                    icon: Icons.visibility_outlined,
                    label: "Detail",
                    color: Colors.blue.shade700,
                    onPressed: () => _showDetail(context),
                  ),
                  if (isValidated) ...[
                    if (item.idTanam.isEmpty || item.statusTanam != '3') ...[
                      const SizedBox(width: 8),
                      _buildFooterButton(
                        icon: Icons.grass,
                        label: "Tanam",
                        color: Colors.green.shade700,
                        onPressed: () => _showUpdateDialog(context),
                      ),
                    ],
                    if (item.statusTanam == '3' && (item.idPanen.isEmpty || item.statusPanen != '3')) ...[
                      const SizedBox(width: 8),
                      _buildFooterButton(
                        icon: Icons.agriculture,
                        label: "Panen",
                        color: Colors.orange.shade800,
                        onPressed: () => _showPanenDialog(context),
                      ),
                    ],
                    if (item.statusPanen == '3' && (item.idSerapan.isEmpty || item.statusSerapan != '3')) ...[
                      const SizedBox(width: 8),
                      _buildFooterButton(
                        icon: Icons.local_shipping,
                        label: "Serapan",
                        color: Colors.purple.shade700,
                        onPressed: () => _showSerapanDialog(context),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          
          // Right side: Edit, Delete (More options popup)
          if (canEditOrDelete)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              padding: EdgeInsets.zero,
              onSelected: (val) {
                if (val == 'edit') {
                  _showUpdateDialog(context);
                } else if (val == 'delete') {
                  _showDeleteDialog(context);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: Colors.orange),
                      SizedBox(width: 8),
                      Text("Ubah Data Lahan", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_outlined, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Hapus Lahan", style: TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        backgroundColor: color.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

enum _NodeState { ok, pending, empty }

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

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFB8C00),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        dokumenController.text = result.files.single.name;
      });
    }
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

    if (mounted) setState(() => isLoading = false);

    if (success && mounted) {
      Navigator.pop(context); // Tutup dialog

      // JEDA 500ms: Memastikan database MySQL sudah selesai melakukan LOCK/UPDATE
      // sebelum Flutter melakukan fetching ulang.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) widget.onSuccess();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
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
                    isDate: true,
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
                          isDate: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInputField(
                          "Est. Panen Akhir",
                          estAkhirController,
                          Icons.event_available,
                          isDate: true,
                        ),
                      ),
                    ],
                  ),
                  _buildInputField(
                    "Dokumen Pendukung",
                    dokumenController,
                    Icons.file_present,
                    isFile: true,
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
    bool isDate = false,
    bool isFile = false,
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
            readOnly: isDate || isFile,
            onTap:
                isDate
                    ? () => _selectDate(context, controller)
                    : (isFile ? _pickFile : null),
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFFFB8C00)),
              suffixIcon:
                  isFile
                      ? const Icon(
                        Icons.upload_file,
                        size: 18,
                        color: Color(0xFFFB8C00),
                      )
                      : (isDate
                          ? const Icon(
                            Icons.edit_calendar,
                            size: 18,
                            color: Color(0xFFFB8C00),
                          )
                          : null),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
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
