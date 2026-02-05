import 'package:KETAHANANPANGAN/features/admin/personnel/data/model/personel_model.dart';
import 'package:KETAHANANPANGAN/features/admin/personnel/data/services/personel_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider Service (Dependency Injection)
final personelServiceProvider = Provider<PersonelService>((ref) {
  return PersonelService();
});

// 2. State Manager Utama (Notifier)
final personelProvider = AsyncNotifierProvider<PersonelNotifier, List<Personel>>(
  PersonelNotifier.new,
);

class PersonelNotifier extends AsyncNotifier<List<Personel>> {
  // Getter Service
  PersonelService get _service => ref.read(personelServiceProvider);

  // List cadangan untuk fitur search client-side
  List<Personel> _fullList = [];

  @override
  Future<List<Personel>> build() async {
    final data = await _service.getAllPersonel();
    _fullList = data; // Simpan copy data lengkap
    return data;
  }

  // --- ACTIONS ---

  Future<void> refresh() async {
    state = const AsyncLoading();
    // Fetch ulang dari server
    state = await AsyncValue.guard(() async {
      final data = await _service.getAllPersonel();
      _fullList = data; // Update cadangan
      return data;
    });
  }

  // Search Logic (Client Side)
  void search(String keyword) {
    if (state.value == null) return;

    if (keyword.isEmpty) {
      // Jika search kosong, kembalikan list penuh
      state = AsyncData(_fullList);
    } else {
      final query = keyword.toLowerCase();
      final filtered = _fullList.where((p) {
        return p.namaLengkap.toLowerCase().contains(query) ||
               p.nrp.toLowerCase().contains(query) ||
               p.jabatan.toLowerCase().contains(query);
      }).toList();
      state = AsyncData(filtered);
    }
  }

  Future<void> add(Personel personel, String password) async {
    // Panggil API Add
    await _service.addPersonel(personel, password);
    // Refresh list setelah sukses
    await refresh(); 
  }

  Future<void> updatePersonel(Personel personel) async {
    // Panggil API Update
    await _service.updatePersonel(personel);
    // Refresh list setelah sukses
    await refresh();
  }

  Future<void> delete(int id) async {
    // Panggil API Delete
    await _service.deletePersonel(id);
    await refresh();
  }
}