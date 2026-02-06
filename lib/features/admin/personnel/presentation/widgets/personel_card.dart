import 'package:flutter/material.dart';
import '../../data/model/personel_model.dart';
import '../../data/model/role_enum.dart'; 

class PersonelCard extends StatelessWidget {
  final Personel personel;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        // Border tipis tapi tegas (Slate-200) untuk kesan rapi & kokoh
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        borderRadius: BorderRadius.circular(12), // Radius sedikit lebih tajam (12 vs 16)
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06), // Slate-900 shadow (Darker)
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
                // 1. AVATAR (Square-ish untuk kesan maskulin/teknis)
                _AvatarSection(
                  name: personel.namaLengkap,
                  photoUrl: personel.fotoProfil,
                ),

                // Spacer "Agak ke kanan" sesuai request
                const SizedBox(width: 20), 

                // 2. INFORMASI UTAMA & DATA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Nama & Menu di baris yang sama
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
                                    fontWeight: FontWeight.w800, // Extra Bold
                                    color: Color(0xFF1E293B), // Slate-800
                                    height: 1.1, // Rapat
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  personel.jabatan.toUpperCase(), // Uppercase biar gahar
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B), // Slate-500
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Menu Geser ke Pojok Kanan Atas
                          _ActionMenu(onEdit: onEdit, onDelete: onDelete),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // GARIS TYPOGRAFI (Separator)
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9), // Slate-100
                      ),

                      const SizedBox(height: 12),

                      // DATA SECTION (NRP & HP)
                      // Menggunakan Layout Teknis
                      _TechnicalDataRow(
                        label: "NRP",
                        value: personel.nrp,
                        icon: Icons.badge_rounded,
                      ),
                      
                      const SizedBox(height: 6), // Jarak Rapat

                      _TechnicalDataRow(
                        label: "TEL",
                        value: (personel.noTelp != null && personel.noTelp!.isNotEmpty) 
                            ? personel.noTelp! 
                            : "-",
                        icon: Icons.phone_iphone_rounded,
                        isPlaceholder: personel.noTelp == null || personel.noTelp!.isEmpty,
                      ),

                      const SizedBox(height: 14),

                      // ROLE BADGE (Bottom Alignment)
                      Align(
                        alignment: Alignment.centerLeft,
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

// =============================================================================
// SUB-WIDGETS (HIGH CONTRAST & TECHNICAL)
// =============================================================================

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
        // Icon Kecil
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)), // Slate-400
        
        const SizedBox(width: 8),
        
        Container(
          width: 1, 
          height: 12, 
          color: const Color(0xFFE2E8F0), // Slate-200
        ),
        
        const SizedBox(width: 8),

        // Value Data
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Ramabadra', 
              fontWeight: FontWeight.w600,
              color: isPlaceholder ? const Color(0xFFCBD5E1) : const Color(0xFF334155), // Slate-700
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
      width: 56, // Sedikit lebih besar
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Slate-50
        borderRadius: BorderRadius.circular(10), // Square rounded (Gahar)
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
                  fontWeight: FontWeight.w800, // Extra Bold
                  color: Color(0xFF64748B), // Slate-500
                ),
              ),
            ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    // Warna Solid & Kontras
    switch (role) {
      case UserRole.admin:
        bgColor = const Color(0xFFFEF2F2); 
        textColor = const Color(0xFFB91C1C); // Dark Red
        borderColor = const Color(0xFFFECACA);
        break;
      case UserRole.polres:
        bgColor = const Color(0xFFFFF7ED);
        textColor = const Color(0xFFC2410C); // Dark Orange
        borderColor = const Color(0xFFFED7AA);
        break;
      case UserRole.polsek:
        bgColor = const Color(0xFFF3E8FF); // Purple-100
        textColor = const Color(0xFF7E22CE); // Purple-700
        borderColor = const Color(0xFFE9D5FF);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9); 
        textColor = const Color(0xFF475569); 
        borderColor = const Color(0xFFE2E8F0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor), // Tambah border agar tegas
      ),
      child: Text(
        role.label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800, // Bold
          letterSpacing: 0.8,
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
        icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)), // Icon horizontal agar modern
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