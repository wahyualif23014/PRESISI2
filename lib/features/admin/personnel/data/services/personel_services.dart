import '../model/personel_model.dart';

class PersonelService {
  final List<Personel> _source = Personel.dummyList;

  // GET ALL PERSONEL
  Future<List<Personel>> getAllPersonel() async {
    // simulasi delay network
    await Future.delayed(const Duration(milliseconds: 300));
    return _source;
  }

  // SEARCH PERSONEL
  Future<List<Personel>> searchPersonel(String keyword) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (keyword.isEmpty) return _source;

    final query = keyword.toLowerCase();

    return _source.where((p) {
      return p.namaLengkap.toLowerCase().contains(query) ||
          p.nrp.toLowerCase().contains(query) ||
          p.unitKerja.nama.toLowerCase().contains(query);
    }).toList();
  }

  // FILTER BY UNIT KERJA
  Future<List<Personel>> filterByUnit(String unitId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _source
        .where((p) => p.unitKerja.id == unitId)
        .toList();
  }

  // ADD PERSONEL (DUMMY)
  Future<void> addPersonel(Personel personel) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _source.add(personel);
  }

  // UPDATE PERSONEL (DUMMY)
  Future<void> updatePersonel(Personel personel) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _source.indexWhere((p) => p.id == personel.id);
    if (index != -1) {
      _source[index] = personel;
    }
  }

  // DELETE PERSONEL (DUMMY)
  Future<void> deletePersonel(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _source.removeWhere((p) => p.id == id);
  }
}
