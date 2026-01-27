import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart';
import 'package:sdmapp/features/admin/land_management/Potensi_lahan/data/repos/land_potential_repository.dart';

enum LandState { initial, loading, loaded, empty, error }

class LandPotentialController extends ChangeNotifier {
  final LandPotentialRepository _repo = LandPotentialRepository();

  LandState _state = LandState.initial;
  LandState get state => _state;

  // Kita simpan data yang SUDAH dikelompokkan agar UI tidak perlu mikir lagi
  Map<String, List<LandPotentialModel>> _groupedData = {};
  Map<String, List<LandPotentialModel>> get groupedData => _groupedData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchData() async {
    // Set loading (opsional, bisa dimatikan jika ingin instant feel)
    _state = LandState.loading;
    notifyListeners();

    try {
      final data = await _repo.getLandPotentials();

      if (data.isEmpty) {
        _state = LandState.empty;
      } else {
        // OPTIMISASI: Grouping dilakukan di sini (sekali saja), bukan di UI
        _groupedData = _groupDataByKabupaten(data);
        _state = LandState.loaded;
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      _errorMessage = e.toString();
      _state = LandState.error;
    }
    notifyListeners();
  }

  // Logic Grouping dipindah ke sini
  Map<String, List<LandPotentialModel>> _groupDataByKabupaten(List<LandPotentialModel> list) {
    Map<String, List<LandPotentialModel>> grouped = {};
    for (var item in list) {
      if (!grouped.containsKey(item.kabupaten)) {
        grouped[item.kabupaten] = [];
      }
      grouped[item.kabupaten]!.add(item);
    }
    return grouped;
  }
}