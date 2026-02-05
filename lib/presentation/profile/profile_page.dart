import 'package:KETAHANANPANGAN/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../auth/provider/auth_provider.dart';

// Pastikan import file AppColors Anda. 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- 1. Variabel State ---
  bool isEditing = false;
  bool isLoading = false;

  // --- 2. Controllers ---
  late TextEditingController _nameController;
  late TextEditingController _nrpController;
  late TextEditingController _jabatanController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;

    _nameController = TextEditingController(text: user?.namaLengkap ?? '');
    _nrpController = TextEditingController(text: user?.nrp ?? '');
    _jabatanController = TextEditingController(text: user?.jabatan ?? '');
    _roleController = TextEditingController(text: user?.role ?? '');
    _phoneController = TextEditingController(text: user?.noTelp ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nrpController.dispose();
    _jabatanController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- 3. Logic Functions ---

  void _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);
    
    // Simulasi delay request API
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
        final user = auth.user;

        return Scaffold(
          backgroundColor: AppColors.slate50, // Background utama bersih
          
          // --- APP BAR PROFESIONAL ---
          appBar: AppBar(
            backgroundColor: AppColors.slate800,
            elevation: 0,
            centerTitle: true,
            title: Text(
              isEditing ? "Edit Profil" : "Profil Saya",
              style: const TextStyle(
                fontWeight: FontWeight.w600, 
                color: AppColors.white,
                letterSpacing: 0.5
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.white),
              onPressed: () {
                // Logic Back yang Aman
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
                // --- 1. HEADER PROFILE (AVATAR) ---
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
                          image: (user?.fotoProfil != null && user!.fotoProfil!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(user.fotoProfil!),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: (user?.fotoProfil == null || user!.fotoProfil!.isEmpty)
                            ? const Icon(Icons.person, size: 60, color: AppColors.slate400)
                            : null,
                      ),
                      
                      // Edit Badge Camera
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
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt, size: 18, color: AppColors.white),
                              onPressed: () {
                                // TODO: Logic Upload Foto
                              },
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
                  user?.role?.toUpperCase() ?? "VIEWER",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenPrimary,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 32),

                // --- 2. FORM DATA ---
                _buildSectionHeader("Informasi Pribadi"),
                const SizedBox(height: 12),
                
                _buildProfileField(
                  label: "Nama Lengkap",
                  controller: _nameController,
                  icon: Icons.person_outline,
                ),
                _buildProfileField(
                  label: "Nomor NRP",
                  controller: _nrpController,
                  icon: Icons.badge_outlined,
                  isNumber: true,
                  isReadOnly: true, // NRP tidak boleh diedit sembarangan
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
                ),
                _buildProfileField(
                  label: "Akses Role",
                  controller: _roleController,
                  icon: Icons.security_outlined,
                  isReadOnly: true,
                ),

                const SizedBox(height: 40),

                // --- 3. ACTION BUTTONS ---
                if (isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary))
                else if (isEditing)
                  // MODE EDIT: Batal & Simpan
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
                              // Reset values
                              _nameController.text = user?.namaLengkap ?? '';
                              _phoneController.text = user?.noTelp ?? '';
                              _jabatanController.text = user?.jabatan ?? '';
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
                  // MODE VIEW: Logout & Edit
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

  // --- WIDGET HELPER UI ---

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
          width: 1.5
        ),
        boxShadow: isEnabled 
          ? [BoxShadow(color: AppColors.greenPrimary.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          side: isOutlined ? BorderSide(color: AppColors.greenPrimary, width: 2) : BorderSide.none,
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

