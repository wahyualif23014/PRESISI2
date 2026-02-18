// import 'role_enum.dart';
// import 'unit_model.dart';

// class UserModel {
//   final int id;
//   final String namaLengkap;
//   final String nrp;
//   final String noTelp;
//   final String idTugas; // Kode Tingkat
//   final UserRole role;
  
//   // Nested Objects dari Preload GORM
//   final JabatanModel? jabatanDetail;
//   final UnitModel? tingkatDetail;

//   UserModel({
//     required this.id,
//     required this.namaLengkap,
//     required this.nrp,
//     required this.noTelp,
//     required this.idTugas,
//     required this.role,
//     this.jabatanDetail,
//     this.tingkatDetail,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'] ?? 0,
//       namaLengkap: json['nama_lengkap'] ?? '',
//       nrp: json['nrp'] ?? '', // Sesuai tag json:"nrp" di Go
//       noTelp: json['no_telp'] ?? '',
//       idTugas: json['id_tugas'] ?? '',
//       role: UserRoleX.fromString(json['role'] ?? '3'),
      
//       // Parsing Nested Object Jabatan
//       jabatanDetail: json['jabatan_detail'] != null 
//           ? JabatanModel.fromJson(json['jabatan_detail']) 
//           : null,
      
//       // Parsing Nested Object Tingkat
//       tingkatDetail: json['tingkat_detail'] != null 
//           ? UnitModel.fromJson(json['tingkat_detail']) 
//           : null,
//     );
//   }

//   // Digunakan untuk Payload POST/PUT ke Backend
//   Map<String, dynamic> toJson() {
//     return {
//       "nama_lengkap": namaLengkap,
//       "username": nrp, // Backend CreateUserInput minta 'username'
//       "no_telp": noTelp,
//       "id_tugas": idTugas,
//       "role": role.value,
//       "id_jabatan": jabatanDetail?.id,
//     };
//   }
// }