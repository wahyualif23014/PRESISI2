import 'package:flutter/material.dart';
import '../../data/model/personel_model.dart';
import '../../data/model/role_enum.dart'; // Pastikan path enum benar

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
      // Dekorasi Container (Shadow & Rounded)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.blue.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BAGIAN AVATAR (Support Foto & Inisial)
                _AvatarSection(
                  name: personel.namaLengkap,
                  photoUrl: personel.fotoProfil,
                ),

                const SizedBox(width: 16),

                // 2. BAGIAN INFORMASI UTAMA
                Expanded(
                  child: _InfoSection(personel: personel),
                ),

                // 3. BAGIAN AKSI (MENU)
                _ActionSection(onEdit: onEdit, onDelete: onDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS (UI COMPONENTS)
// =============================================================================

class _AvatarSection extends StatelessWidget {
  final String name;
  final String? photoUrl; // Tambahan: URL Foto

  const _AvatarSection({required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final bool hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100, width: 1),
        // Jika ada foto, jadikan background image
        image: hasPhoto
            ? DecorationImage(
                image: NetworkImage(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null // Jika ada foto, child kosong (karena sudah di background)
          : Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Personel personel;

  const _InfoSection({required this.personel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama Lengkap
        Text(
          personel.namaLengkap,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B), // Slate 800
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Jabatan
        Text(
          personel.jabatan,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 10),

        // Info Detail (NRP & HP)
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _IconText(icon: Icons.badge_outlined, text: personel.nrp),
            // Menampilkan No Telp (Handle jika null)
            _IconText(
              icon: Icons.phone_android_rounded, 
              text: (personel.noTelp != null && personel.noTelp!.isNotEmpty) 
                  ? personel.noTelp! 
                  : "-",
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Role Badge
        _RoleBadge(role: personel.role),
      ],
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    // Logic Warna Badge sesuai Role Backend
    String label = role.label.toUpperCase(); // ADMIN, POLRES, POLSEK, VIEW

    Color bgColor;
    Color textColor;

    switch (role) {
      case UserRole.admin:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        break;
      case UserRole.polres:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        break;
      case UserRole.polsek:
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade800;
        break;
      case UserRole.view:
      default:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionSection({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == 'edit' && onEdit != null) onEdit!();
          if (value == 'delete' && onDelete != null) onDelete!();
        },
        itemBuilder: (context) => [
          _buildMenuItem('edit', Icons.edit_outlined, 'Edit Data', Colors.black87),
          const PopupMenuDivider(),
          _buildMenuItem('delete', Icons.delete_outline, 'Hapus', Colors.red),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}