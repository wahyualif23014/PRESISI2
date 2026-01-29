import 'package:flutter/material.dart';

enum JabatanFormType { add, edit, delete } // Tambahkan 'edit' jika perlu

class JabatanFormWidget extends StatelessWidget {
  final JabatanFormType type;
  final TextEditingController jabatanController;
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
    
    final title = isDelete ? "Hapus Data Jabatan" : (type == JabatanFormType.add ? "Tambah Data Jabatan" : "Edit Data Jabatan");
    final submitLabel = isDelete ? "Hapus Data" : "Simpan Data";
    final submitColor = isDelete ? Colors.redAccent : const Color(0xFF10B981); // Emerald Green
    final iconHeader = isDelete ? Icons.delete_forever_rounded : Icons.edit_note_rounded;

    // --- FORM CONTENT ---
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header Icon & Title
          _FormHeader(title: title, icon: iconHeader, isDestructive: isDelete),
          
          const SizedBox(height: 24),

          // 2. Form Fields (Hidden if Delete Mode)
          if (!isDelete) ...[
            _FormInputField(
              label: "Nama Jabatan",
              controller: jabatanController,
              hint: "Contoh: Kabag Ops",
              icon: Icons.work_outline_rounded,
            ),
            _FormInputField(
              label: "Nama Pejabat",
              controller: namaController,
              hint: "Nama Lengkap & Gelar",
              icon: Icons.person_outline_rounded,
            ),
            Row(
              children: [
                Expanded(
                  child: _FormInputField(
                    label: "NRP",
                    controller: nrpController,
                    hint: "12345678",
                    icon: Icons.badge_outlined,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FormInputField(
                    label: "Tanggal Peresmian",
                    controller: tanggalController,
                    hint: "DD/MM/YYYY",
                    icon: Icons.calendar_today_rounded,
                    isReadOnly: true, // Idealnya pakai DatePicker
                  ),
                ),
              ],
            ),
          ] else 
            const Text(
              "Apakah Anda yakin ingin menghapus data ini? Data yang dihapus tidak dapat dikembalikan.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

          const SizedBox(height: 32),

          // 3. Action Buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: "Batal",
                  icon: Icons.close_rounded,
                  color: Colors.grey.shade200,
                  textColor: Colors.grey.shade800,
                  onTap: onCancel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionButton(
                  label: submitLabel,
                  icon: isDelete ? Icons.delete_outline : Icons.check_circle_outline,
                  color: submitColor,
                  textColor: Colors.white,
                  onTap: onSubmit,
                ),
              ),
            ],
          ),
          
          // Safety padding for bottom sheet
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SUB-WIDGETS (Private & Clean)
// -----------------------------------------------------------------------------

class _FormHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDestructive;

  const _FormHeader({
    required this.title,
    required this.icon,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.shade50 : Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: isDestructive ? Colors.red : Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B), // Slate 800
            letterSpacing: -0.5,
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
  final bool isNumber;
  final bool isReadOnly;

  const _FormInputField({
    required this.label,
    required this.controller,
    this.hint = "",
    required this.icon,
    this.isNumber = false,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569), // Slate 600
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Slate 100
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              controller: controller,
              readOnly: isReadOnly,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}