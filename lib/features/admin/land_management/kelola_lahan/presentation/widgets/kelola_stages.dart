import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';

class UpdatePanenDialog extends StatefulWidget {
  final LandManagementItemModel item;
  final VoidCallback onSuccess;
  
  const UpdatePanenDialog({
    super.key,
    required this.item,
    required this.onSuccess,
  });

  @override
  State<UpdatePanenDialog> createState() => _UpdatePanenDialogState();
}

class _UpdatePanenDialogState extends State<UpdatePanenDialog> {
  late TextEditingController luasPanenController;
  late TextEditingController totalPanenController;
  late TextEditingController tglPanenController;
  late TextEditingController keteranganController;
  late TextEditingController dokumenController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    luasPanenController = TextEditingController();
    totalPanenController = TextEditingController();
    tglPanenController = TextEditingController();
    keteranganController = TextEditingController();
    dokumenController = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFB8C00),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        dokumenController.text = result.files.single.name;
      });
    }
  }

  Future<void> _handleUpdate() async {
    setState(() => isLoading = true);

    final data = {
      "id_tanam": widget.item.idTanam,
      "luas_panen": double.tryParse(luasPanenController.text) ?? 0.0,
      "total_panen": double.tryParse(totalPanenController.text) ?? 0.0,
      "tgl_panen": tglPanenController.text,
      "keterangan": keteranganController.text,
      "surat_edit": dokumenController.text,
    };

    final success = await LandManagementRepository().updatePanen(widget.item.id, data);

    if (mounted) setState(() => isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) widget.onSuccess();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data panen berhasil disimpan"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.agriculture, color: Colors.white),
                SizedBox(width: 12),
                Text("ISI DATA PANEN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInputField("Tanggal Panen (YYYY-MM-DD)", tglPanenController, Icons.calendar_today, isDate: true),
                  _buildInputField("Luas Panen (Ha)", luasPanenController, Icons.square_foot, isNumber: true),
                  _buildInputField("Total Panen (Ton)", totalPanenController, Icons.scale, isNumber: true),
                  _buildInputField("Dokumen Pendukung", dokumenController, Icons.file_present, isFile: true),
                  _buildInputField("Keterangan", keteranganController, Icons.note_alt, maxLines: 2),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                    child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("SIMPAN", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isDate = false, bool isFile = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: isDate || isFile,
        maxLines: maxLines,
        onTap: () {
          if (isDate) _selectDate(context, controller);
          if (isFile) _pickFile();
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class UpdateSerapanDialog extends StatefulWidget {
  final LandManagementItemModel item;
  final VoidCallback onSuccess;
  
  const UpdateSerapanDialog({
    super.key,
    required this.item,
    required this.onSuccess,
  });

  @override
  State<UpdateSerapanDialog> createState() => _UpdateSerapanDialogState();
}

class _UpdateSerapanDialogState extends State<UpdateSerapanDialog> {
  late TextEditingController distribusiKeController;
  late TextEditingController totalDistribusiController;
  late TextEditingController tglDistribusiController;
  late TextEditingController keteranganController;
  late TextEditingController dokumenController;
  bool isLoading = false;
  List<String> _resapanList = [];
  String? _selectedResapan;
  bool isLoadingResapan = true;

  @override
  void initState() {
    super.initState();
    distribusiKeController = TextEditingController();
    totalDistribusiController = TextEditingController();
    tglDistribusiController = TextEditingController();
    keteranganController = TextEditingController();
    dokumenController = TextEditingController();
    _fetchResapanList();
  }

  Future<void> _fetchResapanList() async {
    final list = await LandManagementRepository().getResapanList();
    if (mounted) {
      setState(() {
        _resapanList = list;
        isLoadingResapan = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFB8C00),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        dokumenController.text = result.files.single.name;
      });
    }
  }

  Future<void> _handleUpdate() async {
    setState(() => isLoading = true);

    final data = {
      "id_panen": widget.item.idPanen,
      "distribusi_ke": _selectedResapan ?? distribusiKeController.text,
      "total_distribusi": double.tryParse(totalDistribusiController.text) ?? 0.0,
      "tgl_distribusi": tglDistribusiController.text,
      "keterangan": keteranganController.text,
      "surat_edit": dokumenController.text,
    };

    final success = await LandManagementRepository().updateSerapan(widget.item.id, data);

    if (mounted) setState(() => isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) widget.onSuccess();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data serapan berhasil disimpan"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0288D1),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.white),
                SizedBox(width: 12),
                Text("ISI DATA SERAPAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Total Panen Tersedia: ${widget.item.hasilPanen} Ton",
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildInputField("Tanggal Distribusi (YYYY-MM-DD)", tglDistribusiController, Icons.calendar_today, isDate: true),
                  _buildDropdownField(),
                  _buildInputField("Total Distribusi (Ton)", totalDistribusiController, Icons.scale, isNumber: true),
                  _buildInputField("Dokumen Pendukung", dokumenController, Icons.file_present, isFile: true),
                  _buildInputField("Keterangan", keteranganController, Icons.note_alt, maxLines: 2),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0288D1)),
                    child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("SIMPAN", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedResapan,
        decoration: InputDecoration(
          labelText: "Distribusi Ke (Resapan)",
          labelStyle: const TextStyle(fontSize: 12),
          prefixIcon: const Icon(Icons.location_city, size: 20, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: isLoadingResapan 
            ? [const DropdownMenuItem(value: null, child: Text("Memuat data..."))]
            : _resapanList.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: isLoadingResapan ? null : (newValue) {
          setState(() {
            _selectedResapan = newValue;
          });
        },
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isDate = false, bool isFile = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: isDate || isFile,
        maxLines: maxLines,
        onTap: () {
          if (isDate) _selectDate(context, controller);
          if (isFile) _pickFile();
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
