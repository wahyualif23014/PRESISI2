import 'package:KETAHANANPANGAN/core/theme/app_colors.dart' show AppColors;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/data/model/land_potential_model.dart' show LandPotentialModel;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/contact_info_section.dart' show ContactInfoSection;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/documentation_section.dart' show DocumentationSection;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/land_detail_section.dart' show LandDetailSection;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/loading_view.dart' show LoadingView;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/mapPicker.dart' show MapPickerPage;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/police_info_section.dart' show PoliceInfoSection;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/statistics_address_section.dart' show StatisticsAddressSection;
import 'package:KETAHANANPANGAN/features/admin/land_management/Potensi_lahan/presentation/widget/common/success_page.dart' show SuccessPage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../data/service/land_potential_service.dart';
import '../../controller/add_land_controller.dart';

class AddLandPage extends StatelessWidget {
  final LandPotentialModel? editData;

  const AddLandPage({super.key, this.editData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddLandController(
        service: LandPotentialService(),
        editData: editData,
      ),
      child: const _AddLandView(),
    );
  }
}

class _AddLandView extends StatelessWidget {
  const _AddLandView();

  @override
  Widget build(BuildContext context) {
    // watch digunakan untuk rebuild UI saat notifyListeners() dipanggil di controller
    final controller = context.watch<AddLandController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          controller.isEditMode ? "Edit Data Lahan" : "Tambah Data Lahan",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: controller.isDataLoading
          ? const LoadingView()
          : SafeArea(
              child: Form(
                key: controller.formKey,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(controller)),
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          PoliceInfoSection(controller: controller),
                          const SizedBox(height: 20),
                          LandDetailSection(controller: controller),
                          const SizedBox(height: 20),
                          ContactInfoSection(controller: controller),
                          const SizedBox(height: 20),
                          StatisticsAddressSection(
                            controller: controller,
                            onMapTap: () => _openMapPicker(context),
                            onGpsTap: () => _getCurrentLocation(context),
                          ),
                          const SizedBox(height: 20),
                          DocumentationSection(
                            controller: controller,
                            onCameraTap: () => _pickImage(context, ImageSource.camera),
                            onGalleryTap: () => _pickImage(context, ImageSource.gallery),
                          ),
                          const SizedBox(height: 30),
                          _buildActionButtons(context),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(AddLandController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.forestGreen,
            AppColors.forestGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.isEditMode ? Icons.edit_document : Icons.add_location_alt,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isEditMode ? 'Mode Edit Data' : 'Input Data Baru',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isEditMode 
                          ? 'Perbarui informasi lahan yang sudah ada'
                          : 'Tambahkan data potensi lahan baru',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // read digunakan di dalam callback agar tidak terjadi unnecessary rebuild
    final controller = context.read<AddLandController>();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.slateGrey,
              side: BorderSide(color: AppColors.slateGrey.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'BATAL',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: controller.isSaving ? null : () => _handleSave(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: AppColors.forestGreen.withOpacity(0.4),
            ),
            child: controller.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text(
                    'SIMPAN DATA',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // --- LOGIC HANDLERS ---

  Future<void> _handleSave(BuildContext context) async {
    final controller = context.read<AddLandController>();

    // Validasi gambar manual (opsional, tergantung policy aplikasi)
    if (!controller.validateImage()) {
      _showErrorSnackBar(context, 'Silakan tambahkan foto lahan terlebih dahulu');
      return;
    }

    final success = await controller.saveData();

    if (success && context.mounted) {
      _showSuccessSnackBar(context, 'Data berhasil disimpan');
      _navigateToSuccessPage(context);
    } else if (context.mounted) {
      _showErrorSnackBar(context, 'Gagal menyimpan data ke server');
    }
  }

  void _navigateToSuccessPage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SuccessPage()),
      (route) => false,
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      await context.read<AddLandController>().pickImage(source);
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Gagal mengakses kamera/galeri: $e');
      }
    }
  }

  Future<void> _openMapPicker(BuildContext context) async {
    final controller = context.read<AddLandController>();
    
    // Pastikan Anda sudah membuat widget MapPickerPage sebelumnya
    // Titik awal diambil dari koordinat yang sudah ada atau default Surabaya
    final LatLng? result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (c) => MapPickerPage(
          initialLocation: controller.selectedLocation ?? LatLng(-7.2504, 112.7688),
        ),
        fullscreenDialog: true,
      ),
    );

    if (result != null && context.mounted) {
      controller.setLocation(result, controller.alamatController.text);
      _showSuccessSnackBar(context, 'Titik koordinat berhasil diperbarui');
    }
  }

  Future<void> _getCurrentLocation(BuildContext context) async {
    final controller = context.read<AddLandController>();
    await controller.getCurrentLocation();
    
    if (context.mounted) {
      if (controller.hasLocation) {
        _showSuccessSnackBar(context, 'Lokasi GPS berhasil didapatkan');
      } else {
        _showErrorSnackBar(context, 'Gagal mendapatkan lokasi GPS. Pastikan GPS aktif.');
      }
    }
  }

  // --- FEEDBACK WIDGETS ---

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}