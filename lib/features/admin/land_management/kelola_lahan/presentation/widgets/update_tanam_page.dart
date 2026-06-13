import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/models/kelola_mode.dart';
import 'package:KETAHANANPANGAN/features/admin/land_management/kelola_lahan/data/repos/kelola_repo.dart';

class UpdateTanamPage extends StatefulWidget {
  final LandManagementItemModel item;
  const UpdateTanamPage({
    super.key,
    required this.item,
  });

  @override
  State<UpdateTanamPage> createState() => _UpdateTanamPageState();
}

class _UpdateTanamPageState extends State<UpdateTanamPage> {
  late TextEditingController tglTanamController;
  late TextEditingController luasTanamController;
  late TextEditingController jenisBibitController;
  late TextEditingController kebutuhanBibitController;
  late TextEditingController estAwalController;
  late TextEditingController estAkhirController;
  late TextEditingController dokumenController;
  late TextEditingController keteranganController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    tglTanamController = TextEditingController(text: widget.item.tglTanam);
    luasTanamController = TextEditingController(
      text: widget.item.luasTanamDetail.toString(),
    );
    jenisBibitController = TextEditingController(text: widget.item.jenisBibit);
    kebutuhanBibitController = TextEditingController(
      text: widget.item.kebutuhanBibit.toString(),
    );
    estAwalController = TextEditingController(text: widget.item.estAwalPanen);
    estAkhirController = TextEditingController(text: widget.item.estAkhirPanen);
    dokumenController = TextEditingController(
      text: widget.item.dokumenPendukung,
    );
    keteranganController = TextEditingController(
      text: widget.item.keteranganTanam,
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
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
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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
      "tgl_tanam": tglTanamController.text,
      "luas_tanam": double.tryParse(luasTanamController.text) ?? 0.0,
      "jenis_bibit": jenisBibitController.text,
      "kebutuhan_bibit": double.tryParse(kebutuhanBibitController.text) ?? 0.0,
      "est_awal_panen": estAwalController.text,
      "est_akhir_panen": estAkhirController.text,
      "dokumen_pendukung": dokumenController.text,
      "keterangan": keteranganController.text,
    };

    final success = await LandManagementRepository().updateTanam(
      widget.item.id,
      data,
    );

    if (mounted) setState(() => isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
      
      // JEDA 500ms: Memastikan database MySQL sudah selesai melakukan LOCK/UPDATE
      // sebelum Flutter melakukan fetching ulang.
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    bool isDate = false,
    bool isFile = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: isDate ? () => _selectDate(context, controller) : null,
            child: AbsorbPointer(
              absorbing: isDate,
              child: TextFormField(
                controller: controller,
                keyboardType:
                    isNumber
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                maxLines: maxLines,
                readOnly: isFile,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: Colors.grey),
                  suffixIcon:
                      isFile
                          ? IconButton(
                            icon: const Icon(Icons.upload_file, color: Colors.blue),
                            onPressed: _pickFile,
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFFB8C00)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          "Update Data Tanam",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFB8C00),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      "Tanggal Tanam (YYYY-MM-DD)",
                      tglTanamController,
                      Icons.calendar_today,
                      isDate: true,
                    ),
                    _buildInputField(
                      "Luas Tanam (Ha)",
                      luasTanamController,
                      Icons.square_foot,
                      isNumber: true,
                    ),
                    _buildInputField(
                      "Jenis Bibit",
                      jenisBibitController,
                      Icons.grass,
                    ),
                    _buildInputField(
                      "Kebutuhan Bibit (Kg)",
                      kebutuhanBibitController,
                      Icons.scale,
                      isNumber: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            "Est. Panen Awal",
                            estAwalController,
                            Icons.date_range,
                            isDate: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInputField(
                            "Est. Panen Akhir",
                            estAkhirController,
                            Icons.event_available,
                            isDate: true,
                          ),
                        ),
                      ],
                    ),
                    _buildInputField(
                      "Dokumen Pendukung",
                      dokumenController,
                      Icons.file_present,
                      isFile: true,
                    ),
                    _buildInputField(
                      "Keterangan Lain",
                      keteranganController,
                      Icons.note_alt,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB8C00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "SIMPAN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
