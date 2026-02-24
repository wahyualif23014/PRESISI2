import 'package:flutter/material.dart';

enum JabatanFormType { add, edit, delete }

class JabatanFormWidget extends StatelessWidget {
  final JabatanFormType type;
  final TextEditingController jabatanController;
  // Controller ini tetap ada di parameter agar tidak merusak PositionPage, 
  // namun tidak ditampilkan di UI sesuai kebutuhan database Anda.
  final TextEditingController namaController;
  final TextEditingController nrpController;
  final TextEditingController tanggalController;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const JabatanFormWidget({
    super.key,
    required this.type,
    required this.jabatanController,
    required this.namaController,
    required this.nrpController,
    required this.tanggalController,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDelete = type == JabatanFormType.delete;
    final isEdit = type == JabatanFormType.edit;

    final title = isDelete ? "Hapus Jabatan" : (isEdit ? "Edit Jabatan" : "Tambah Jabatan");
    final submitLabel = isDelete ? "Hapus" : "Simpan";
    final submitColor = isDelete ? const Color(0xFFE27D60) : const Color(0xFF2D4F1E);
    
    final iconHeader = isDelete
        ? Icons.delete_sweep_rounded
        : (isEdit ? Icons.edit_calendar_rounded : Icons.add_business_rounded);

    return Container(
      width: double.infinity,
      // Desain BottomSheet yang lebih elegan
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _DragHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormHeader(
                    title: title,
                    icon: iconHeader,
                    isDestructive: isDelete,
                  ),
                  const SizedBox(height: 28),
                  
                  if (!isDelete) ...[
                    // HANYA MENAMPILKAN NAMA JABATAN SESUAI DB
                    _FormInputField(
                      label: "Nama Jabatan Baru",
                      controller: jabatanController,
                      hint: "Contoh: KAPOLSEK, WAKAPOLDA, dll.",
                      icon: Icons.account_tree_outlined,
                      autoFocus: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "* Nama jabatan akan muncul di daftar pilihan anggota.",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    // TAMPILAN PERINGATAN HAPUS
                    _DeleteWarningBox(),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: "Batal",
                          isOutlined: true,
                          onTap: onCancel,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          label: submitLabel,
                          backgroundColor: submitColor,
                          onTap: onSubmit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SUB-WIDGETS UNTUK KONSISTENSI ---

class _DeleteWarningBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE27D60).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE27D60).withOpacity(0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.report_problem_rounded, color: Color(0xFFE27D60), size: 44),
          SizedBox(height: 12),
          Text(
            "Konfirmasi Hapus",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE27D60)),
          ),
          SizedBox(height: 4),
          Text(
            "Data jabatan yang dihapus tidak dapat dipulihkan. Lanjutkan?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDestructive;

  const _FormHeader({required this.title, required this.icon, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final themeColor = isDestructive ? const Color(0xFFE27D60) : const Color(0xFF2D4F1E);
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: themeColor.withOpacity(0.1),
          child: Icon(icon, size: 32, color: themeColor),
        ),
        const SizedBox(height: 16),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C3E2D),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _FormInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool autoFocus;

  const _FormInputField({
    required this.label, 
    required this.controller, 
    this.hint = "", 
    required this.icon,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF4A4A4A)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          autofocus: autoFocus,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2D4F1E)),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2D4F1E), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton({required this.label, this.backgroundColor, this.isOutlined = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : (backgroundColor ?? const Color(0xFF2D4F1E)),
          foregroundColor: isOutlined ? const Color(0xFF4A4A4A) : Colors.white,
          elevation: isOutlined ? 0 : 4,
          shadowColor: (backgroundColor ?? const Color(0xFF2D4F1E)).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOutlined ? const BorderSide(color: Color(0xFFE2E8F0)) : BorderSide.none,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}