import 'package:flutter/material.dart';
import 'package:sdmapp/presentation/profile/repos/profile_repository.dart';
import 'models/profile_model.dart'; // Sesuaikan path import

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 1. Variabel State
  late ProfileModel profile;
  final ProfileRepository _repo = ProfileRepository();
  bool isEditing = false; // Penanda mode edit
  bool isLoading = false; // Penanda loading saat simpan

  // 2. Controllers untuk Input Text
  late TextEditingController _nameController;
  late TextEditingController _nrpController;
  late TextEditingController _positionController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    // Load data awal
    profile = _repo.getProfileData();
    
    // Inisialisasi controller dengan data awal
    _nameController = TextEditingController(text: profile.fullName);
    _nrpController = TextEditingController(text: profile.nrp);
    _positionController = TextEditingController(text: profile.position);
    _locationController = TextEditingController(text: profile.location);
  }

  @override
  void dispose() {
    // Wajib dispose controller agar tidak memory leak
    _nameController.dispose();
    _nrpController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 3. Fungsi untuk Menyimpan Data
  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    // Buat object model baru dari inputan user
    final newProfile = ProfileModel(
      fullName: _nameController.text,
      nrp: _nrpController.text,
      position: _positionController.text,
      location: _locationController.text,
      imageUrl: profile.imageUrl, // Gambar dianggap tetap dulu
    );

    // Panggil Repository
    final success = await _repo.updateProfileData(newProfile);

    if (success) {
      if (!mounted) return;
      setState(() {
        profile = newProfile; // Update data tampilan utama
        isEditing = false;    // Kembali ke mode lihat
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D2730),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          isEditing ? "Edit Profile" : "MY Profile", // Judul berubah dinamis
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Profile Personel",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),

            // --- AVATAR SECTION ---
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    shape: BoxShape.circle,
                    image: profile.imageUrl.isNotEmpty
                        ? DecorationImage(image: AssetImage(profile.imageUrl))
                        : null,
                  ),
                  child: profile.imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 80, color: Colors.white)
                      : null,
                ),
                // Icon upload hanya muncul/bisa diklik jika sedang edit (opsional)
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                         // Logika ganti foto
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.blue),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              profile.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 30),

            // --- FORM FIELDS (Pass Controller ke Helper) ---
            _buildInfoTile("Nama Lengkap", _nameController),
            _buildInfoTile("NRP", _nrpController, isNumber: true),
            _buildInfoTile("Jabatan", _positionController),
            _buildInfoTile("Lokasi", _locationController),

            const SizedBox(height: 20),

            // --- BUTTONS LOGIC ---
            if (isLoading)
              const CircularProgressIndicator()
            else if (isEditing)
              // TAMPILAN SAAT EDIT (Tombol Batal & Simpan)
              Row(
                children: [
                   Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                          // Reset controller ke data asli jika batal
                          _nameController.text = profile.fullName;
                          _nrpController.text = profile.nrp;
                          _positionController.text = profile.position;
                          _locationController.text = profile.location;
                        });
                      },
                      child: const Text("Batal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _saveProfile,
                      child: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else
              // TAMPILAN SAAT VIEW (Tombol Logout & Update)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        // Logic Logout
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          isEditing = true; // Aktifkan mode edit
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Update Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGET DINAMIS ---
  // Sekarang menerima TextEditingController
  Widget _buildInfoTile(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          // Jika editing, padding diatur oleh TextFormField, jika tidak pakai padding container
          padding: isEditing ? const EdgeInsets.symmetric(horizontal: 16) : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isEditing ? Border.all(color: Colors.blueAccent, width: 1.5) : null, // Highlight saat edit
          ),
          child: isEditing
              ? TextFormField(
                  controller: controller,
                  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                  decoration: const InputDecoration(
                    border: InputBorder.none, // Hilangkan garis default input
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.text, // Tampilkan text dari controller/data
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const Icon(Icons.lock_outline, size: 16, color: Colors.grey), // Indikator read-only
                  ],
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}