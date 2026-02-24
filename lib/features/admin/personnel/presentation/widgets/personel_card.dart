import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/auth/models/role_enum.dart';

// --- PALET WARNA EARTHY & ORGANIC ---
const Color _forestGreen = Color(0xFF2D4F1E);
const Color _warmBeige = Color(0xFFF5E6CC);
const Color _terracotta = Color(0xFFE27D60);
const Color _slateGrey = Color(0xFF4A4A4A);
const Color _bgWarm = Color(0xFFFDF8F3);
const Color _borderWarm = Color(0xFFE8DDD0);
const Color _textPrimary = Color(0xFF2C3E2D);

class PersonelCard extends StatelessWidget {
  final UserModel personel;
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

  String? _sanitizePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    String sanitized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (sanitized.startsWith('0')) {
      sanitized = '+62${sanitized.substring(1)}';
    } else if (sanitized.startsWith('62') && !sanitized.startsWith('+')) {
      sanitized = '+$sanitized';
    } else if (!sanitized.startsWith('+')) {
      sanitized = '+$sanitized';
    }
    if (sanitized.length < 8 || sanitized.length > 15) return null;
    return sanitized;
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final message = Uri.encodeComponent(
      "Halo ${personel.namaLengkap}, saya ingin menghubungi terkait tugas di ${personel.tingkatDetail?.nama ?? 'Kantor'}.",
    );
    final waNumber = phone.replaceAll('+', '');
    final Uri url = Uri.parse("https://wa.me/$waNumber?text=$message");
    debugPrint('Launching WhatsApp: $url');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          _showError(context, 'WhatsApp tidak terinstall atau tidak dapat dibuka');
        }
      }
    } catch (e) {
      debugPrint('WhatsApp Error: $e');
      if (context.mounted) {
        _showError(context, 'Error: $e');
      }
    }
  }

  Future<void> _launchPhoneCall(BuildContext context, String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    debugPrint('Launching Phone: $url');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          _showError(context, 'Tidak dapat melakukan panggilan');
        }
      }
    } catch (e) {
      debugPrint('Phone Error: $e');
      if (context.mounted) {
        _showError(context, 'Error: $e');
      }
    }
  }

  Future<void> _launchSMS(BuildContext context, String phone) async {
    final Uri url = Uri.parse("sms:$phone");
    debugPrint('Launching SMS: $url');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          _showError(context, 'Tidak dapat membuka SMS');
        }
      }
    } catch (e) {
      debugPrint('SMS Error: $e');
      if (context.mounted) {
        _showError(context, 'Error: $e');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _terracotta,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _forestGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    final sanitized = _sanitizePhoneNumber(personel.noTelp);
    if (sanitized == null) {
      _showError(context, 'Nomor telepon tidak valid');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ContactBottomSheet(
        name: personel.namaLengkap,
        phone: sanitized,
        onCall: () async {
          Navigator.pop(sheetContext);
          await Future.delayed(const Duration(milliseconds: 200));
          if (context.mounted) {
            await _launchPhoneCall(context, sanitized);
          }
        },
        onSms: () async {
          Navigator.pop(sheetContext);
          await Future.delayed(const Duration(milliseconds: 200));
          if (context.mounted) {
            await _launchSMS(context, sanitized);
          }
        },
        onWhatsApp: () async {
          Navigator.pop(sheetContext);
          await Future.delayed(const Duration(milliseconds: 200));
          if (context.mounted) {
            await _launchWhatsApp(context, sanitized);
          }
        },
        onCopy: () {
          Clipboard.setData(ClipboardData(text: sanitized));
          Navigator.pop(sheetContext);
          _showSuccess(context, 'Nomor disalin: $sanitized');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String unitName = personel.tingkatDetail?.nama ?? "-";
    final String jabatanName = personel.jabatanDetail?.namaJabatan ?? "-";
    final String? sanitizedPhone = _sanitizePhoneNumber(personel.noTelp);
    final bool hasPhone = sanitizedPhone != null;
    final String displayPhone = hasPhone ? sanitizedPhone : "Belum terdaftar";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderWarm, width: 1),
        boxShadow: [
          BoxShadow(
            color: _forestGreen.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAvatar(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  personel.namaLengkap.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _textPrimary,
                                    letterSpacing: 0.3,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _warmBeige.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    unitName.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _forestGreen,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ActionMenu(
                            onEdit: onEdit,
                            onDelete: onDelete,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _bgWarm,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderWarm),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoItem(
                                    icon: Icons.work_outline,
                                    label: "JABATAN",
                                    value: jabatanName,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: _borderWarm,
                                ),
                                Expanded(
                                  child: _InfoItem(
                                    icon: Icons.badge_outlined,
                                    label: "ID TUGAS",
                                    value: personel.idTugas,
                                  ),
                                ),
                              ],
                            ),
                            if (hasPhone) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: _borderWarm),
                              ),
                              _InfoItem(
                                icon: Icons.phone_outlined,
                                label: "NOMOR TELEPON",
                                value: displayPhone,
                                isPhone: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _RoleBadge(role: personel.role),
                          if (hasPhone)
                            Text(
                              "Ketuk untuk menghubungi",
                              style: TextStyle(
                                fontSize: 11,
                                color: _slateGrey.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              if (hasPhone)
                Container(
                  decoration: BoxDecoration(
                    color: _bgWarm,
                    border: Border(
                      top: BorderSide(color: _borderWarm),
                    ),
                  ),
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.phone,
                        label: "Telepon",
                        color: _forestGreen,
                        onTap: () => _launchPhoneCall(context, sanitizedPhone),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: _borderWarm,
                      ),
                      _ActionButton(
                        icon: Icons.message_outlined,
                        label: "SMS",
                        color: _terracotta,
                        onTap: () => _launchSMS(context, sanitizedPhone),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: _borderWarm,
                      ),
                      _ActionButton(
                        icon: Icons.chat,
                        label: "WhatsApp",
                        color: const Color(0xFF25D366),
                        onTap: () => _launchWhatsApp(context, sanitizedPhone),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final String initial = personel.namaLengkap.isNotEmpty
        ? personel.namaLengkap[0].toUpperCase()
        : '?';

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_forestGreen, Color(0xFF1E3A0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _forestGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: personel.fotoProfil != null && personel.fotoProfil!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                personel.fotoProfil!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildInitials(initial),
              ),
            )
          : _buildInitials(initial),
    );
  }

  Widget _buildInitials(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ContactBottomSheet extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onSms;
  final VoidCallback onWhatsApp;
  final VoidCallback onCopy;

  const _ContactBottomSheet({
    required this.name,
    required this.phone,
    required this.onCall,
    required this.onSms,
    required this.onWhatsApp,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _borderWarm,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_forestGreen, Color(0xFF1E3A0F)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                phone,
                style: TextStyle(
                  fontSize: 16,
                  color: _slateGrey.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _bgWarm,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: _slateGrey,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _BigActionButton(
                    icon: Icons.phone,
                    label: "Telepon",
                    color: _forestGreen,
                    onTap: onCall,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BigActionButton(
                    icon: Icons.message_outlined,
                    label: "SMS",
                    color: _terracotta,
                    onTap: onSms,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BigActionButton(
                    icon: Icons.chat_bubble,
                    label: "WA",
                    color: const Color(0xFF25D366),
                    onTap: onWhatsApp,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
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

class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BigActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPhone;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPhone ? _forestGreen.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isPhone ? _forestGreen : _slateGrey.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _slateGrey.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isPhone ? _forestGreen : _textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
    Color color;
    String label;
    
    switch (role) {
      case UserRole.admin:
        color = _terracotta;
        label = "ADMIN";
        break;
      case UserRole.operator:
        color = const Color(0xFFD4A574);
        label = "OPERATOR";
        break;
      case UserRole.view:
        color = _forestGreen;
        label = "VIEWER";
        break;
      default:
        color = _slateGrey;
        label = "UNKNOWN";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ActionMenu({
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _bgWarm,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.more_horiz,
          color: _slateGrey.withOpacity(0.7),
          size: 20,
        ),
      ),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (v) => v == 'edit' ? onEdit?.call() : onDelete?.call(),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: _forestGreen),
              const SizedBox(width: 12),
              const Text(
                "Ubah Data",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: _terracotta, size: 20),
              const SizedBox(width: 12),
              Text(
                "Hapus",
                style: TextStyle(
                  color: _terracotta,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}