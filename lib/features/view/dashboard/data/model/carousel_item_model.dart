// features/dashboard/data/model/carousel_item_model.dart

class CarouselItemModel {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;

  CarouselItemModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
}

// --- DUMMY DATA ---
final List<CarouselItemModel> dummyCarouselData = [
  CarouselItemModel(
    id: '1',
    imageUrl: 'https://images.unsplash.com/photo-1538115081112-32c7d8401807?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8cG9scml8ZW58MHx8MHx8fDA%3D', // Gambar sawah/pertanian
    title: 'Panen Raya',
    subtitle: 'Hasil melimpah musim ini',
  ),
  CarouselItemModel(
    id: '2',
    imageUrl: 'https://www.suaramuhammadiyah.id/storage/posts/image/Polda_Jatim_dan_UMM-20241004134811.jpeg', // Gambar ladang hijau
    title: 'Lahan Subur',
    subtitle: 'Optimalkan potensi tanah',
  ),
  CarouselItemModel(
    id: '3',
    imageUrl: 'https://memorandum.disway.id/upload/740da7d86f13e02e4c17e6a89756364f.jpeg', // Gambar teknologi tani
    title: 'Teknologi Tani',
    subtitle: 'Modernisasi alat pertanian',
  ),
  CarouselItemModel(
    id: '4',
    imageUrl: 'https://cdn.antaranews.com/cache/1200x800/2023/08/01/IMG-20230801-WA0082_1.jpg', // Gambar teknologi tani
    title: 'SDM Polda',
    subtitle: 'Melakukan pengawasan dalam genggaman',
  ),
];