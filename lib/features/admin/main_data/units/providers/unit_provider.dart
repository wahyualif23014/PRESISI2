import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Import Service & Model Backend
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/services/kesatuan_service.dart';
import 'package:KETAHANANPANGAN/features/admin/main_data/units/data/models/kesatuan_model.dart';

// Import Model UI
import '../data/models/unit_region_viewmodel.dart';
import '../data/models/polres_model.dart';
import '../data/models/polsek_model.dart';
import '../data/models/wilayah_model.dart';

class UnitProvider with ChangeNotifier {
  // --- STATE ---
  List<UnitRegionViewModel> _originalList = [];
  List<UnitRegionViewModel> _filteredList = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _currentSearchQuery = "";

  // State Filter
  bool _showPolres = true;
  bool _showPolsek = true;
  String _selectedWilayah = "Semua";

  // --- GETTERS ---
  List<UnitRegionViewModel> get units => _filteredList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showPolres => _showPolres;
  bool get showPolsek => _showPolsek;
  String get selectedWilayah => _selectedWilayah;

  // ✅ GETTER: Total Polres (yang terfilter)
  int get totalPolres => _filteredList.length;

  // ✅ GETTER: Total Polsek (yang terfilter)
  int get totalPolsek {
    return _filteredList.fold<int>(
      0,
      (sum, region) => sum + region.polseks.length,
    );
  }

  // Getter: List Wilayah Unik untuk Dropdown
  List<String> get uniqueWilayahList {
    final wilayahs = _originalList
        .map((e) => e.polres.wilayah?.kabupaten ?? "")
        .where((w) => w.isNotEmpty)
        .toSet()
        .toList();

    wilayahs.sort();
    return ["Semua", ...wilayahs];
  }

  // --- ACTIONS ---

  Future<void> fetchUnits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final service = KesatuanService();
      List<KesatuanModel> backendData = await service.getKesatuan();

      List<UnitRegionViewModel> mappedData = backendData.map((k) {
        // ✅ Mapping Polres dengan data lengkap
        final polresUI = PolresModel(
          id: 0,
          namaPolres: k.namaSatuan,
          kapolres: k.namaPejabat,
          noTelp: _formatPhoneNumber(k.noHp), // ✅ Format nomor
          wilayahId: 0,
          wilayah: WilayahModel(
            id: 0,
            kabupaten: k.wilayah,
            kecamatan: "",
            latitude: 0,
            longitude: 0,
          ),
        );

        // ✅ Mapping Polsek dengan data lengkap
        final polsekUIList = k.daftarPolsek.map((child) {
          return PolsekModel(
            id: 0,
            namaPolsek: child.namaSatuan,
            kapolsek: child.namaPejabat,
            noTelp: _formatPhoneNumber(child.noHp), // ✅ Format nomor
            kode: child.kode,
            polresId: 0,
            wilayahId: 0,
            wilayah: WilayahModel(
              id: 0,
              kabupaten: child.wilayah,
              kecamatan: "",
              latitude: 0,
              longitude: 0,
            ),
          );
        }).toList();

        return UnitRegionViewModel(
          polres: polresUI,
          polseks: polsekUIList,
          isExpanded: false,
        );
      }).toList();

      _originalList = mappedData;

      // Terapkan filter awal
      applyFilter(
        _showPolres,
        _showPolsek,
        _selectedWilayah,
        _currentSearchQuery,
      );

      _isLoading = false;
      notifyListeners(); // ✅ Jangan lupa notify setelah sukses
    } catch (e) {
      print("Error Fetch Units: $e");
      _errorMessage = "Gagal memuat data: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchUnits();
  }

  void toggleExpand(int index) {
    if (index >= 0 && index < _filteredList.length) {
      _filteredList[index].isExpanded = !_filteredList[index].isExpanded;
      notifyListeners();
    }
  }

  // ✅ FUNGSI: Format nomor telepon (bersihkan & tambah +62 jika perlu)
  String _formatPhoneNumber(String? rawNumber) {
    if (rawNumber == null || rawNumber.isEmpty || rawNumber == '-') {
      return '-';
    }

    // Hapus spasi, strip, dan karakter non-digit kecuali +
    String cleaned = rawNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Jika dimulai dengan 0, ganti dengan +62
    if (cleaned.startsWith('0')) {
      cleaned = '+62${cleaned.substring(1)}';
    }
    // Jika tidak dimulai dengan +, tambahkan +62
    else if (!cleaned.startsWith('+')) {
      cleaned = '+62$cleaned';
    }

    return cleaned;
  }

  // ✅ FUNGSI: Tap untuk menelepon
  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber == '-' || phoneNumber.isEmpty) return;

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _errorMessage = "Tidak dapat melakukan panggilan ke $phoneNumber";
        notifyListeners();
      }
    } catch (e) {
      print("Error launching dialer: $e");
      _errorMessage = "Gagal membuka aplikasi telepon";
      notifyListeners();
    }
  }

  // ✅ PERBAIKAN: Filter Logic yang lebih robust
  void applyFilter(
    bool showPolres,
    bool showPolsek,
    String wilayah,
    String query,
  ) {
    _showPolres = showPolres;
    _showPolsek = showPolsek;
    _selectedWilayah = wilayah;
    _currentSearchQuery = query;

    final searchLower = query.toLowerCase().trim();

    _filteredList = _originalList.where((region) {
      // 1. Filter Wilayah
      if (_selectedWilayah != "Semua") {
        final regionWilayah = region.polres.wilayah?.kabupaten ?? "";
        if (regionWilayah != _selectedWilayah) {
          return false;
        }
      }

      // 2. Filter Search Teks (Polres)
      final polresName = region.polres.namaPolres.toLowerCase();
      final polresPejabat = region.polres.kapolres.toLowerCase();
      final matchPolres = polresName.contains(searchLower) ||
          polresPejabat.contains(searchLower);

      // 3. Filter Search Teks (Polsek)
      final matchingPolseks = region.polseks.where((polsek) {
        final polsekName = polsek.namaPolsek.toLowerCase();
        final polsekPejabat = polsek.kapolsek.toLowerCase();
        final polsekKode = polsek.kode.toLowerCase();
        final polsekWilayah = polsek.wilayah?.kabupaten.toLowerCase() ?? "";

        return polsekName.contains(searchLower) ||
            polsekPejabat.contains(searchLower) ||
            polsekKode.contains(searchLower) ||
            polsekWilayah.contains(searchLower);
      }).toList();

      final hasMatchingPolsek = matchingPolseks.isNotEmpty;

      // 4. Logic Pencarian
      bool shouldShow = false;

      if (searchLower.isEmpty) {
        // Jika tidak ada search, tampilkan semua (tergantung checkbox)
        shouldShow = _showPolres;
      } else {
        // Jika ada search, tampilkan jika Polres cocok ATAU ada Polsek yang cocok
        shouldShow = matchPolres || hasMatchingPolsek;
      }

      // 5. Auto-expand jika search cocok dengan Polsek
      if (searchLower.isNotEmpty && hasMatchingPolsek && !matchPolres) {
        // Jika yang cocok hanya Polsek (bukan Polres), expand untuk menunjukkan hasil
        region.isExpanded = true;
      } else if (searchLower.isEmpty) {
        // Reset expand saat search kosong
        region.isExpanded = false;
      }

      return shouldShow;
    }).map((region) {
      // 6. Filter Polsek berdasarkan search (jika ada search, hanya tampilkan yang cocok)
      List<PolsekModel> filteredPolseks;
      
      if (searchLower.isNotEmpty) {
        // Jika sedang search, filter Polsek yang cocok
        filteredPolseks = region.polseks.where((polsek) {
          final polsekName = polsek.namaPolsek.toLowerCase();
          final polsekPejabat = polsek.kapolsek.toLowerCase();
          final polsekKode = polsek.kode.toLowerCase();
          final polsekWilayah = polsek.wilayah?.kabupaten.toLowerCase() ?? "";

          return polsekName.contains(searchLower) ||
              polsekPejabat.contains(searchLower) ||
              polsekKode.contains(searchLower) ||
              polsekWilayah.contains(searchLower);
        }).toList();
      } else {
        // Jika tidak search, tampilkan semua atau kosong tergantung checkbox
        filteredPolseks = _showPolsek ? region.polseks : [];
      }

      return UnitRegionViewModel(
        polres: region.polres,
        polseks: filteredPolseks,
        isExpanded: region.isExpanded,
      );
    }).toList();

    notifyListeners();
  }

  // Wrapper untuk Search Bar
  void search(String query) {
    applyFilter(_showPolres, _showPolsek, _selectedWilayah, query);
  }

  void resetFilter() {
    _showPolres = true;
    _showPolsek = true;
    _selectedWilayah = "Semua";
    _currentSearchQuery = "";
    
    // Reset semua expand state
    for (var region in _originalList) {
      region.isExpanded = false;
    }
    
    _filteredList = List.from(_originalList);
    notifyListeners();
  }
}