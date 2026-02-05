import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unit_service.dart';
import '../models/unit_region_viewmodel.dart'; // ViewModel Gabungan
import '../models/polres_model.dart';
import '../models/polsek_model.dart';

// 1. Provider Service
final unitServiceProvider = Provider<UnitService>((ref) => UnitService());

// 2. Controller Utama
final unitControllerProvider = AsyncNotifierProvider<UnitController, List<UnitRegionViewModel>>(
  UnitController.new,
);

class UnitController extends AsyncNotifier<List<UnitRegionViewModel>> {
  UnitService get _service => ref.read(unitServiceProvider);

  // Variable lokal untuk filtering (Search)
  List<UnitRegionViewModel> _fullList = [];

  @override
  Future<List<UnitRegionViewModel>> build() async {
    return _fetchAndGroupData();
  }

  // --- LOGIC UTAMA: FETCH & GROUPING ---
  Future<List<UnitRegionViewModel>> _fetchAndGroupData() async {
    // 1. Ambil data Polres & Polsek secara paralel (lebih cepat)
    final results = await Future.wait([
      _service.getPolres(),
      _service.getPolsek(),
    ]);

    final List<PolresModel> polresList = results[0] as List<PolresModel>;
    final List<PolsekModel> polsekList = results[1] as List<PolsekModel>;

    // 2. Grouping Logic
    // Kita iterasi setiap Polres, lalu cari anak-anaknya (Polsek) yang punya ID Polres sama
    final groupedList = polresList.map((polres) {
      final childPolseks = polsekList.where((p) => p.polresId == polres.id).toList();

      return UnitRegionViewModel(
        polres: polres,
        polseks: childPolseks,
        isExpanded: false, // Default tertutup
      );
    }).toList();

    _fullList = groupedList; // Simpan untuk backup search
    return groupedList;
  }

  // --- ACTIONS ---

  // Refresh Data
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAndGroupData());
  }

  // Toggle Accordion (Buka/Tutup)
  void toggleExpand(int index) {
    if (!state.hasValue) return;

    final currentList = state.value!;
    // Kita buat copy list agar state terdeteksi berubah
    final newList = List<UnitRegionViewModel>.from(currentList);
    
    // Toggle status expanded
    newList[index].isExpanded = !newList[index].isExpanded;

    state = AsyncData(newList);
  }

  // Search Logic
  void search(String keyword) {
    if (keyword.isEmpty) {
      state = AsyncData(_fullList);
      return;
    }

    final query = keyword.toLowerCase();
    
    // Filter: Tampilkan region jika Nama Polres match ATAU ada salah satu Polsek match
    final filtered = _fullList.where((region) {
      final polresMatch = region.polres.namaPolres.toLowerCase().contains(query);
      final polsekMatch = region.polseks.any((p) => p.namaPolsek.toLowerCase().contains(query));
      
      return polresMatch || polsekMatch;
    }).toList();

    state = AsyncData(filtered);
  }
}