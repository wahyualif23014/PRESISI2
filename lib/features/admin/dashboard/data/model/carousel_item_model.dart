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
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQSBmBQ6PnbfbWgg3qD7rWH7scRIY8TN8welw&s', // Gambar ladang hijau
    title: 'Lahan Subur',
    subtitle: 'Optimalkan potensi tanah',
  ),
  CarouselItemModel(
    id: '3',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTlaIYRdTy7qJ7JHBL1ftRiPq3zYQ_3qVfhhw&s', // Gambar teknologi tani
    title: 'Teknologi Tani',
    subtitle: 'Modernisasi alat pertanian',
  ),
];