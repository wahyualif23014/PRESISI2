import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _policeNameController = TextEditingController();
  final _policePhoneController = TextEditingController();
  final _picNameController = TextEditingController();
  final _picPhoneController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _jmlPoktanController = TextEditingController(text: "0");
  final _luasLahanController = TextEditingController(text: "0.0");
  final _jmlPetaniController = TextEditingController(text: "0");
  final _alamatController = TextEditingController();
  final _latController = TextEditingController(text: "0");
  final _lngController = TextEditingController(text: "0");
  final _ketLainController = TextEditingController();

  // State Variabel Wilayah (Sekarang menggunakan List of Map)
  List<Map<String, dynamic>> _listKab = [];
  List<Map<String, dynamic>> _listKec = [];
  List<Map<String, dynamic>> _listDesa = [];
  List<Map<String, dynamic>> _listKomoditi = [];

  String? _selectedKabKode;
  String? _selectedKecKode;
  String? _selectedDesaKode;
  String? _selectedJenisLahan;
  int? _selectedKomoditiId;
  String? _fotoPath;

  bool _isLoading = false;
  String _currentUserId = "0";

  final List<String> _kategoriLahan = [
    "PRODUKTIF (POKTAN BINAAN POLRI)",
    "HUTAN (PERHUTANAN SOSIAL)",
    "LUAS BAKU SAWAH (LBS)",
    "PESANTREN",
    "MILIK POLRI",
    "PRODUKTIF (MASYARAKAT BINAAN POLRI)",
    "PRODUKTIF (TUMPANG SARI)",
    "HUTAN (PERHUTANI/INHUTANI)",
    "LAHAN LAINNYA",
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialConfig();
  }

  Future<void> _loadInitialConfig() async {
    setState(() => _isLoading = true);
    _currentUserId = await _storage.read(key: 'user_id') ?? "0";

    // Load Polres & Komoditi pertama kali
    _listKab = await _service.fetchDynamicWilayah();
    _listKomoditi = await _service.fetchKomoditiOptions();

    if (widget.editData != null) {
      await _fillEditData();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _fillEditData() async {
    final d = widget.editData!;
    _policeNameController.text = d.policeName;
    _policePhoneController.text = d.policePhone;
    _picNameController.text = d.picName;
    _picPhoneController.text = d.picPhone;
    _keteranganController.text = d.keterangan;
    _jmlPoktanController.text = d.jumlahPoktan.toString();
    _luasLahanController.text = d.luasLahan.toString();
    _jmlPetaniController.text = d.jumlahPetani.toString();
    _alamatController.text = d.alamatLahan;
    _latController.text = d.latitude;
    _lngController.text = d.longitude;
    _ketLainController.text = d.keteranganLain;

    _selectedJenisLahan = d.jenisLahan;
    _selectedKomoditiId = d.idKomoditi;
    _fotoPath = d.fotoLahan;

    // Logika pengisian wilayah saat edit
    // Note: Edit data harusnya mengirim Kode Wilayah, namun jika hanya nama,
    // pastikan backend GetFilterOptions mengembalikan data yang cocok.
    try {
      // 1. Set Kabupaten
      _selectedKabKode = d.idWilayah.substring(0, 5);
      // 2. Load Kecamatan
      final kabName = d.kabupaten;
      _listKec = await _service.fetchDynamicWilayah(polres: kabName);
      _selectedKecKode = d.idWilayah.substring(0, 8);
      // 3. Load Desa
      final kecName = d.kecamatan;
      _listDesa = await _service.fetchDynamicWilayah(
        polres: kabName,
        polsek: kecName,
      );
      _selectedDesaKode = d.idWilayah;
    } catch (e) {
      debugPrint("Error fill edit wilayah: $e");
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    int idJenis =
        _kategoriLahan.indexOf(_selectedJenisLahan ?? "LAHAN LAINNYA") + 1;

    final payload = LandPotentialModel(
      id: widget.editData?.id ?? "0",
      idWilayah: _selectedDesaKode ?? "0", // PENTING: Mengirim Kode Desa
      kabupaten: _selectedKabKode ?? "-",
      kecamatan: _selectedKecKode ?? "-",
      desa: _selectedDesaKode ?? "-",
      idJenisLahan: idJenis,
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
      idKomoditi: _selectedKomoditiId ?? 1,
      komoditi: "DIAMBIL DARI ID",
      fotoLahan: _fotoPath ?? "",
      latitude: _latController.text,
      longitude: _lngController.text,
      editoleh: _currentUserId,
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
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          "Form Data Lahan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Wilayah Administrasi"),
                      _buildDropdownWilayah(
                        "Pilih Kepolisian Resor (Kab/Kota)",
                        _listKab,
                        (v) async {
                          if (v == null) return;
                          setState(() {
                            _selectedKabKode = v;
                            _selectedKecKode = null;
                            _selectedDesaKode = null;
                            _listKec = [];
                            _listDesa = [];
                          });
                          final name =
                              _listKab.firstWhere(
                                (e) => e['kode'] == v,
                              )['nama'];
                          final list = await _service.fetchDynamicWilayah(
                            polres: name,
                          );
                          setState(() => _listKec = list);
                        },
                        _selectedKabKode,
                      ),

                      _buildDropdownWilayah(
                        "Pilih Kepolisian Sektor (Kecamatan)",
                        _listKec,
                        (v) async {
                          if (v == null) return;
                          setState(() {
                            _selectedKecKode = v;
                            _selectedDesaKode = null;
                            _listDesa = [];
                          });
                          final polresName =
                              _listKab.firstWhere(
                                (e) => e['kode'] == _selectedKabKode,
                              )['nama'];
                          final polsekName =
                              _listKec.firstWhere(
                                (e) => e['kode'] == v,
                              )['nama'];
                          final list = await _service.fetchDynamicWilayah(
                            polres: polresName,
                            polsek: polsekName,
                          );
                          setState(() => _listDesa = list);
                        },
                        _selectedKecKode,
                      ),

                      _buildDropdownWilayah(
                        "Pilih Kelurahan / Desa",
                        _listDesa,
                        (v) {
                          setState(() => _selectedDesaKode = v);
                        },
                        _selectedDesaKode,
                      ),

                      const SizedBox(height: 12),
                      _buildSectionTitle("Kategori Lahan"),
                      _buildDropdownSimple(
                        "Pilih Jenis Lahan",
                        _kategoriLahan,
                        (v) {
                          setState(() => _selectedJenisLahan = v);
                        },
                        _selectedJenisLahan,
                      ),

                      const SizedBox(height: 12),
                      _buildSectionTitle("Personel Pengelola"),
                      _buildTextField(
                        _policeNameController,
                        "Polisi Penggerak (Bhabinkamtibmas)",
                        Icons.person,
                      ),
                      _buildTextField(
                        _policePhoneController,
                        "Kontak Polisi",
                        Icons.phone,
                        isNumber: true,
                        prefixText: "+62 ",
                      ),
                      _buildTextField(
                        _picNameController,
                        "Penanggung Jawab Lahan (PIC)",
                        Icons.person_outline,
                      ),
                      _buildTextField(
                        _picPhoneController,
                        "Kontak PIC",
                        Icons.phone_android,
                        isNumber: true,
                        prefixText: "+62 ",
                      ),
                      _buildTextField(
                        _keteranganController,
                        "Keterangan Strategis (CP)",
                        Icons.notes,
                        maxLines: 2,
                      ),

                      const SizedBox(height: 12),
                      _buildSectionTitle("Informasi Teknis Lahan"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _jmlPoktanController,
                              "Jml. Poktan",
                              Icons.group_work,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              _luasLahanController,
                              "Luas (Ha)",
                              Icons.square_foot,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        _jmlPetaniController,
                        "Estimasi Jml. Petani",
                        Icons.groups,
                        isNumber: true,
                      ),
                      _buildDropdownKomoditi(
                        "Jenis Komoditi",
                        _listKomoditi,
                        (v) => setState(() => _selectedKomoditiId = v),
                        _selectedKomoditiId,
                      ),
                      _buildTextField(
                        _alamatController,
                        "Detail Alamat Lahan",
                        Icons.location_on,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 12),
                      _buildSectionTitle("Koordinat Lokasi"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _latController,
                              "Latitude",
                              Icons.explore,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              _lngController,
                              "Longitude",
                              Icons.explore,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      _buildLeafletMapMockup(),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Dokumentasi Foto"),
                      _buildPhotoUploadSection(),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Catatan Tambahan"),
                      _buildTextField(
                        _ketLainController,
                        "Keterangan Lainnya",
                        Icons.more_horiz,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "SIMPAN DATA LOKASI",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
          prefixText: prefixText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator:
            (v) => v == null || v.isEmpty ? "Bidang ini wajib diisi" : null,
      ),
    );
  }

  // Dropdown Khusus Wilayah (Map: Nama & Kode)
  Widget _buildDropdownWilayah(
    String label,
    List<Map<String, dynamic>> items,
    Function(String?) onChanged,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: items.any((e) => e['kode'] == value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items:
            items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e['kode'].toString(),
                    child: Text(
                      e['nama'].toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Wajib dipilih" : null,
      ),
    );
  }

  // Dropdown Sederhana (List String)
  Widget _buildDropdownSimple(
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
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items:
            items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Wajib dipilih" : null,
      ),
    );
  }

  Widget _buildDropdownKomoditi(
    String label,
    List<Map<String, dynamic>> items,
    Function(int?) onChanged,
    int? value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: items.any((e) => e['id'] == value) ? value : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items:
            items
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e['id'] as int,
                    child: Text(
                      e['nama'].toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Wajib dipilih" : null,
      ),
    );
  }

  Widget _buildLeafletMapMockup() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: NetworkImage(
            "https://a.tile.openstreetmap.org/13/4193/2767.png",
          ),
          fit: BoxFit.cover,
          opacity: 0.7,
        ),
      ),
      child: const Center(
        child: Icon(Icons.location_on, size: 40, color: Colors.red),
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
          style: BorderStyle.solid,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Klik untuk mengunggah foto lahan",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
