import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:flutter/material.dart';
// Pastikan import ini mengarah ke file UserModel yang benar

class PersonelCard extends StatelessWidget {
  final UserModel personel; // Menggunakan UserModel
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PersonelCard({
    super.key,
    required this.personel,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. LOGIC SAFE ACCESS UNTUK JABATAN
    // Jika jabatanDetail ada, ambil namanya. Jika null, tampilkan '-'
    final String displayJabatan = personel.jabatanDetail?.namaJabatan ?? '-';

    // 2. LOGIC SAFE ACCESS UNTUK NO TELP
    // Cek apakah tidak null DAN tidak kosong
    final bool hasPhone = personel.noTelp != null && personel.noTelp!.isNotEmpty;
    final String displayPhone = hasPhone ? personel.noTelp! : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.blueGrey.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. AVATAR
                _AvatarSection(
                  name: personel.namaLengkap,
                  photoUrl: personel.fotoProfil,
                ),

                const SizedBox(width: 20),

                // 2. INFORMASI UTAMA & DATA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  personel.namaLengkap,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayJabatan.toUpperCase(), // Gunakan variabel yang sudah diamankan
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          _ActionMenu(onEdit: onEdit, onDelete: onDelete),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(height: 1, color: const Color(0xFFF1F5F9)),
                      const SizedBox(height: 12),

                      // DATA SECTION (ID TUGAS & HP)
                      _TechnicalDataRow(
                        label: "ID TUGAS",
                        value: personel.idTugas,
                        icon: Icons.badge_rounded,
                      ),

                      const SizedBox(height: 6),

                      _TechnicalDataRow(
                        label: "TEL",
                        value: displayPhone, // Gunakan variabel safe phone
                        icon: Icons.phone_iphone_rounded,
                        isPlaceholder: !hasPhone,
                      ),

                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerLeft,
                        // Kirim Role String ('1','2','3') ke Badge
                        child: _RoleBadge(role: personel.role),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- SUB WIDGETS ---

class _RoleBadge extends StatelessWidget {
  final String role; 

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;

    switch (role) {
      case '1':
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFB91C1C);
        borderColor = const Color(0xFFFECACA);
        label = "ADMINISTRATOR";
        break;
      case '2':
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFC2410C);
        borderColor = const Color(0xFFFED7AA);
        label = "OPERATOR";
        break;
      case '3':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7E22CE);
        borderColor = const Color(0xFFE9D5FF);
        label = "VIEW ONLY";
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        borderColor = const Color(0xFFE2E8F0);
        label = "UNKNOWN";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// --- WIDGET HELPER LAINNYA TIDAK BERUBAH ---
// (Copy paste _TechnicalDataRow, _AvatarSection, _ActionMenu dari kode sebelumnya)

class _TechnicalDataRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPlaceholder;

  const _TechnicalDataRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Container(width: 1, height: 12, color: const Color(0xFFE2E8F0)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Ramabadra',
              fontWeight: FontWeight.w600,
              color: isPlaceholder ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const _AvatarSection({required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bool hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionMenu({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: (value) {
          if (value == 'edit' && onEdit != null) onEdit!();
          if (value == 'delete' && onDelete != null) onDelete!();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.edit_note, color: Colors.black87, size: 18),
                SizedBox(width: 12),
                Text("Edit Data", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          const PopupMenuItem(
            value: 'delete',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 18),
                SizedBox(width: 12),
                Text("Hapus", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}