import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/personel_model.dart';
import '../data/services/personel_services.dart';

// Service Dependency Injection
final personelServiceProvider = Provider((ref) => PersonelService());


final personelGroupedProvider = Provider.autoDispose<AsyncValue<Map<String, List<Personel>>>>((ref) {
  return ref.watch(personelProvider).whenData((list) {
    final Map<String, List<Personel>> grouped = {};
    for (final p in list) {
      (grouped[p.unitKerja.nama] ??= []).add(p);
    }
    return grouped;
  });
});

// State Manager utama (List Mentah)
final personelProvider = AsyncNotifierProvider<PersonelNotifier, List<Personel>>(
  PersonelNotifier.new,
);

class PersonelNotifier extends AsyncNotifier<List<Personel>> {
  // Helper getter agar code lebih bersih
  PersonelService get _service => ref.read(personelServiceProvider);

  @override
  Future<List<Personel>> build() async {
    return _service.getAllPersonel();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.getAllPersonel());
  }

  Future<void> search(String keyword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.searchPersonel(keyword));
  }

  Future<void> delete(String id) async {
    await _service.deletePersonel(id);
    await refresh();
  }

  Future<void> add(Personel personel) async {
    await _service.addPersonel(personel);
    await refresh();
  }

  Future<void> updatePersonel(Personel personel) async {
    await _service.updatePersonel(personel);
    await refresh();
  }
}