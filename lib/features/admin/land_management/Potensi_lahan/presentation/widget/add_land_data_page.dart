import 'package:flutter/material.dart';

class AddLandDataPage extends StatefulWidget {
  const AddLandDataPage({super.key});

  @override
  State<AddLandDataPage> createState() => _AddLandDataPageState();
}

class _AddLandDataPageState extends State<AddLandDataPage> {
  // ==========================================
  // 1. CONTROLLERS
  // ==========================================
  final TextEditingController _resorController = TextEditingController();
  final TextEditingController _sektorController = TextEditingController();
  final TextEditingController _jenisLahanController = TextEditingController();
  final TextEditingController _polisiPenggerakController = TextEditingController();
  final TextEditingController _kontakPenggerakController = TextEditingController();
  final TextEditingController _penanggungJawabController = TextEditingController();
  final TextEditingController _kontakPJController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  
  // Statistik
  final TextEditingController _jmlPoktanController = TextEditingController();
  final TextEditingController _luasLahanController = TextEditingController();
  final TextEditingController _jmlPetaniController = TextEditingController();
  final TextEditingController _komoditiController = TextEditingController();
  
  // Alamat & Lokasi
  final TextEditingController _alamat1Controller = TextEditingController();
  final TextEditingController _alamat2Controller = TextEditingController();
  final TextEditingController _alamat3Controller = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  
  final TextEditingController _keteranganLainController = TextEditingController();

  @override
  void dispose() {
    _resorController.dispose();
    _sektorController.dispose();
    _jenisLahanController.dispose();
    _polisiPenggerakController.dispose();
    _kontakPenggerakController.dispose();
    _penanggungJawabController.dispose();
    _kontakPJController.dispose();
    _keteranganController.dispose();
    _jmlPoktanController.dispose();
    _luasLahanController.dispose();
    _jmlPetaniController.dispose();
    _komoditiController.dispose();
    _alamat1Controller.dispose();
    _alamat2Controller.dispose();
    _alamat3Controller.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _keteranganLainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF5), 
      // AppBar dihapus sesuai permintaan
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Container Form Utama
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0), // Padding dalam diperbesar agar lega
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Form (Opsional, agar user tahu ini halaman apa)
                    const Text(
                      "Formulir Data Lahan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(thickness: 1.5, height: 30),

                    // 1. DATA UMUM
                    _buildSectionTitle("Data Umum"),
                    _buildDataUmum(),
                    const SizedBox(height: 20),

                    // 2. PERSONEL & KONTAK
                    _buildSectionTitle("Personel & Kontak"),
                    _buildPersonelData(),
                    const SizedBox(height: 20),

                    // 3. STATISTIK & KOMODITI
                    _buildSectionTitle("Statistik & Komoditi"),
                    _buildStatistikData(),
                    const SizedBox(height: 20),

                    // 4. LOKASI & PETA
                    _buildSectionTitle("Lokasi Lahan"),
                    _buildLokasiData(),
                    const SizedBox(height: 20),

                    // 5. DOKUMENTASI & LAINNYA
                    _buildSectionTitle("Dokumentasi"),
                    _buildDokumentasi(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Tombol Aksi (Tetap di bawah)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFE8EFF5),
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: "Batal",
                icon: Icons.close,
                color: const Color(0xFFEA4335),
                onTap: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                label: "Simpan",
                icon: Icons.save,
                color: const Color(0xFF00C853),
                onTap: () {
                  // TODO: Logic Simpan
                  print("Simpan Data");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION BUILDERS (Agar Code Rapi)
  // ==========================================

  Widget _buildDataUmum() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLabelAndInput("Kepolisian Resor", _resorController)),
            const SizedBox(width: 12),
            Expanded(child: _buildLabelAndInput("Kepolisian Sektor", _sektorController)),
          ],
        ),
        const SizedBox(height: 12),
        _buildLabelAndInput("Jenis Lahan", _jenisLahanController),
      ],
    );
  }

  Widget _buildPersonelData() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: _buildLabelAndInput("Polisi Penggerak", _polisiPenggerakController)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _buildLabelAndInput("Kontak", _kontakPenggerakController, inputType: TextInputType.phone)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(flex: 3, child: _buildLabelAndInput("Penanggung Jawab", _penanggungJawabController)),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _buildLabelAndInput("Kontak", _kontakPJController, inputType: TextInputType.phone)),
          ],
        ),
        const SizedBox(height: 12),
        _buildLabelAndInput("Keterangan", _keteranganController),
      ],
    );
  }

  Widget _buildStatistikData() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildLabelAndInput("JML. Poktan", _jmlPoktanController, inputType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _buildLabelAndInput("Luas (HA)", _luasLahanController, inputType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _buildLabelAndInput("JML Petani", _jmlPetaniController, inputType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 12),
        _buildLabelAndInput("Komoditi", _komoditiController),
      ],
    );
  }

  Widget _buildLokasiData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleTextField(_alamat1Controller, hint: "Alamat Jalan/Gedung"),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSimpleTextField(_alamat2Controller, hint: "RT/RW/Kelurahan")),
            const SizedBox(width: 8),
            Expanded(child: _buildSimpleTextField(_alamat3Controller, hint: "Kecamatan/Kota")),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLabelAndInput("LATITUDE", _latitudeController)),
            const SizedBox(width: 12),
            Expanded(child: _buildLabelAndInput("LONGITUDE", _longitudeController)),
          ],
        ),
        const SizedBox(height: 12),
        // Map Placeholder
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: NetworkImage("https://mt1.google.com/vt/lyrs=m&x=1325&y=3143&z=13"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(Icons.location_on, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDokumentasi() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            print("Upload foto ditekan");
          },
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.black54, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_a_photo, size: 32, color: Colors.black54),
                SizedBox(height: 8),
                Text("Tap untuk Upload Foto", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildLabelAndInput("Keterangan Lain", _keteranganLainController, maxLines: 3),
      ],
    );
  }

  // ==========================================
  // HELPER WIDGETS KECIL
  // ==========================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF0097B2), // Warna aksen cyan/biru
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLabelAndInput(String label, TextEditingController controller, {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        _buildSimpleTextField(controller, maxLines: maxLines, inputType: inputType),
      ],
    );
  }

  Widget _buildSimpleTextField(TextEditingController controller, {int maxLines = 1, TextInputType inputType = TextInputType.text, String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8), // Abu-abu sangat muda agar kontras dengan kotak putih
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.normal, fontSize: 13),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }
}