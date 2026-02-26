import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:image_picker/image_picker.dart';
import '../data/model/land_potential_model.dart';
import '../data/service/land_potential_service.dart';

class AddLandController extends ChangeNotifier {
  final LandPotentialService _service;
  final LandPotentialModel? editData;

  AddLandController({
    required LandPotentialService service,
    this.editData,
  }) : _service = service {
    _initialize();
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController policeNameController = TextEditingController();
  final TextEditingController policePhoneController = TextEditingController();
  final TextEditingController picNameController = TextEditingController();
  final TextEditingController picPhoneController = TextEditingController();
  final TextEditingController picKeteranganController = TextEditingController();
  final TextEditingController jmlPoktanController = TextEditingController(text: "0");
  final TextEditingController luasLahanController = TextEditingController(text: "0.00");
  final TextEditingController jmlPetaniController = TextEditingController(text: "0");
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController ketLainController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  String? selectedResor;
  String? selectedSektor;
  String? selectedJenisLahan;
  String? selectedKomoditi;
  String? selectedKab;
  String? selectedKec;
  String? selectedDesa;
  
  String? selectedTingkatId; 
  String? selectedWilayahId;

  // State khusus untuk ENUM ketlahan (1, 2, 3)
  String selectedKetLainId = "1"; 

  String selectedStatus = "BELUM TERVALIDASI";
  
  File? selectedImageFile;
  String? existingImageUrl;
  Uint8List? imageBytes;
  LatLng? selectedLocation;

  List<String> resorList = [];
  List<String> sektorList = [];
  List<String> jenisLahanList = [];
  List<String> komoditiList = [];

  final List<String> ketLainOptions = ["PRODUKTIF", "NON-PRODUKTIF", "LAHAN TIDUR"];

  bool isLoading = false;
  bool isDataLoading = true;
  bool isSaving = false;

  bool get isEditMode => editData != null;
  bool get hasLocation => selectedLocation != null;
  bool get hasImage => selectedImageFile != null || imageBytes != null || existingImageUrl != null;

  Future<void> _initialize() async {
    isDataLoading = true;
    notifyListeners();
    
    await _loadAuthProfile();
    await _loadFilterOptions();
    
    if (editData != null) {
      await _loadInitialData();
    }
    
    isDataLoading = false;
    notifyListeners();
  }

  Future<void> _loadAuthProfile() async {
    try {
      final profile = await _service.fetchMyProfile(); 
      if (profile != null && !isEditMode) {
        selectedTingkatId = profile['id_tingkat']; 
        selectedWilayahId = profile['id_wilayah']; 
        selectedResor = profile['nama_polres'];
        selectedSektor = profile['nama_polsek'];
        debugPrint("Auth Profile Sync: ID Satker $selectedTingkatId.");
      }
    } catch (e) {
      debugPrint("Error loading auth profile: $e");
    }
  }

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
    
    // Sinkronisasi pilihan ENUM saat edit
    selectedKetLainId = (d.keteranganLain == '1' || d.keteranganLain == '2' || d.keteranganLain == '3') 
        ? d.keteranganLain 
        : "1";
    
    selectedJenisLahan = d.jenisLahan;
    selectedKomoditi = d.komoditi;
    selectedResor = d.resor;
    selectedSektor = d.sektor;
    selectedKab = d.kabupaten;
    selectedKec = d.kecamatan;
    selectedDesa = d.desa;
    selectedTingkatId = d.idTingkat;
    selectedWilayahId = d.idWilayah;
    selectedStatus = d.statusValidasi;
    
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

  void onKetLainChanged(String label) {
    if (label == "PRODUKTIF") selectedKetLainId = "1";
    else if (label == "NON-PRODUKTIF") selectedKetLainId = "2";
    else if (label == "LAHAN TIDUR") selectedKetLainId = "3";
    notifyListeners();
  }

  void setTingkatId(String kode) {
    selectedTingkatId = kode;
    notifyListeners();
  }

  void setWilayahId(String kode) {
    selectedWilayahId = kode;
    notifyListeners();
  }

  Future<void> onResorChanged(String? value) async {
    selectedResor = value;
    selectedSektor = null;
    notifyListeners();
    if (value != null) {
      await _loadFilterOptions(polres: value);
      notifyListeners();
    }
  }

  void onSektorChanged(String? value) {
    selectedSektor = value;
    notifyListeners();
  }

  void onJenisLahanChanged(String? value) {
    selectedJenisLahan = value;
    notifyListeners();
  }

  void onKomoditiChanged(String? value) {
    selectedKomoditi = value;
    notifyListeners();
  }

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

  void clearImage() {
    selectedImageFile = null;
    imageBytes = null;
    existingImageUrl = null;
    notifyListeners();
  }

  void setLocation(LatLng location, String address) {
    selectedLocation = location;
    latitudeController.text = location.latitude.toString();
    longitudeController.text = location.longitude.toString();
    alamatController.text = address;
    notifyListeners();
  }

  void clearLocation() {
    selectedLocation = null;
    latitudeController.clear();
    longitudeController.clear();
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
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

  bool validate() => formKey.currentState?.validate() ?? false;

  bool validateImage() {
    if (!isEditMode && selectedImageFile == null) return false;
    return true;
  }
  
  Future<bool> saveData() async {
    if (!validate()) return false;
    if (!validateImage()) return false;

    if (selectedTingkatId == null || selectedWilayahId == null) {
      debugPrint("Gagal Simpan: ID belum terisi.");
      return false;
    }

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
        
        // PENTING: Mengirim '1', '2', atau '3' sesuai ENUM database
        keteranganLain: selectedKetLainId, 
        
        fotoLahan: fotoLahanBase64,
        imageUrl: existingImageUrl ?? "",
        infoProses: "-",
        infoValidasi: "-",
        latitude: selectedLocation?.latitude,
        longitude: selectedLocation?.longitude,
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
    ketLainController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }
}