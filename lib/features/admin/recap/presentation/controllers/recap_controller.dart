import 'package:flutter/material.dart';
import 'package:sdmapp/features/admin/recap/data/model/recap_model.dart';
import 'package:sdmapp/features/admin/recap/data/repo/recap_repo.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_data_row.dart';
import 'package:sdmapp/features/admin/recap/presentation/widgets/recap_group_section.dart';

enum RecapState { initial, loading, loaded, error, empty }

class RecapController extends ChangeNotifier {
  final RecapRepo _repo = RecapRepo();

  RecapState _state = RecapState.initial;
  RecapState get state => _state;

  List<Widget> _treeWidgets = [];
  List<Widget> get treeWidgets => _treeWidgets;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Fungsi Fetch Data (Non-Blocking UI)
  Future<void> fetchData() async {
    _state = RecapState.loading;
    notifyListeners(); 

    try {
      final flatData = await _repo.getRecapData();

      if (flatData.isEmpty) {
        _state = RecapState.empty;
      } else {
        // PROSES BERAT (Grouping) dilakukan di sini agar UI tetap smooth
        _treeWidgets = _buildTreeStructure(flatData);
        _state = RecapState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = RecapState.error;
    }

    notifyListeners();
  }

  // Logic Grouping Data (Clean Code)
  List<Widget> _buildTreeStructure(List<RecapModel> flatData) {
    List<Widget> resultWidgets = [];
    RecapModel? currentPolres;
    List<Widget> polresChildren = [];
    RecapModel? currentPolsek;
    List<Widget> polsekChildren = [];

    void flushPolsek() {
      if (currentPolsek != null) {
        polresChildren.add(
          RecapGroupSection(
            header: currentPolsek!,
            children: List.from(polsekChildren),
          ),
        );
        polsekChildren = [];
        currentPolsek = null;
      }
    }

    void flushPolres() {
      flushPolsek();
      if (currentPolres != null) {
        resultWidgets.add(
          RecapGroupSection(
            header: currentPolres!,
            children: List.from(polresChildren),
          ),
        );
        polresChildren = [];
        currentPolres = null;
      }
    }

    for (var item in flatData) {
      if (item.type == RecapRowType.polres) {
        flushPolres();
        currentPolres = item;
      } else if (item.type == RecapRowType.polsek) {
        flushPolsek();
        currentPolsek = item;
      } else if (item.type == RecapRowType.desa) {
        polsekChildren.add(RecapDataRow(data: item));
      }
    }

    flushPolres();
    return resultWidgets;
  }
}