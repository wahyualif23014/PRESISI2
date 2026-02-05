import 'polres_model.dart';
import 'polsek_model.dart';

class UnitRegionViewModel {
  final PolresModel polres;
  final List<PolsekModel> polseks;
  bool isExpanded;

  UnitRegionViewModel({
    required this.polres,
    this.polseks = const [],
    this.isExpanded = false,
  });
}