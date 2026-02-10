import 'package:KETAHANANPANGAN/auth/models/auth_model.dart';
import 'package:KETAHANANPANGAN/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../auth/provider/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _idTugasController;
  late TextEditingController _usernameController;
  late TextEditingController _jabatanController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final UserModel? user = context.read<AuthProvider>().user;

    _nameController = TextEditingController(text: user?.namaLengkap ?? '');
    _idTugasController = TextEditingController(text: user?.idTugas ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _phoneController = TextEditingController(text: user?.noTelp ?? '');
    
    _jabatanController = TextEditingController(
      text: user?.jabatanDetail?.namaJabatan ?? user?.idJabatan.toString() ?? '-',
    );

    _roleController = TextEditingController(text: _getRoleDisplay(user?.role));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idTugasController.dispose();
    _usernameController.dispose();
    _jabatanController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getRoleDisplay(String? role) {
    switch (role) {
      case '1':
        return 'Administrator';
      case '2':
        return 'Operator';
      case '3':
        return 'View Only';
      default:
        return 'Unknown Role';
    }
  }

  void _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      isEditing = false;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data berhasil diperbarui!"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final UserModel? user = auth.user;

        return Scaffold(
          backgroundColor: AppColors.slate50,
          appBar: AppBar(
            backgroundColor: AppColors.slate800,
            elevation: 0,
            centerTitle: true,
            title: Text(
              isEditing ? "Edit Profil" : "Profil Saya",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.white,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.dashboard);
                }
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.slate200,
                          border: Border.all(color: AppColors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.slate900.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: (user?.fotoProfil ?? '').isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  user!.fotoProfil!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 50, color: AppColors.slate400),
                                ),
                              )
                            : const Icon(Icons.person, size: 60, color: AppColors.slate400),
                      ),
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: AppColors.slate600,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.white,
                                width: 2,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: AppColors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.namaLengkap ?? "Pengguna",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate800,
                  ),
                ),
                Text(
                  _getRoleDisplay(user?.role).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionHeader("Informasi Pribadi"),
                const SizedBox(height: 12),
                _buildProfileField(
                  label: "Nama Lengkap",
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                _buildProfileField(
                  label: "ID Tugas",
                  controller: _idTugasController,
                  icon: Icons.badge_outlined,
                  isReadOnly: true,
                ),
                _buildProfileField(
                  label: "Username",
                  controller: _usernameController,
                  icon: Icons.account_circle_outlined,
                  isReadOnly: true,
                ),
                _buildProfileField(
                  label: "Nomor Telepon",
                  controller: _phoneController,
                  icon: Icons.phone_android_outlined,
                  isNumber: true,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader("Informasi Jabatan"),
                const SizedBox(height: 12),
                _buildProfileField(
                  label: "Jabatan",
                  controller: _jabatanController,
                  icon: Icons.work_outline,
                  isReadOnly: true,
                ),
                _buildProfileField(
                  label: "Hak Akses",
                  controller: _roleController,
                  icon: Icons.security_outlined,
                  isReadOnly: true,
                ),
                const SizedBox(height: 40),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.greenPrimary,
                    ),
                  )
                else if (isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          text: "Batal",
                          color: AppColors.slate200,
                          textColor: AppColors.slate700,
                          icon: Icons.close,
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                              _nameController.text = user?.namaLengkap ?? '';
                              _phoneController.text = user?.noTelp ?? '';
                              _idTugasController.text = user?.idTugas ?? '';
                              _usernameController.text = user?.username ?? '';
                              _jabatanController.text = user?.jabatanDetail?.namaJabatan ?? user?.idJabatan.toString() ?? '';
                              _roleController.text = _getRoleDisplay(user?.role);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton(
                          text: "Simpan",
                          color: AppColors.greenPrimary,
                          textColor: AppColors.white,
                          icon: Icons.check,
                          onPressed: _saveProfile,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _buildButton(
                          text: "Edit Profil",
                          color: AppColors.white,
                          textColor: AppColors.greenPrimary,
                          icon: Icons.edit_outlined,
                          isOutlined: true,
                          onPressed: () => setState(() => isEditing = true),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: _buildButton(
                          text: "Logout",
                          color: AppColors.errorBg,
                          textColor: AppColors.errorText,
                          icon: Icons.logout,
                          onPressed: _handleLogout,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.slate500,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
    bool isReadOnly = false,
  }) {
    final bool isEnabled = isEditing && !isReadOnly;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.white : AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? AppColors.greenPrimary : AppColors.transparent,
          width: 1.5,
        ),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.greenPrimary.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        enabled: isEnabled,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          color: isReadOnly ? AppColors.slate500 : AppColors.slate800,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isEnabled ? AppColors.greenPrimary : AppColors.slate400,
          ),
          prefixIcon: Icon(
            icon,
            color: isEnabled ? AppColors.greenPrimary : AppColors.slate400,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required IconData icon,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : color,
        elevation: isOutlined ? 0 : 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined
              ? BorderSide(color: AppColors.greenPrimary, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}