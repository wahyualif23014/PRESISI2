import '../model/personel_model.dart';
import '../repos/personel_repository.dart'; // Import Repository

class PersonelService {
  // 1. Inisialisasi Repository
  final PersonelRepository _repository = PersonelRepository();

  List<Personel> _localData = [];

  PersonelService() {
    _localData = _repository.getPersonelList();
  }


  // GET ALL PERSONEL
  Future<List<Personel>> getAllPersonel() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _localData;
  }

  // SEARCH PERSONEL
  Future<List<Personel>> searchPersonel(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (keyword.isEmpty) return _localData;

    final query = keyword.toLowerCase();

    // Filter dari _localData
    return _localData.where((p) {
      return p.namaLengkap.toLowerCase().contains(query) ||
          p.nrp.toLowerCase().contains(query) ||
          p.unitKerja.nama.toLowerCase().contains(query);
    }).toList();
  }

  // FILTER BY UNIT KERJA
  Future<List<Personel>> filterByUnit(String unitId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Filter dari _localData
    return _localData
        .where((p) => p.unitKerja.id == unitId)
        .toList();
  }

  // ADD PERSONEL
  Future<void> addPersonel(Personel personel) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Tambahkan ke _localData
    _localData.add(personel);
  }

  // UPDATE PERSONEL
  Future<void> updatePersonel(Personel personel) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _localData.indexWhere((p) => p.id == personel.id);
    if (index != -1) {
      _localData[index] = personel;
    }
  }

  // DELETE PERSONEL
  Future<void> deletePersonel(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _localData.removeWhere((p) => p.id == id);
  }
}