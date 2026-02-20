import 'package:flutter/material.dart';
import '../../data/model/recap_model.dart';
import '../../data/repo/recap_repo.dart';

enum RecapState { initial, loading, loaded, error, empty }

class RecapController extends ChangeNotifier {
  final RecapRepo _repo = RecapRepo();

  RecapState _state = RecapState.initial;
  RecapState get state => _state;

  Map<String, List<RecapModel>> _groupedData = {};
  Map<String, List<RecapModel>> get groupedData => _groupedData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchData() async {
    _state = RecapState.loading;
    notifyListeners();

    try {
      final flatData = await _repo.getRecapData();

      if (flatData.isEmpty) {
        _state = RecapState.empty;
      } else {
        _groupedData = _processDataStructure(flatData);
        _state = RecapState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = RecapState.error;
    }

    notifyListeners();
  }

  Map<String, List<RecapModel>> _processDataStructure(List<RecapModel> flatData) {
    Map<String, List<RecapModel>> result = {};
    String currentPolres = "";
    String currentPolsek = "";

    for (var item in flatData) {
      if (item.type == RecapRowType.polres) {
        currentPolres = item.namaWilayah;
        result[currentPolres] = [];
      } else if (item.type == RecapRowType.polsek) {
        currentPolsek = item.namaWilayah;
      } else if (item.type == RecapRowType.desa) {
        final enrichedItem = item.namaPolsek == null 
            ? item.copyWith(namaPolsek: currentPolsek) 
            : item;
        
        if (currentPolres.isNotEmpty) {
           result[currentPolres]?.add(enrichedItem);
        }
      }
    }
    return result;
  }
}