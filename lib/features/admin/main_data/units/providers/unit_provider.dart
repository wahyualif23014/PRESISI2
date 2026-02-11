import 'package:flutter/material.dart';

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
  String _selectedWilayah = "Semua"; // Default: Semua Wilayah

  // --- GETTERS ---
  List<UnitRegionViewModel> get units => _filteredList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get showPolres => _showPolres;
  bool get showPolsek => _showPolsek;
  String get selectedWilayah => _selectedWilayah;

  // Getter Baru: Mengambil List Wilayah Unik dari Data untuk Dropdown
  List<String> get uniqueWilayahList {
    final wilayahs =
        _originalList
            .map((e) => e.polres.wilayah?.kabupaten ?? "")
            .where((w) => w.isNotEmpty)
            .toSet() // Hapus duplikat
            .toList();

    wilayahs.sort(); // Urutkan abjad
    return ["Semua", ...wilayahs]; // Tambahkan opsi "Semua" di paling atas
  }

  int get totalUnits {
    int total = 0;
    for (var region in _filteredList) {
      total += 1;
      total += region.polseks.length;
    }
    return total;
  }

  // --- ACTIONS ---

  Future<void> fetchUnits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final service = KesatuanService();
      List<KesatuanModel> backendData = await service.getKesatuan();

      List<UnitRegionViewModel> mappedData =
          backendData.map((k) {
            final polresUI = PolresModel(
              id: 0,
              namaPolres: k.namaSatuan,
              kapolres: k.namaPejabat,
              noTelp: k.noHp,
              wilayahId: 0,
              wilayah: WilayahModel(
                id: 0,
                kabupaten: k.wilayah,
                kecamatan: "",
                latitude: 0,
                longitude: 0,
              ),
            );

            final polsekUIList =
                k.daftarPolsek.map((child) {
                  return PolsekModel(
                    id: 0,
                    namaPolsek: child.namaSatuan,
                    kapolsek: child.namaPejabat,
                    noTelp: child.noHp,
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

  // --- UPDATE FILTER LOGIC ---
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

    final searchLower = query.toLowerCase();

    _filteredList =
        _originalList
            .where((region) {
              // 1. Filter Wilayah
              if (_selectedWilayah != "Semua") {
                final regionWilayah = region.polres.wilayah?.kabupaten ?? "";
                if (regionWilayah != _selectedWilayah) {
                  return false; // Sembunyikan jika wilayah tidak cocok
                }
              }

              // 2. Filter Search Teks
              final matchPolres = region.polres.namaPolres
                  .toLowerCase()
                  .contains(searchLower);
              final matchPolsek = region.polseks.any(
                (p) =>
                    p.namaPolsek.toLowerCase().contains(searchLower) ||
                    p.kode.contains(searchLower),
              );

              bool matchText = matchPolres || matchPolsek;

              // 3. Filter Checkbox Polres
              if (!_showPolres) return false;

              // Auto Expand jika search ketemu di anak
              if (query.isNotEmpty && matchPolsek) {
                region.isExpanded = true;
              }

              return matchText;
            })
            .map((region) {
              // 4. Filter Checkbox Polsek (Hide Anak)
              return UnitRegionViewModel(
                polres: region.polres,
                polseks: _showPolsek ? region.polseks : [],
                isExpanded: region.isExpanded,
              );
            })
            .toList();

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
    _filteredList =
        _originalList.map((e) {
          e.isExpanded = false;
          return e;
        }).toList();
    notifyListeners();
  }
}
