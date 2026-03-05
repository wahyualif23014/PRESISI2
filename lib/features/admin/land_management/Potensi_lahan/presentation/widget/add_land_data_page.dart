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
  final _keteranganController = TextEditingController();
  final _ketLainController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String? _selectedKab;
  String? _selectedKec;
  String? _selectedDesa;
  String? _selectedJenisLahan;
  String? _selectedKomoditi;

  bool _isLoading = false;

  final List<String> _kategoriLahan = [
    "LAHAN MILIK POLRI",
    "LAHAN PRODUKTIF (POKTAN BINAAN POLRI)",
    "LAHAN PRODUKTIF (MASYARAKAT BINAAN POLRI)",
    "LAHAN PRODUKTIF (TUMPANG SARI)",
    "LAHAN HUTAN (PERHUTANAN SOSIAL)",
    "LAHAN HUTAN (PERHUTANI/INHUTANI)",
    "LAHAN PESANTREN",
    "LAHAN LUAS BAKU SAWAH (LBS)",
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
      _selectedKomoditi = d.komoditi.split("-").last.trim();
      _selectedKab = d.kabupaten;
      _selectedKec = d.kecamatan;
      _selectedDesa = d.desa;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = LandPotentialModel(
      id: widget.editData?.id ?? "0",
      idWilayah: "3510000000",
      kabupaten: _selectedKab ?? "-",
      kecamatan: _selectedKec ?? "-",
      desa: _selectedDesa ?? "-",
      idJenisLahan: 9,
      jenisLahan: _selectedJenisLahan ?? "LAHAN LAINNYA",
      luasLahan: double.tryParse(_luasLahanController.text) ?? 0.0,
      alamatLahan: _alamatController.text,
      statusValidasi: widget.editData?.statusValidasi ?? "1",
      policeName: _policeNameController.text,
      policePhone: _policePhoneController.text,
      picName: _picNameController.text,
      picPhone: _picPhoneController.text,
      keterangan: _keteranganController.text,
      keteranganLain: _ketLainController.text,
      jumlahPoktan: int.tryParse(_jmlPoktanController.text) ?? 0,
      jumlahPetani: int.tryParse(_jmlPetaniController.text) ?? 0,
      idKomoditi: 1,
      komoditi: "TANAMAN PANGAN - ${_selectedKomoditi ?? 'Jagung'}",
      fotoLahan: "",
      latitude: _latController.text,
      longitude: _lngController.text,
      infoProses: "-",
      infoValidasi: "-",
      namaPemroses: "",
      tglEdit: "",
      namaValidator: "",
      tglValid: "",
      namaPoktan: "-",
    );

    bool success =
        widget.editData != null
            ? await _service.updateLandData(widget.editData!.id, payload)
            : await _service.postLandData(payload);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data Berhasil Disimpan ke Database"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          widget.editData != null ? "EDIT DATA LAHAN" : "TAMBAH DATA LAHAN",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildCard(
                        title: "LOKASI & KOORDINAT",
                        icon: Icons.location_on,
                        child: Column(
                          children: [
                            _buildTextField(
                              _latController,
                              "Latitude",
                              Icons.explore,
                            ),
                            _buildTextField(
                              _lngController,
                              "Longitude",
                              Icons.explore,
                            ),
                            _buildTextField(
                              _alamatController,
                              "Alamat Lengkap Lahan",
                              Icons.map,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      _cardWrapper(
                        title: "PERSONEL TERKAIT",
                        icon: Icons.people,
                        child: Column(
                          children: [
                            _buildTextField(
                              _policeNameController,
                              "Nama Polisi Penggerak",
                              Icons.person,
                            ),
                            _buildTextField(
                              _picNameController,
                              "Nama Penanggung Jawab",
                              Icons.person_outline,
                            ),
                          ],
                        ),
                      ),
                      _buildCard(
                        title: "DETAIL POTENSI LAHAN",
                        icon: Icons.grass,
                        child: Column(
                          children: [
                            _buildDropdown(
                              "Jenis Lahan",
                              _kategoriLahan,
                              (v) => setState(() => _selectedJenisLahan = v),
                              _selectedJenisLahan,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    _luasLahanController,
                                    "Luas (Ha)",
                                    null,
                                    isNumber: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    _jmlPetaniController,
                                    "Jml Petani",
                                    null,
                                    isNumber: true,
                                  ),
                                ),
                              ],
                            ),
                            _buildTextField(
                              _keteranganController,
                              "Keterangan Lahan",
                              Icons.notes,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _handleSave,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            "SIMPAN DATA KE DATABASE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _cardWrapper({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return _buildCard(title: title, icon: icon, child: child);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData? icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator:
            (v) => v == null || v.isEmpty ? "Bidang ini wajib diisi" : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: items.contains(value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        items:
            items.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Wajib dipilih" : null,
      ),
    );
  }
}
