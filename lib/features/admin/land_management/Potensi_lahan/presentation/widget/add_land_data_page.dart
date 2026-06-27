

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:KETAHANANPANGAN/auth/provider/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:convert';
import 'package:KETAHANANPANGAN/core/config/api_config.dart';
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

  // Map Controller
  final MapController _mapController = MapController();

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
  final _latController = TextEditingController(text: "-7.2575");
  final _lngController = TextEditingController(text: "112.7521");
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
  String? _localImagePath;
  String? _fotoBase64;

  int _currentStep = 0;
  final int _totalSteps = 3;

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

    // Load Komoditi
    _listKomoditi = await _service.fetchKomoditiOptions();

    // Load Polres & scope berdasarkan role
    final allPolres = await _service.fetchDynamicWilayah();
    
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userKode = auth.user?.tingkatDetail?.kode ?? auth.user?.idTugas ?? '';
    final unitName = auth.user?.tingkatDetail?.nama ?? '';
    
    debugPrint('=== ADD LAND SCOPING ===');
    debugPrint('isOperator: ${auth.isOperator}, isAdmin: ${auth.isAdmin}');
    debugPrint('userKode: $userKode, unitName: $unitName');
    debugPrint('allPolres count: ${allPolres.length}');
    if (allPolres.isNotEmpty) debugPrint('allPolres sample: ${allPolres.first}');
    
    final bool isAdmin = auth.user?.role?.toString().contains('admin') ?? false;
    final unitNameUpper = unitName.toUpperCase();
    final bool isPolresUnit = !isAdmin && unitNameUpper.contains('POLRES');
    final bool isPolsekUnit = !isAdmin && unitNameUpper.contains('POLSEK');

    if (isPolsekUnit) {
      // Operator Polsek: Fetch Desa first to find the hierarchy
      debugPrint('Fetching desa for polsek: $unitName');
      final desasList = await _service.fetchDynamicWilayah(polsek: unitName);
      debugPrint('desasList count: ${desasList.length}');
      if (desasList.isNotEmpty) debugPrint('desasList sample: ${desasList.first}');
      
      if (desasList.isNotEmpty) {
        final firstDesaKode = desasList.first['kode'].toString();
        // Extract Polres and Polsek kodes based on BPS format (e.g., "35.78.01.2001")
        String polresKode = "";
        String polsekKode = "";
        
        if (firstDesaKode.length >= 5) {
          polresKode = firstDesaKode.substring(0, 5);
        }
        if (firstDesaKode.length >= 8) {
          polsekKode = firstDesaKode.substring(0, 8);
        }
        
        debugPrint('Extracted polresKode: $polresKode, polsekKode: $polsekKode');
        
        final polresMatch = allPolres.where((e) => e['kode'].toString() == polresKode).toList();
        debugPrint('polresMatch: $polresMatch');
        
        if (polresMatch.isNotEmpty) {
          _listKab = polresMatch;
          _selectedKabKode = polresKode;
          
          final polresName = polresMatch.first['nama'].toString();
          final allKec = await _service.fetchDynamicWilayah(polres: polresName);
          debugPrint('allKec count: ${allKec.length}');
          if (allKec.isNotEmpty) debugPrint('allKec sample: ${allKec.first}');
          
          final polsekMatch = allKec.where((e) => e['kode'].toString() == polsekKode || e['nama'].toString() == unitName).toList();
          debugPrint('polsekMatch: $polsekMatch');
          
          if (polsekMatch.isNotEmpty) {
            _listKec = polsekMatch;
            _selectedKecKode = polsekMatch.first['kode'].toString();
            _listDesa = desasList;
          } else {
            // Fallback if Polsek not found in allKec
            _listKec = [{'kode': polsekKode.isEmpty ? 'DUMMY' : polsekKode, 'nama': unitName}];
            _selectedKecKode = _listKec.first['kode'].toString();
            _listDesa = desasList;
          }
        } else {
           // Fallback if Polres not found
           _listKab = [{'kode': polresKode.isEmpty ? 'DUMMY' : polresKode, 'nama': 'Polres (Auto)'}];
           _selectedKabKode = _listKab.first['kode'].toString();
           _listKec = [{'kode': polsekKode.isEmpty ? 'DUMMY' : polsekKode, 'nama': unitName}];
           _selectedKecKode = _listKec.first['kode'].toString();
           _listDesa = desasList;
        }
      } else {
        // Fallback if Desa is empty
        debugPrint('WARNING: desasList empty! Check if unitName matches API polsek field.');
        _listKab = allPolres;
        _listKec = [{'kode': 'DUMMY', 'nama': unitName}];
        _selectedKecKode = 'DUMMY';
      }
    } else if (isPolresUnit) {
      // Admin/Operator Polres: auto-select Polres, bisa pilih Polsek
      final polresMatch = allPolres.where((e) {
        final kode = e['kode'].toString();
        final nama = e['nama'].toString();
        return (userKode.isNotEmpty && userKode.startsWith(kode)) || nama == unitName;
      }).toList();
      
      if (polresMatch.isNotEmpty) {
        _listKab = polresMatch;
        _selectedKabKode = polresMatch.first['kode'].toString();
        final polresName = polresMatch.first['nama'].toString();
        _listKec = await _service.fetchDynamicWilayah(polres: polresName);
      } else {
        _listKab = allPolres;
      }
    } else {
      // Polda / Viewer: full access
      _listKab = allPolres;
    }

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

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
        _mapController.move(LatLng(position.latitude, position.longitude), 14.0);
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          final file = File(path);
          final bytes = await file.readAsBytes();
          setState(() {
            _localImagePath = path;
            _fotoBase64 = base64Encode(bytes);
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking photo: $e");
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_selectedKabKode == null) {
        _showSnackbar("Harap pilih Polres / Kabupaten");
        return false;
      }
      if (_selectedKecKode == null) {
        _showSnackbar("Harap pilih Polsek / Kecamatan");
        return false;
      }
      if (_selectedDesaKode == null) {
        _showSnackbar("Harap pilih Kelurahan / Desa");
        return false;
      }
      if (_alamatController.text.trim().isEmpty) {
        _showSnackbar("Detail alamat lahan wajib diisi");
        return false;
      }
      if (_latController.text.trim().isEmpty || _lngController.text.trim().isEmpty) {
        _showSnackbar("Koordinat latitude & longitude wajib diisi");
        return false;
      }
      return true;
    } else if (_currentStep == 1) {
      if (_selectedJenisLahan == null) {
        _showSnackbar("Harap pilih jenis kategori lahan");
        return false;
      }
      if (_policeNameController.text.trim().isEmpty) {
        _showSnackbar("Nama polisi penggerak wajib diisi");
        return false;
      }
      if (_policePhoneController.text.trim().isEmpty) {
        _showSnackbar("Kontak polisi wajib diisi");
        return false;
      }
      if (_picNameController.text.trim().isEmpty) {
        _showSnackbar("Nama PIC lahan wajib diisi");
        return false;
      }
      if (_picPhoneController.text.trim().isEmpty) {
        _showSnackbar("Kontak PIC lahan wajib diisi");
        return false;
      }
      return true;
    } else {
      // Step 2 (0-indexed 3rd step)
      if (_jmlPoktanController.text.trim().isEmpty) {
        _showSnackbar("Jumlah Poktan wajib diisi");
        return false;
      }
      if (_luasLahanController.text.trim().isEmpty) {
        _showSnackbar("Luas lahan (Ha) wajib diisi");
        return false;
      }
      if (_jmlPetaniController.text.trim().isEmpty) {
        _showSnackbar("Estimasi jumlah petani wajib diisi");
        return false;
      }
      if (_selectedKomoditiId == null) {
        _showSnackbar("Harap pilih jenis komoditi");
        return false;
      }
      return true;
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleSave() async {
    if (!_validateCurrentStep()) return;
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
      fotoLahan: _fotoBase64 ?? _fotoPath ?? "",
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
    final auth = context.read<AuthProvider>();
    final unitName = auth.user?.tingkatDetail?.nama ?? '';
    final bool isAdmin = auth.user?.role?.toString().contains('admin') ?? false;
    final unitNameUpper = unitName.toUpperCase();
    final bool isLockedToPolres = !isAdmin && (unitNameUpper.contains('POLRES') || unitNameUpper.contains('POLSEK'));
    final bool isLockedToPolsek = !isAdmin && unitNameUpper.contains('POLSEK');
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(
          widget.editData != null ? "Ubah Data Lahan" : "Form Tambah Data Lahan",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
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
                    _buildStepIndicator(),
                    const SizedBox(height: 8),

                    // --- STEP 1: Wilayah & Lokasi ---
                    if (_currentStep == 0) ...[
                      _buildSectionTitle("Wilayah Administrasi"),
                      _buildDropdownWilayah(
                        "Pilih Kepolisian Resor (Kab/Kota)",
                        _listKab,
                        isLockedToPolres
                            ? null
                            : (v) async {
                                if (v == null) return;
                                setState(() {
                                  _selectedKabKode = v;
                                  _selectedKecKode = null;
                                  _selectedDesaKode = null;
                                  _listKec = [];
                                  _listDesa = [];
                                });
                                final name = _listKab.firstWhere(
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
                        isLockedToPolsek
                            ? null
                            : (v) async {
                                if (v == null) return;
                                setState(() {
                                  _selectedKecKode = v;
                                  _selectedDesaKode = null;
                                  _listDesa = [];
                                });
                                final polresName = _listKab.firstWhere(
                                  (e) => e['kode'] == _selectedKabKode,
                                )['nama'];
                                final polsekName = _listKec.firstWhere(
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
                      _buildTextField(
                        _alamatController,
                        "Detail Alamat Lahan",
                        Icons.location_on,
                        maxLines: 2,
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
                      _buildLeafletMap(),
                    ],

                    // --- STEP 2: Detail Kategori & Pengelola ---
                    if (_currentStep == 1) ...[
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
                    ],

                    // --- STEP 3: Informasi Teknis & Foto ---
                    if (_currentStep == 2) ...[
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
                      const SizedBox(height: 12),
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
                    ],

                    const SizedBox(height: 32),

                    // --- STEPPERS NAVIGATION BUTTONS ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        if (_currentStep > 0)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _currentStep--;
                                    });
                                  },
                                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
                                  label: const Text(
                                    "KEMBALI",
                                    style: TextStyle(
                                      color: Color(0xFF1A237E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF1A237E)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          const Spacer(),

                        // Next / Save Button
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (_currentStep < _totalSteps - 1) {
                                    if (_validateCurrentStep()) {
                                      setState(() {
                                        _currentStep++;
                                      });
                                    }
                                  } else {
                                    _handleSave();
                                  }
                                },
                                icon: Icon(
                                  _currentStep == _totalSteps - 1 ? Icons.save : Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _currentStep == _totalSteps - 1 ? "SIMPAN" : "LANJUT",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _currentStep == _totalSteps - 1
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF1A237E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;

          String title = "";
          if (index == 0) title = "Lokasi";
          if (index == 1) title = "Kategori & CP";
          if (index == 2) title = "Teknis & Foto";

          return Expanded(
            child: Row(
              children: [
                // Circle Number
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF2E7D32)
                        : (isActive ? const Color(0xFF1A237E) : Colors.grey.shade300),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: isActive || isCompleted ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                // Text Title
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? const Color(0xFF1A237E)
                          : (isCompleted ? const Color(0xFF2E7D32) : Colors.grey.shade600),
                    ),
                  ),
                ),
                // Connector Line
                if (index < _totalSteps - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          );
        }),
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
    Function(String?)? onChanged,
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

  Widget _buildLeafletMap() {
    final lat = double.tryParse(_latController.text) ?? -7.2575;
    final lng = double.tryParse(_lngController.text) ?? 112.7521;
    final center = LatLng(lat, lng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tentukan Titik Koordinat Lahan",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            TextButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location, size: 16, color: Color(0xFF1A237E)),
              label: const Text(
                "Lokasi Saya",
                style: TextStyle(fontSize: 12, color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _latController.text = point.latitude.toStringAsFixed(6);
                  _lngController.text = point.longitude.toStringAsFixed(6);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.presisi.ketahananpangan',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "*Ketuk pada peta untuk memindahkan penanda lokasi (Marker)",
          style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPhotoUploadSection() {
    Widget content;
    if (_localImagePath != null) {
      // Local image preview
      content = Image.file(File(_localImagePath!), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    } else if (_fotoPath != null && _fotoPath!.isNotEmpty) {
      // Existing backend image preview
      final fullUrl = "${ApiConfig.imageBaseUrl}${Uri.encodeComponent(_fotoPath!)}";
      content = Image.network(
        fullUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 40, color: Colors.grey);
        },
      );
    } else {
      // Placeholder
      content = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Klik untuk memilih/mengunggah foto lahan",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _pickPhoto,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade400,
            style: BorderStyle.solid,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: content),
            if (_localImagePath != null || (_fotoPath != null && _fotoPath!.isNotEmpty))
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                    onPressed: _pickPhoto,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
