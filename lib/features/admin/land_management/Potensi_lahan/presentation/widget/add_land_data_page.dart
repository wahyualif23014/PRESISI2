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
  final _picKeteranganController = TextEditingController();
  final _jmlPoktanController = TextEditingController(text: "0");
  final _luasLahanController = TextEditingController(text: "0.00");
  final _jmlPetaniController = TextEditingController(text: "0");
  final _alamatController = TextEditingController();
  final _latitudeController = TextEditingController(text: "0");
  final _longitudeController = TextEditingController(text: "0");
  final _ketLainController = TextEditingController();

  String? _selectedResor;
  String? _selectedSektor;
  String? _selectedJenisLahan;
  String? _selectedKomoditi;
  String? _selectedKab;
  String? _selectedKec;
  String? _selectedDesa;
  String _selectedStatus = "BELUM TERVALIDASI";

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
    if (widget.editData != null) _loadInitialData();
  }

  void _loadInitialData() {
    final d = widget.editData!;
    _policeNameController.text = d.policeName;
    _policePhoneController.text = d.policePhone;
    _picNameController.text = d.picName;
    _picPhoneController.text = d.picPhone;
    _picKeteranganController.text = d.keterangan;
    _jmlPoktanController.text = d.jumlahPoktan.toString();
    _luasLahanController.text = d.luasLahan.toString();
    _jmlPetaniController.text = d.jumlahPetani.toString();
    _alamatController.text = d.alamatLahan;
    _ketLainController.text = d.keteranganLain;
    _selectedJenisLahan = d.jenisLahan;
    _selectedKomoditi = d.komoditi;
    _selectedResor = d.resor.replaceAll("POLRES ", "");
    _selectedSektor = d.sektor.replaceAll("POLSEK ", "");
    _selectedKab = d.kabupaten;
    _selectedKec = d.kecamatan;
    _selectedDesa = d.desa;
    _selectedStatus = d.statusValidasi;
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
      idWilayah: "3510010",
      kabupaten: _selectedKab ?? "-",
      kecamatan: _selectedKec ?? "-",
      desa: _selectedDesa ?? "-",
      resor: "POLRES ${_selectedResor ?? '-'}",
      sektor: "POLSEK ${_selectedSektor ?? '-'}",
      idJenisLahan: _getIdJenisLahan(_selectedJenisLahan),
      jenisLahan: _selectedJenisLahan ?? "LAHAN LAINNYA",
      luasLahan: double.tryParse(_luasLahanController.text) ?? 0.0,
      alamatLahan: _alamatController.text,
      statusValidasi: _selectedStatus,
      policeName: _policeNameController.text,
      policePhone: _policePhoneController.text,
      picName: _picNameController.text,
      picPhone: _picPhoneController.text,
      keterangan: _picKeteranganController.text,
      jumlahPoktan: int.tryParse(_jmlPoktanController.text) ?? 0,
      jumlahPetani: int.tryParse(_jmlPetaniController.text) ?? 0,
      idKomoditi: 1,
      komoditi: _selectedKomoditi ?? "TANAMAN PANGAN-JAGUNG",
      keteranganLain: _ketLainController.text,
      fotoLahan: widget.editData?.fotoLahan ?? "",
      infoProses: widget.editData?.infoProses ?? "Admin (${DateTime.now()})",
      infoValidasi: widget.editData?.infoValidasi ?? "-",
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
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Kepolisian Resor"),
                      _buildDropdown(
                        "Pilih Kepolisian Resor",
                        ["BANYUWANGI", "JEMBER"],
                        (v) => setState(() => _selectedResor = v),
                        _selectedResor,
                      ),

                      _buildLabel("Kepolisian Sektor"),
                      _buildDropdown(
                        "Pilih Kepolisian Sektor",
                        ["KABAT", "ROGOJAMPI"],
                        (v) => setState(() => _selectedSektor = v),
                        _selectedSektor,
                      ),

                      _buildLabel("Jenis Lahan"),
                      _buildDropdown(
                        "Pilih Jenis Lahan",
                        _kategoriLahan,
                        (v) => setState(() => _selectedJenisLahan = v),
                        _selectedJenisLahan,
                      ),

                      const Divider(height: 40),

                      _buildLabel("Polisi Penggerak"),
                      _buildTextField(
                        _policeNameController,
                        "Masukkan Nama Anggota",
                      ),
                      _buildLabel("Kontak Polisi"),
                      _buildTextField(
                        _policePhoneController,
                        "Masukkan No. Handphone",
                        isPhone: true,
                      ),

                      _buildLabel("Penanggung Jawab"),
                      _buildTextField(
                        _picNameController,
                        "Masukkan Nama Penanggung Jawab",
                      ),
                      _buildLabel("Kontak Penanggung Jawab"),
                      _buildTextField(
                        _picPhoneController,
                        "Masukkan No. Handphone",
                        isPhone: true,
                      ),

                      _buildLabel("Keterangan Penanggung Jawab"),
                      _buildTextField(
                        _picKeteranganController,
                        "Masukkan Keterangan Penanggung Jawab",
                        maxLines: 2,
                      ),

                      const Divider(height: 40),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Jml. Poktan"),
                                _buildTextField(
                                  _jmlPoktanController,
                                  "0",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Luas Lahan (HA)"),
                                _buildTextField(
                                  _luasLahanController,
                                  "0.00",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Jml. Petani"),
                                _buildTextField(
                                  _jmlPetaniController,
                                  "0",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      _buildLabel("Komoditi"),
                      _buildDropdown(
                        "Pilih Komoditi",
                        ["AKASIA", "JAGUNG", "PADI", "TEBU"],
                        (v) => setState(() => _selectedKomoditi = v),
                        _selectedKomoditi,
                      ),

                      const Divider(height: 40),

                      _buildLabel("Alamat Lahan"),
                      _buildTextField(
                        _alamatController,
                        "Masukkan Alamat Lahan",
                        maxLines: 3,
                      ),

                      _buildLabel("Kabupaten/Kota"),
                      _buildDropdown(
                        "Pilih Kabupaten/Kota",
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

                      _buildLabel("Kelurahan/Desa"),
                      _buildDropdown(
                        "Pilih Kelurahan/Desa",
                        ["DESA A", "DESA B"],
                        (v) => setState(() => _selectedDesa = v),
                        _selectedDesa,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Latitude"),
                                _buildTextField(
                                  _latitudeController,
                                  "0",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Longitude"),
                                _buildTextField(
                                  _longitudeController,
                                  "0",
                                  isNumber: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildMapPlaceholder(),

                      const SizedBox(height: 20),
                      _buildLabel("Foto Lahan"),
                      _buildPhotoPlaceholder(),

                      _buildLabel("Keterangan Lain"),
                      _buildTextField(
                        _ketLainController,
                        "Masukkan Keterangan Lainnya",
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          isNumber || isPhone ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
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
      hint: Text(hint, style: const TextStyle(fontSize: 13)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
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
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: const Center(child: Icon(Icons.map, size: 50, color: Colors.blue)),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 50,
            color: Colors.grey,
          ),
          SizedBox(height: 8),
          Text("Belum Ada Foto", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "BATAL",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "SIMPAN DATA",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
