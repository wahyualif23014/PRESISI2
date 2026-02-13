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

  // --- CONTROLLERS BERDASARKAN FORM ---
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

  // --- DROPDOWN STATES ---
  String? _selectedResor;
  String? _selectedSektor;
  String? _selectedJenisLahan;
  String? _selectedKomoditi = "AKASIA";
  String? _selectedKab;
  String? _selectedKec;
  String? _selectedDesa;
  String _selectedStatus = "BELUM TERVALIDASI";

  bool _isLoading = false;

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
    _selectedJenisLahan = d.jenisLahan;
    _selectedKomoditi = d.komoditi;
    _selectedResor = d.resor;
    _selectedSektor = d.sektor;
    _selectedKab = d.kabupaten;
    _selectedKec = d.kecamatan;
    _selectedDesa = d.desa;
    _selectedStatus = d.statusValidasi;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = LandPotentialModel(
      id: widget.editData?.id ?? "0",
      kabupaten: _selectedKab ?? "-",
      kecamatan: _selectedKec ?? "-",
      desa: _selectedDesa ?? "-",
      resor: _selectedResor ?? "-",
      sektor: _selectedSektor ?? "-",
      jenisLahan: _selectedJenisLahan ?? "-",
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
      komoditi: _selectedKomoditi ?? "AKASIA",
      keteranganLain: _ketLainController.text,
      fotoLahan: "",
      tglProses: DateTime.now().toString(),
      diprosesOleh: "Admin",
      divalidasiOleh: "-",
      tglValidasi: "-",
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
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Text(
          widget.editData != null
              ? "EDIT FORM DATA LAHAN"
              : "FORM TAMBAH DATA LAHAN",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF0097B2),
        foregroundColor: Colors.white,
        centerTitle: true,
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
                      // SECTION 1: UNIT KERJA
                      _buildSectionCard("UNIT KERJA", [
                        _buildDropdown(
                          "KEPOLISIAN RESOR",
                          [
                            "PILIH KEPOLISIAN RESOR",
                            "POLRES BANYUWANGI",
                            "POLRES JEMBER",
                          ],
                          (v) => setState(() => _selectedResor = v),
                          _selectedResor,
                        ),
                        _buildDropdown(
                          "KEPOLISIAN SEKTOR",
                          [
                            "PILIH KEPOLISIAN SEKTOR",
                            "POLSEK KABAT",
                            "POLSEK ROGOJAMPI",
                          ],
                          (v) => setState(() => _selectedSektor = v),
                          _selectedSektor,
                        ),
                      ]),

                      // SECTION 2: JENIS LAHAN
                      _buildSectionCard("JENIS LAHAN", [
                        _buildDropdown(
                          "PILIH JENIS LAHAN",
                          ["SAWAH", "LADANG", "PERKEBUNAN"],
                          (v) => setState(() => _selectedJenisLahan = v),
                          _selectedJenisLahan,
                        ),
                      ]),

                      // SECTION 3: PERSONEL & PJ
                      _buildSectionCard("PERSONEL & PENANGGUNG JAWAB", [
                        _buildFieldRow(
                          "POLISI PENGGERAK",
                          _policeNameController,
                          "KONTAK",
                          _policePhoneController,
                          isPhone: true,
                        ),
                        const SizedBox(height: 12),
                        _buildFieldRow(
                          "PENANGGUNG JAWAB",
                          _picNameController,
                          "KONTAK",
                          _picPhoneController,
                          isPhone: true,
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          "KETERANGAN PENANGGUNG JAWAB",
                          _picKeteranganController,
                          Icons.edit_note,
                        ),
                      ]),

                      // SECTION 4: DATA LAHAN
                      _buildSectionCard("DATA LAHAN", [
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                "JML. POKTAN",
                                _jmlPoktanController,
                                Icons.groups,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildField(
                                "LUAS LAHAN (HA)",
                                _luasLahanController,
                                Icons.area_chart,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildField(
                                "JML. PETANI",
                                _jmlPetaniController,
                                Icons.person,
                                isNumber: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown(
                          "KOMODITI",
                          ["AKASIA", "JATI", "JAGUNG", "PADI"],
                          (v) => setState(() => _selectedKomoditi = v),
                          _selectedKomoditi,
                        ),
                      ]),

                      // SECTION 5: ALAMAT & MAPS
                      _buildSectionCard("ALAMAT LAHAN", [
                        _buildField(
                          "MASUKKAN ALAMAT LAHAN",
                          _alamatController,
                          Icons.location_on,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                "KABUPATEN/KOTA",
                                ["BANYUWANGI", "JEMBER"],
                                (v) => setState(() => _selectedKab = v),
                                _selectedKab,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdown(
                                "KECAMATAN",
                                ["KEC. KABAT", "KEC. ROGOJAMPI"],
                                (v) => setState(() => _selectedKec = v),
                                _selectedKec,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdown(
                                "DESA",
                                ["DESA A", "DESA B"],
                                (v) => setState(() => _selectedDesa = v),
                                _selectedDesa,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildFieldRow(
                          "LATITUDE",
                          _latitudeController,
                          "LONGITUDE",
                          _longitudeController,
                          isNumber: true,
                        ),
                      ]),

                      // SECTION 6: KETERANGAN LAIN
                      _buildSectionCard("KETERANGAN LAIN", [
                        _buildField(
                          "MASUKKAN KETERANGAN LAINNYA",
                          _ketLainController,
                          Icons.description,
                          maxLines: 2,
                        ),
                      ]),

                      _buildFooterButtons(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1,
            ),
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF0097B2)),
        filled: true,
        fillColor: const Color(0xFFF9FBFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFieldRow(
    String label1,
    TextEditingController ctrl1,
    String label2,
    TextEditingController ctrl2, {
    bool isNumber = false,
    bool isPhone = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildField(label1, ctrl1, Icons.edit, isNumber: isNumber),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: _buildField(
            label2,
            ctrl2,
            Icons.contact_phone,
            isNumber: isNumber || isPhone,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : null,
        style: const TextStyle(fontSize: 11, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10),
          filled: true,
          fillColor: const Color(0xFFF9FBFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        items:
            items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 16, color: Colors.white),
            label: const Text(
              "BATAL",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.check, size: 16),
            label: const Text("SIMPAN", style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF546E7A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
