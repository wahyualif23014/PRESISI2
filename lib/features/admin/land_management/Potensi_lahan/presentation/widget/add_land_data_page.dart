import 'package:flutter/material.dart';
import '../../data/model/land_potential_model.dart';
import '../../data/service/land_potential_service.dart';

class AddLandDataPage extends StatefulWidget {
  final LandPotentialModel? editData;

  const AddLandDataPage({super.key, this.editData});

  @override
  State<AddLandDataPage> createState() => _AddLandDataPageState();
}

class _AddLandDataPageState extends State<AddLandDataPage> {
  final LandPotentialService _service = LandPotentialService();
  final _formKey = GlobalKey<FormState>();

  final _policeNameController = TextEditingController();
  final _policePhoneController = TextEditingController();
  final _picNameController = TextEditingController();
  final _picPhoneController = TextEditingController();
  final _jmlPoktanController = TextEditingController(text: "0");
  final _luasLahanController = TextEditingController(text: "0.0");
  final _jmlPetaniController = TextEditingController(text: "0");
  final _alamatController = TextEditingController();

  final _keteranganController = TextEditingController(); // Untuk ketcp
  final _ketLainController = TextEditingController();

  final _latController = TextEditingController(text: "0");
  final _lngController = TextEditingController(text: "0");

  String? _selectedResor;
  String? _selectedSektor;
  String? _selectedJenisLahan;
  String? _selectedKomoditi;
  String? _selectedKab;
  String? _selectedKec;
  String? _selectedDesa;

  String _currentStatus = "1";
  bool _isLoading = false;

  final List<String> _kategoriLahan = [
    "PERHUTANAN SOSIAL",
    "POKTAN BINAAN POLRI",
    "MASYARAKAT BINAAN POLRI",
    "TUMPANG SARI",
    "MILIK POLRI",
    "LBS",
    "PESANTREN",
    "LAHAN LAINNYA",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    final d = widget.editData!;
    setState(() {
      _policeNameController.text = d.policeName;
      _policePhoneController.text = d.policePhone;
      _picNameController.text = d.picName;
      _picPhoneController.text = d.picPhone;
      _jmlPoktanController.text = d.jumlahPoktan.toString();
      _luasLahanController.text = d.luasLahan.toString();
      _jmlPetaniController.text = d.jumlahPetani.toString();
      _alamatController.text = d.alamatLahan;
      _keteranganController.text = d.keterangan;
      _ketLainController.text = d.keteranganLain;
      _latController.text = d.latitude;
      _lngController.text = d.longitude;
      _selectedJenisLahan = d.jenisLahan;
      _selectedKomoditi =
          d.komoditi.contains("-")
              ? d.komoditi.split("-")[1].trim()
              : d.komoditi;
      _selectedKab = d.kabupaten;
      _selectedKec = d.kecamatan;
      _selectedDesa = d.desa;
      _currentStatus = d.statusValidasi == "TERVALIDASI" ? "2" : "1";
    });
  }

  int _getIdJenisLahan(String? title) {
    switch (title) {
      case "PERHUTANAN SOSIAL":
        return 1;
      case "POKTAN BINAAN POLRI":
        return 2;
      case "MASYARAKAT BINAAN POLRI":
        return 3;
      case "TUMPANG SARI":
        return 4;
      case "MILIK POLRI":
        return 5;
      case "LBS":
        return 6;
      case "PESANTREN":
        return 7;
      default:
        return 8;
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = LandPotentialModel(
      id: widget.editData?.id ?? "0",
      idWilayah: "3510010101",
      kabupaten: _selectedKab ?? "-",
      kecamatan: _selectedKec ?? "-",
      desa: _selectedDesa ?? "-",
      idJenisLahan: _getIdJenisLahan(_selectedJenisLahan),
      jenisLahan: _selectedJenisLahan ?? "LAHAN LAINNYA",
      luasLahan: double.tryParse(_luasLahanController.text) ?? 0.0,
      alamatLahan: _alamatController.text,
      statusValidasi: _currentStatus,
      policeName: _policeNameController.text,
      policePhone: _policePhoneController.text,
      picName: _picNameController.text,
      picPhone: _picPhoneController.text,
      keterangan: _keteranganController.text,
      keteranganLain: _ketLainController.text,

      jumlahPoktan: int.tryParse(_jmlPoktanController.text) ?? 0,
      jumlahPetani: int.tryParse(_jmlPetaniController.text) ?? 0,
      idKomoditi: 1,
      komoditi: "TANAMAN PANGAN - ${_selectedKomoditi ?? 'JAGUNG'}",
      fotoLahan: widget.editData?.fotoLahan ?? "",
      infoProses: widget.editData?.infoProses ?? "-",
      infoValidasi: widget.editData?.infoValidasi ?? "-",
      namaPemroses: widget.editData?.namaPemroses ?? "",
      tglEdit: widget.editData?.tglEdit ?? "",
      namaValidator: widget.editData?.namaValidator ?? "",
      tglValid: widget.editData?.tglValid ?? "",
      latitude: _latController.text,
      longitude: _lngController.text,
      namaPoktan: widget.editData?.namaPoktan ?? "-",
    );

    bool success =
        widget.editData != null
            ? await _service.updateLandData(widget.editData!.id, payload)
            : await _service.postLandData(payload);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data Berhasil Disimpan"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.editData != null ? "EDIT DATA LAHAN" : "TAMBAH DATA LAHAN",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Lokasi & Administrasi"),
                      _buildLabel("Kabupaten / Kota"),
                      _buildDropdown(
                        "Pilih Kabupaten",
                        ["BANYUWANGI", "JEMBER"],
                        (v) => setState(() => _selectedKab = v),
                        _selectedKab,
                      ),
                      _buildLabel("Kecamatan"),
                      _buildDropdown(
                        "Pilih Kecamatan",
                        ["KEC. KABAT", "KEC. ROGOJAMPI"],
                        (v) => setState(() => _selectedKec = v),
                        _selectedKec,
                      ),
                      _buildLabel("Kelurahan / Desa"),
                      _buildDropdown(
                        "Pilih Desa",
                        ["DESA A", "DESA B"],
                        (v) => setState(() => _selectedDesa = v),
                        _selectedDesa,
                      ),

                      const Divider(height: 40),
                      _buildSectionTitle("Detail Potensi Lahan"),
                      _buildLabel("Jenis Lahan"),
                      _buildDropdown(
                        "Pilih Jenis Lahan",
                        _kategoriLahan,
                        (v) => setState(() => _selectedJenisLahan = v),
                        _selectedJenisLahan,
                      ),

                      const SizedBox(height: 15),
                      _buildLabel("Alamat Lengkap Lahan"),
                      _buildTextField(
                        _alamatController,
                        "Jl. Raya...",
                        maxLines: 2,
                      ),

                      // Field Input untuk Keterangan (ketcp)
                      _buildLabel("Keterangan (Ketcp)"),
                      _buildTextField(
                        _keteranganController,
                        "Masukkan catatan ketcp...",
                        maxLines: 2,
                      ),

                      // Field Input untuk Keterangan Lain (keterangan)
                      _buildLabel("Keterangan Tambahan (Keterangan)"),
                      _buildTextField(
                        _ketLainController,
                        "Catatan lainnya...",
                        maxLines: 3,
                      ),

                      const SizedBox(height: 30),
                      _buildActionButtons(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0D47A1),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    Function(String?) onChanged,
    String? value,
  ) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      hint: Text(hint, style: const TextStyle(fontSize: 12)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items:
          items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Pilih salah satu" : null,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL"),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
            ),
            child: const Text(
              "SIMPAN DATA",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
