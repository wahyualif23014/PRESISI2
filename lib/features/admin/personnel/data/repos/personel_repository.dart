// import '../model/personel_model.dart'; // Sesuaikan path import model
// import '../model/role_enum.dart';      // Sesuaikan path import enum
// import '../model/unit_model.dart';     // Sesuaikan path import unit

// class PersonelRepository {
  
//   // Fungsi untuk mengambil data (Simulasi API)
//   List<Personel> getPersonelList() {
//     return [
//       Personel(
//         id: '1',
//         namaLengkap: 'IRJEN POL NANANG AVIANTO, M.Si.',
//         nrp: '012345689',
//         nomorHp: '0812-3456-7896',
//         pangkat: 'IRJEN POL',
//         jabatan: 'KAPOLDA',
//         role: UserRole.endUser,
//         unitKerja: UnitKerja(
//           id: 'polda_jatim',
//           nama: 'Polda Jawa Timur',
//         ),
//       ),

//       Personel(
//         id: '2',
//         namaLengkap: 'KOMBESPOL ARI WIBOWO, S.I.K., M.H.',
//         nrp: '20251235',
//         nomorHp: '0813-3316-1393',
//         pangkat: 'KOMBESPOL',
//         jabatan: 'KARO SDM',
//         role: UserRole.administrator,
//         unitKerja: UnitKerja(
//           id: 'polda_jatim',
//           nama: 'Polda Jawa Timur',
//         ),
//       ),

//       Personel(
//         id: '3',
//         namaLengkap: 'DIO VLADIKA',
//         nrp: '012345689',
//         nomorHp: '0812-3456-7896',
//         pangkat: 'BRIPDA',
//         jabatan: 'OPERATOR SDM',
//         role: UserRole.administrator,
//         unitKerja: UnitKerja(
//           id: 'polda_jatim',
//           nama: 'Polda Jawa Timur',
//         ),
//       ),

//       // ===== POLRESTABES SURABAYA =====
//       Personel(
//         id: '4',
//         namaLengkap: 'Bripda M. Fahmi Ardian Rahmat Fadhila',
//         nrp: 'operator2',
//         nomorHp: '0812-3669-1851',
//         pangkat: 'BRIPDA',
//         jabatan: 'Operator',
//         role: UserRole.operator,
//         unitKerja: UnitKerja(
//           id: 'polrestabes_surabaya',
//           nama: 'Polrestabes Surabaya',
//         ),
//       ),

//       Personel(
//         id: '5',
//         namaLengkap: 'Briptu M. Alip Musthofa, S.H.',
//         nrp: '99080662',
//         nomorHp: '0812-3669-1851',
//         pangkat: 'BRIPTU',
//         jabatan: '-',
//         role: UserRole.operator,
//         unitKerja: UnitKerja(
//           id: 'polrestabes_surabaya',
//           nama: 'Polrestabes Surabaya',
//         ),
//       ),

//       Personel(
//         id: '6',
//         namaLengkap: 'Bripka Eric Puspita Ady Krisna',
//         nrp: '90030177',
//         nomorHp: '0812-4986-1927',
//         pangkat: 'BRIPKA',
//         jabatan: '-',
//         role: UserRole.operator,
//         unitKerja: UnitKerja(
//           id: 'polrestabes_surabaya',
//           nama: 'Polrestabes Surabaya',
//         ),
//       ),

//       // ===== POLSEK PAKAL =====
//       Personel(
//         id: '7',
//         namaLengkap: 'AIPDA SOEDJARWO',
//         nrp: '79070796',
//         nomorHp: '0812-1749-1640',
//         pangkat: 'AIPDA',
//         jabatan: '-',
//         role: UserRole.operator,
//         unitKerja: UnitKerja(
//           id: 'polsek_pakal',
//           nama: 'Polsek Pakal, Polrestabes Surabaya',
//         ),
//       ),

//       Personel(
//         id: '8',
//         namaLengkap: 'AKP MULYA SUGIHARTO, S.I.K.',
//         nrp: '012345689',
//         nomorHp: '0812-3456-7896',
//         pangkat: 'AKP',
//         jabatan: 'KAPOLSEK',
//         role: UserRole.endUser,
//         unitKerja: UnitKerja(
//           id: 'polsek_pakal',
//           nama: 'Polsek Pakal, Polrestabes Surabaya',
//         ),
//       ),
//     ];
//   }
// }