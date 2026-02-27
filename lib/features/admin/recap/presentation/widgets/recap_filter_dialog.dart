import 'package:flutter/material.dart';
import '../../data/repo/recap_repo.dart';

class RecapFilterDialog extends StatefulWidget {
  const RecapFilterDialog({super.key});

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
    if (mounted) {
      setState(() {
        _listPolres = data['polres']!;
        _listJenis = data['jenis_lahan']!;
        _listKomoditi = data['komoditi']!;
        _isLoading = false;
      });
    }
  }

  void _showLockMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Silakan pilih wilayah Polres terlebih dahulu"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetFilterInternal() {
    setState(() {
      _selPolres = null;
      _selPolsek = null;
      _selJenis = null;
      _selKomoditi = null;
      _selYear = null;
      _selQuarter = null;
      _startDate = null;
      _endDate = null;
      _listPolsek = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPolresSelected = _selPolres != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(
                            color: Colors.deepPurple,
                          ),
                        ),
                      )
                    else ...[
                      _buildSectionTitle("Wilayah"),
                      _buildDrop(
                        "Pilih Polres",
                        _selPolres,
                        _listPolres,
                        true,
                        (v) {
                          setState(() {
                            _selPolres = v;
                            _selPolsek = null;
                          });
                          if (v != null) {
                            _repo.getFilterOptions(polres: v).then((d) {
                              if (mounted)
                                setState(() => _listPolsek = d['polsek']!);
                            });
                          }
                        },
                      ),
                      _buildDrop(
                        "Pilih Polsek",
                        _selPolsek,
                        _listPolsek,
                        isPolresSelected,
                        (v) => setState(() => _selPolsek = v),
                      ),

                      const SizedBox(height: 16),
                      _buildSectionTitle("Kategori"),
                      _buildDrop(
                        "Jenis Lahan",
                        _selJenis,
                        _listJenis,
                        isPolresSelected,
                        (v) => setState(() => _selJenis = v),
                      ),
                      _buildDrop(
                        "Komoditi",
                        _selKomoditi,
                        _listKomoditi,
                        isPolresSelected,
                        (v) => setState(() => _selKomoditi = v),
                      ),

                      const SizedBox(height: 16),
                      _buildSectionTitle("Waktu"),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDrop(
                              "Tahun",
                              _selYear,
                              ["2024", "2025", "2026"],
                              isPolresSelected,
                              (v) => setState(() => _selYear = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDrop(
                              "Kuartal",
                              _selQuarter,
                              ["1", "2", "3", "4"],
                              isPolresSelected,
                              (v) => setState(() => _selQuarter = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDateRangePicker(isPolresSelected),
                    ],
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, color: Colors.deepPurple),
          const SizedBox(width: 12),
          const Text(
            "Filter Rekapitulasi",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.grey),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildDrop(
    String label,
    String? val,
    List<String> list,
    bool isEnabled,
    Function(String?) onChg,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: isEnabled ? null : _showLockMessage,
        child: AbsorbPointer(
          absorbing: !isEnabled,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: DropdownButtonFormField<String>(
              value: val,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 1.5,
                  ),
                ),
              ),
              items:
                  list
                      .toSet()
                      .toList()
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 14)),
                        ),
                      )
                      .toList(),
              onChanged: onChg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(bool isEnabled) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _dateButton(
                _startDate,
                "Mulai",
                isEnabled,
                (d) => setState(() => _startDate = d),
              ),
            ),
            Container(width: 1, height: 20, color: Colors.grey.shade300),
            Expanded(
              child: _dateButton(
                _endDate,
                "Selesai",
                isEnabled,
                (d) => setState(() => _endDate = d),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateButton(
    DateTime? date,
    String label,
    bool isEnabled,
    Function(DateTime) onPick,
  ) {
    return TextButton.icon(
      onPressed:
          isEnabled
              ? () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) onPick(d);
              }
              : _showLockMessage,
      icon: const Icon(Icons.calendar_today_outlined, size: 14),
      label: Text(
        date == null ? label : date.toString().split(' ')[0],
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor:
            isEnabled
                ? (date == null ? Colors.grey.shade600 : Colors.deepPurple)
                : Colors.grey,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _resetFilterInternal();
                Navigator.pop(context, <String, String>{});
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Reset",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'polres': _selPolres ?? '',
                  'polsek': _selPolsek ?? '',
                  'jenis_lahan': _selJenis ?? '',
                  'komoditi': _selKomoditi ?? '',
                  'tahun': _selYear ?? '',
                  'kuartal': _selQuarter ?? '',
                  'tgl_awal': _startDate?.toIso8601String().split('T')[0] ?? '',
                  'tgl_akhir': _endDate?.toIso8601String().split('T')[0] ?? '',
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Terapkan Filter",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
