import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart' show LandPotentialModel;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/data/service/land_potential_service.dart' show LandPotentialService;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:image_picker/image_picker.dart';

/// Controller untuk mengelola logika penambahan dan edit data lahan.
/// Menggunakan ChangeNotifier untuk state management.
class AddLandController extends ChangeNotifier {
  final LandPotentialService _service;
  final LandPotentialModel? editData;

  AddLandController({
    required LandPotentialService service,
    this.editData,
  }) : _service = service {
    _initialize();
  }

  // ===========================================================================
  // FORM & NAVIGATION KEYS
  // ===========================================================================
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // ===========================================================================
  // TEXT EDITING CONTROLLERS
  // ===========================================================================
  
  final TextEditingController policeNameController = TextEditingController();
  final TextEditingController policePhoneController = TextEditingController();
  final TextEditingController picNameController = TextEditingController();
  final TextEditingController picPhoneController = TextEditingController();
  final TextEditingController picKeteranganController = TextEditingController();
  final TextEditingController jmlPoktanController = TextEditingController(text: "0");
  final TextEditingController luasLahanController = TextEditingController(text: "0.00");
  final TextEditingController jmlPetaniController = TextEditingController(text: "0");
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  
  // Controller tambahan untuk sinkronisasi model baru
  final TextEditingController skLahanController = TextEditingController();
  final TextEditingController lembagaController = TextEditingController();
  final TextEditingController tahunLahanController = TextEditingController(text: DateTime.now().year.toString());

  // ===========================================================================
  // SELECTED VALUES - DROPDOWN & STATE
  // ===========================================================================
  
  String? selectedResor;
  String? selectedSektor;
  String? selectedJenisLahan;
  String? selectedKomoditi;
  String? selectedKab;
  String? selectedKec;
  String? selectedDesa;
  
  String? selectedTingkatId; 
  String? selectedWilayahId;

  String selectedKetLainId = "1"; 
  String selectedStatus = "1"; // Default ENUM '1' (Belum Tervalidasi)
  String selectedStatusPakai = "1"; // Default ENUM '1'
  String selectedStatusAktif = "2"; // Default ENUM '2'
  
  // ===========================================================================
  // IMAGE & LOCATION DATA
  // ===========================================================================
  
  File? selectedImageFile;
  String? existingImageUrl;
  Uint8List? imageBytes;
  LatLng? selectedLocation;

  // ===========================================================================
  // FILTER OPTIONS LISTS
  // ===========================================================================
  
  List<String> resorList = [];
  List<String> sektorList = [];
  List<String> jenisLahanList = [];
  List<String> komoditiList = [];

  final List<String> ketLainOptions = ["PRODUKTIF", "NON-PRODUKTIF", "LAHAN TIDUR"];

  // ===========================================================================
  // LOADING STATES
  // ===========================================================================
  
  bool isLoading = false;
  bool isDataLoading = true;
  bool isSaving = false;

  // ===========================================================================
  // GETTERS
  // ===========================================================================
  
  bool get isEditMode => editData != null;
  bool get hasLocation => selectedLocation != null;
  bool get hasImage => selectedImageFile != null || imageBytes != null || existingImageUrl != null;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  /// Inisialisasi controller - memuat data auth, filter options, dan data edit jika ada.
  Future<void> _initialize() async {
    isDataLoading = true;
    notifyListeners();
    
    await _loadAuthProfile();
    await _loadFilterOptions();
    
    if (isEditMode) {
      await _loadInitialData();
    }
    
    isDataLoading = false;
    notifyListeners();
  }

  /// Memuat profile user yang sedang login untuk auto-fill data satker.
  Future<void> _loadAuthProfile() async {
    try {
      final profile = await _service.fetchMyProfile(); 
      if (profile != null && !isEditMode) {
        selectedTingkatId = profile['id_tingkat']?.toString(); 
        selectedWilayahId = profile['id_wilayah']?.toString(); 
        selectedResor = profile['nama_polres']?.toString().toUpperCase();
        selectedSektor = profile['nama_polsek']?.toString().toUpperCase();
        debugPrint("Auth Profile Sync: Satker $selectedTingkatId terdeteksi.");
      }
    } catch (e) {
      debugPrint("Error loading auth profile: $e");
    }
  }

  /// Memuat opsi filter dari backend (polres, polsek, jenis lahan, komoditas).
  Future<void> _loadFilterOptions({String? polres}) async {
    try {
      final options = await _service.fetchFilterOptions(polres: polres);
      resorList = options['polres'] ?? [];
      sektorList = options['polsek'] ?? [];
      jenisLahanList = options['jenis_lahan'] ?? [];
      komoditiList = options['komoditas'] ?? [];
    } catch (e) {
      debugPrint("Error loading filters: $e");
    }
  }

  /// Memuat data awal saat mode edit.
  Future<void> _loadInitialData() async {
    final d = editData!;
    policeNameController.text = d.policeName;
    policePhoneController.text = d.policePhone;
    picNameController.text = d.picName;
    picPhoneController.text = d.picPhone;
    picKeteranganController.text = d.keterangan;
    jmlPoktanController.text = d.jumlahPoktan.toString();
    luasLahanController.text = d.luasLahan.toString();
    jmlPetaniController.text = d.jumlahPetani.toString();
    alamatController.text = d.alamatLahan;
    
    skLahanController.text = d.skLahan;
    lembagaController.text = d.lembaga;
    tahunLahanController.text = d.tahunLahan;

    selectedKetLainId = (d.keteranganLain == '1' || d.keteranganLain == '2' || d.keteranganLain == '3') 
        ? d.keteranganLain 
        : "1";
    
    selectedStatus = d.statusValidasi;
    selectedStatusPakai = d.statusPakai;
    selectedStatusAktif = d.statusAktif;

    selectedJenisLahan = d.jenisLahan;
    selectedKomoditi = d.komoditi;
    selectedResor = d.resor;
    selectedSektor = d.sektor;
    selectedKab = d.kabupaten;
    selectedKec = d.kecamatan;
    selectedDesa = d.desa;
    selectedTingkatId = d.idTingkat;
    selectedWilayahId = d.idWilayah;
    
    if (d.latitude != null && d.longitude != null) {
      selectedLocation = LatLng(d.latitude!, d.longitude!);
      latitudeController.text = d.latitude!.toString();
      longitudeController.text = d.longitude!.toString();
    }
    
    if (d.imageUrl.isNotEmpty) {
      existingImageUrl = d.imageUrl;
      imageBytes = await _service.fetchImageBytes(d.imageUrl);
    }
  }

  // ===========================================================================
  // EVENT HANDLERS - DROPDOWN CHANGES
  // ===========================================================================
  
  /// Handler perubahan keterangan lain (PRODUKTIF/NON-PRODUKTIF/LAHAN TIDUR).
  void onKetLainChanged(String label) {
    if (label == "PRODUKTIF") selectedKetLainId = "1";
    else if (label == "NON-PRODUKTIF") selectedKetLainId = "2";
    else if (label == "LAHAN TIDUR") selectedKetLainId = "3";
    notifyListeners();
  }

  /// Handler perubahan resor - akan reload daftar sektor.
  Future<void> onResorChanged(String? value) async {
    selectedResor = value;
    selectedSektor = null;
    notifyListeners();
    if (value != null) {
      await _loadFilterOptions(polres: value);
      notifyListeners();
    }
  }

  void onSektorChanged(String? value) => {selectedSektor = value, notifyListeners()};
  void onJenisLahanChanged(String? value) => {selectedJenisLahan = value, notifyListeners()};
  void onKomoditiChanged(String? value) => {selectedKomoditi = value, notifyListeners()};

  // ===========================================================================
  // IMAGE HANDLERS
  // ===========================================================================
  
  /// Memilih gambar dari kamera atau gallery.
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        selectedImageFile = File(pickedFile.path);
        existingImageUrl = null;
        imageBytes = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  /// Menghapus gambar yang sudah dipilih.
  void clearImage() {
    selectedImageFile = null;
    imageBytes = null;
    existingImageUrl = null;
    notifyListeners();
  }

  /// ✅ VALIDASI GAMBAR
  /// 
  /// Memvalidasi apakah gambar lahan sudah dipilih.
  /// - Mode tambah (create): Wajib ada gambar baru yang dipilih
  /// - Mode edit: Bisa menggunakan gambar yang sudah ada (existingImageUrl)
  /// 
  /// Returns `true` jika valid, `false` jika belum ada gambar.
  bool validateImage() {
    // Mode edit: boleh pakai gambar lama atau gambar baru
    if (isEditMode) {
      return hasImage; // Cek dari getter: file baru, bytes, atau URL lama
    }
    
    // Mode tambah: wajib ada file gambar baru yang dipilih
    return selectedImageFile != null;
  }

  // ===========================================================================
  // LOCATION HANDLERS
  // ===========================================================================
  
  /// Mengatur lokasi dari peta atau manual input.
  void setLocation(LatLng location, String address) {
    selectedLocation = location;
    latitudeController.text = location.latitude.toString();
    longitudeController.text = location.longitude.toString();
    alamatController.text = address;
    notifyListeners();
  }

  /// ✅ MEMBERSIHKAN DATA LOKASI
  /// 
  /// Menghapus semua data lokasi yang tersimpan termasuk koordinat dan alamat.
  /// Digunakan saat user ingin mereset atau menghapus lokasi yang sudah dipilih.
  void clearLocation() {
    selectedLocation = null;
    latitudeController.clear();
    longitudeController.clear();
    // Note: alamatController tidak di-clear agar user bisa mengisi manual
    notifyListeners();
  }

  /// Mendapatkan lokasi saat ini menggunakan GPS device.
  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      selectedLocation = LatLng(position.latitude, position.longitude);
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
    } catch (e) {
      debugPrint("Error GPS: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // VALIDATION & SAVE
  // ===========================================================================
  
  /// Validasi form sebelum submit.
  bool validate() => formKey.currentState?.validate() ?? false;
  
  /// Menyimpan data lahan ke backend (create atau update).
  Future<bool> saveData() async {
    if (!validate()) return false;
    
    // ✅ Gunakan validateImage() untuk konsistensi
    if (!validateImage()) return false;

    if (selectedTingkatId == null || selectedWilayahId == null) return false;

    isSaving = true;
    notifyListeners();

    try {
      String fotoLahanBase64 = "";
      if (selectedImageFile != null) {
        final bytes = await selectedImageFile!.readAsBytes();
        fotoLahanBase64 = base64Encode(bytes);
      }

      final payload = LandPotentialModel(
        id: editData?.id ?? "0",
        idWilayah: selectedWilayahId!, 
        idTingkat: selectedTingkatId!, 
        kabupaten: selectedKab ?? "-",
        kecamatan: selectedKec ?? "-",
        desa: selectedDesa ?? "-",
        resor: selectedResor ?? '-',
        sektor: selectedSektor ?? '-',
        idJenisLahan: _getIdJenisLahan(selectedJenisLahan),
        jenisLahan: selectedJenisLahan ?? "LAHAN LAINNYA",
        luasLahan: double.tryParse(luasLahanController.text) ?? 0.0,
        alamatLahan: alamatController.text,
        statusValidasi: selectedStatus,
        policeName: policeNameController.text,
        policePhone: policePhoneController.text,
        picName: picNameController.text,
        picPhone: picPhoneController.text,
        keterangan: picKeteranganController.text,
        jumlahPoktan: int.tryParse(jmlPoktanController.text) ?? 0,
        jumlahPetani: int.tryParse(jmlPetaniController.text) ?? 0,
        idKomoditi: 1,
        komoditi: selectedKomoditi ?? "JAGUNG",
        keteranganLain: selectedKetLainId, 
        fotoLahan: fotoLahanBase64,
        imageUrl: existingImageUrl ?? "",
        infoProses: "-",
        infoValidasi: "-",
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
        // Sync field baru sesuai skema DB
        statusPakai: selectedStatusPakai,
        statusAktif: selectedStatusAktif,
        skLahan: skLahanController.text,
        lembaga: lembagaController.text,
        sumberData: "-",
        tglProses: DateTime.now().toIso8601String(),
        tahunLahan: tahunLahanController.text,
      );

      return isEditMode
          ? await _service.updateLandData(editData!.id, payload)
          : await _service.postLandData(payload);

    } catch (e) {
      debugPrint('Error saving data: $e');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  /// Mapping nama jenis lahan ke ID integer.
  int _getIdJenisLahan(String? title) {
    final Map<String, int> mapping = {
      "LAHAN MILIK POLRI": 1,
      "LAHAN PRODUKTIF (POKTAN BINAAN POLRI)": 2,
      "LAHAN PRODUKTIF (MASYARAKAT BINAAN POLRI)": 3,
      "LAHAN PRODUKTIF (TUMPANG SARI)": 4,
      "LAHAN HUTAN (PERHUTANAN SOSIAL)": 5,
      "LAHAN HUTAN (PERHUTANANI/INHUTAN)": 6,
      "LAHAN PESANTREN": 7,
      "LAHAN LUAS BAKU SAWAH (LBS)": 8,
    };
    return mapping[title] ?? 9;
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================
  
  @override
  void dispose() {
    policeNameController.dispose();
    policePhoneController.dispose();
    picNameController.dispose();
    picPhoneController.dispose();
    picKeteranganController.dispose();
    jmlPoktanController.dispose();
    luasLahanController.dispose();
    jmlPetaniController.dispose();
    alamatController.dispose();
    skLahanController.dispose();
    lembagaController.dispose();
    tahunLahanController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }
}