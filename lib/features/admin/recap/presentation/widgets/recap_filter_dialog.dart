import 'package:flutter/material.dart';
import '../../data/repo/recap_repo.dart';

class RecapFilterDialog extends StatefulWidget {
  @override
  State<RecapFilterDialog> createState() => _RecapFilterDialogState();
}

class _RecapFilterDialogState extends State<RecapFilterDialog> {
  final RecapRepo _repo = RecapRepo();
  bool _isLoading = true;

  List<String> _listPolres = [],
      _listPolsek = [],
      _listJenis = [],
      _listKomoditi = [];
  String? _selPolres,
      _selPolsek,
      _selJenis,
      _selKomoditi,
      _selYear,
      _selQuarter;
  DateTime? _startDate, _endDate;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final data = await _repo.getFilterOptions();
    setState(() {
      _listPolres = data['polres']!;
      _listJenis = data['jenis_lahan']!;
      _listKomoditi = data['komoditi']!;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filter Rekapitulasi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                _buildDrop("Polres", _selPolres, _listPolres, (v) {
                  setState(() {
                    _selPolres = v;
                    _selPolsek = null;
                  });
                  _repo
                      .getFilterOptions(polres: v)
                      .then((d) => setState(() => _listPolsek = d['polsek']!));
                }),
                _buildDrop(
                  "Polsek",
                  _selPolsek,
                  _listPolsek,
                  (v) => setState(() => _selPolsek = v),
                ),
                _buildDrop(
                  "Jenis Lahan",
                  _selJenis,
                  _listJenis,
                  (v) => setState(() => _selJenis = v),
                ),
                _buildDrop(
                  "Komoditi",
                  _selKomoditi,
                  _listKomoditi,
                  (v) => setState(() => _selKomoditi = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildDrop("Tahun", _selYear, [
                        "2024",
                        "2025",
                        "2026",
                      ], (v) => setState(() => _selYear = v)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDrop("Kuartal", _selQuarter, [
                        "1",
                        "2",
                        "3",
                        "4",
                      ], (v) => setState(() => _selQuarter = v)),
                    ),
                  ],
                ),
                _buildDatePickers(),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'polres': _selPolres ?? '',
                    'polsek': _selPolsek ?? '',
                    'jenis_lahan': _selJenis ?? '',
                    'komoditi': _selKomoditi ?? '',
                    'tahun': _selYear ?? '',
                    'kuartal': _selQuarter ?? '',
                    'tgl_awal':
                        _startDate?.toIso8601String().split('T')[0] ?? '',
                    'tgl_akhir':
                        _endDate?.toIso8601String().split('T')[0] ?? '',
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Terapkan Filter"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrop(
    String label,
    String? val,
    List<String> list,
    Function(String?) onChg,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<String>(
        value: val,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items:
            list
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
        onChanged: onChg,
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              setState(() => _startDate = d);
            },
            child: Text(
              _startDate == null
                  ? "Tgl Awal"
                  : _startDate!.toString().split(' ')[0],
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              setState(() => _endDate = d);
            },
            child: Text(
              _endDate == null
                  ? "Tgl Akhir"
                  : _endDate!.toString().split(' ')[0],
            ),
          ),
        ),
      ],
    );
  }
}
