import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/model/land_potential_model.dart';
import '../../data/service/land_potential_service.dart';

class LandDetailDialog extends StatefulWidget {
  final LandPotentialModel data;

  const LandDetailDialog({super.key, required this.data});

  @override
  State<LandDetailDialog> createState() => _LandDetailDialogState();
}

class _LandDetailDialogState extends State<LandDetailDialog> {
  final LandPotentialService _service = LandPotentialService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool isValidated = false;
  bool _isProcessing = false;
  int currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _checkInitialValidation();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final storedId = await _storage.read(key: 'user_id');
    setState(() {
      currentUserId = int.tryParse(storedId ?? '') ?? 0;
    });
  }

  void _checkInitialValidation() {
    // Memeriksa status validasi berdasarkan nama validator dari model
    final v = widget.data.namaValidator.trim();
    setState(() {
      isValidated = v != "" && v != "null" && v != "-" && v != "0";
    });
  }

  Future<void> _openMaps() async {
    String googleMapsUrl = "";

    if (widget.data.latitude != "0" && widget.data.longitude != "0") {
      googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${widget.data.latitude},${widget.data.longitude}";
    } else {
      final query = Uri.encodeComponent(widget.data.alamatLahan);
      googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$query";
    }

    final Uri url = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak bisa membuka link peta';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal membuka peta: $e")));
    }
  }

  Future<void> _handleValidation() async {
    // Validasi ID Lahan sebelum dikirim ke service
    int landId = int.tryParse(widget.data.id.toString()) ?? 0;

    if (landId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ID lahan tidak valid")));
      return;
    }

    if (isValidated) {
      _showUnvalidateConfirmation();
      return;
    }

    setState(() => _isProcessing = true);

    // Memanggil service toggleValidation yang sudah disesuaikan dengan backend Go
    bool success = await _service.toggleValidation(landId);

    if (!mounted) return;

    if (success) {
      setState(() {
        isValidated = true;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil divalidasi"),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman utama dengan nilai true untuk trigger refresh list
      Navigator.pop(context, true);
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gagal memproses validasi, cek koneksi atau sesi login",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUnvalidateConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Data ini sudah divalidasi. Batalkan validasi?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                setState(() => _isProcessing = true);

                int landId = int.tryParse(widget.data.id.toString()) ?? 0;
                bool success = await _service.toggleValidation(landId);

                if (!mounted) return;

                if (success) {
                  setState(() {
                    isValidated = false;
                    _isProcessing = false;
                  });

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text("Status validasi dibatalkan"),
                      backgroundColor: Colors.orange,
                    ),
                  );

                  Navigator.pop(this.context, true);
                } else {
                  setState(() => _isProcessing = false);
                }
              },
              child: const Text(
                "YA, BATALKAN",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  "Detail Informasi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSection(
                    Icons.account_balance_rounded,
                    "Wilayah",
                    Colors.blue,
                    [
                      _row(
                        "Kepolisian Resor",
                        "POLRES ${widget.data.kabupaten}",
                      ),
                      _row(
                        "Kepolisian Sektor",
                        "POLSEK ${widget.data.kecamatan}",
                      ),
                      _row(
                        "Wilayah Lahan",
                        "Desa ${widget.data.desa} Kecamatan ${widget.data.kecamatan} Kabupaten ${widget.data.kabupaten}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    Icons.people_alt_rounded,
                    "Personel",
                    Colors.teal,
                    [
                      _row(
                        "Polisi Penggerak",
                        "${widget.data.policeName} (${widget.data.policePhone})",
                      ),
                      _row(
                        "Penanggung Jawab",
                        "${widget.data.picName} (${widget.data.picPhone})",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    Icons.grass_rounded,
                    "Informasi Lahan",
                    Colors.green,
                    [
                      _row("Jenis Lahan", widget.data.jenisLahan),
                      _row("Keterangan", widget.data.keterangan),
                      _row(
                        "Jumlah Poktan",
                        widget.data.jumlahPoktan.toString(),
                      ),
                      _row(
                        "Luas Lahan",
                        "${widget.data.luasLahan.toStringAsFixed(2)} Ha",
                      ),
                      _row(
                        "Jumlah Petani",
                        widget.data.jumlahPetani.toString(),
                      ),
                      _row("Komoditi", widget.data.komoditi),
                      _row("Alamat Lahan", widget.data.alamatLahan),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _openMaps,
                          icon: const Icon(
                            Icons.map,
                            size: 18,
                            color: Color(0xFF0097B2),
                          ),
                          label: const Text(
                            "Lihat di Google Maps",
                            style: TextStyle(
                              color: Color(0xFF0097B2),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    Icons.camera_alt_rounded,
                    "Foto Lahan",
                    Colors.purple,
                    [
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImageFromData(widget.data.fotoLahan),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    Icons.history_toggle_off_rounded,
                    "Lainnya",
                    Colors.blueGrey,
                    [
                      _row("Keterangan Lain", widget.data.keteranganLain),
                      _row("Diproses Oleh", widget.data.infoProses),
                      _row(
                        "Divalidasi Oleh",
                        isValidated ? widget.data.infoValidasi : "-",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isProcessing
                                ? Colors.grey
                                : (isValidated ? Colors.orange : Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isProcessing ? null : _handleValidation,
                      child:
                          _isProcessing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                isValidated
                                    ? "BATALKAN VALIDASI"
                                    : "VALIDASI DATA SEKARANG",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFromData(String photoData) {
    if (photoData.isEmpty || photoData == "null" || photoData == "-") {
      return _emptyImage();
    }

    if (photoData.length < 500 ||
        photoData.toLowerCase().endsWith('.jpg') ||
        photoData.toLowerCase().endsWith('.png') ||
        photoData.toLowerCase().endsWith('.jpeg')) {
      String fullUrl =
          "http://192.168.100.195:8080/uploads/${Uri.encodeComponent(photoData)}";

      return Image.network(
        fullUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _emptyImage(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF0097B2)),
            ),
          );
        },
      );
    }

    try {
      String cleanBase64 =
          photoData.contains(',') ? photoData.split(',').last : photoData;
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'[^A-Za-z0-9+/]'), '');
      int mod = cleanBase64.length % 4;
      if (mod > 0) cleanBase64 += '=' * (4 - mod);
      Uint8List bytes = base64Decode(cleanBase64);

      return Image.memory(
        bytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _emptyImage(),
      );
    } catch (e) {
      return _emptyImage();
    }
  }

  Widget _emptyImage() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            "Belum ada foto dokumentasi",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    IconData icon,
    String title,
    Color color,
    List<Widget> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          ...items,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty || value == "null" ? "-" : value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
