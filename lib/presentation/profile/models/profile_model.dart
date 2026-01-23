class ProfileModel {
  final String fullName;
  final String nrp;
  final String position; // Jabatan
  final String location;
  final String imageUrl; // Untuk foto profil

  ProfileModel({
    required this.fullName,
    required this.nrp,
    required this.position,
    required this.location,
    this.imageUrl = '', 
  });
}