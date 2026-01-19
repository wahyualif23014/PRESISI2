import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/model/carousel_item_model.dart';

class PromoCarousel extends StatefulWidget {
  final List<CarouselItemModel> items;
  final ValueChanged<CarouselItemModel>? onTap;

  const PromoCarousel({super.key, required this.items, this.onTap});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.93, initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.items.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double bannerHeight = width < 600 ? width * 0.6 : 450;

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => widget.onTap?.call(widget.items[index]),
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = index - _pageController.page!;
                    } else {
                      value = (index - _currentPage).toDouble();
                    }

                    value = (1 - (value.abs() * 0.05)).clamp(0.0, 1.0);

                    return Center(
                      child: Transform.scale(
                        scale: Curves.easeOutCubic.transform(value),
                        child: Opacity(
                          opacity: Curves.easeIn
                              .transform(value)
                              .clamp(0.6, 1.0),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _CarouselBannerItem(
                    item: widget.items[index],
                    isActive: index == _currentPage,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: _currentPage == index ? 24 : 6,
          decoration: BoxDecoration(
            color:
                _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _CarouselBannerItem extends StatelessWidget {
  final CarouselItemModel item;
  final bool isActive;

  const _CarouselBannerItem({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          28,
        ), // Border radius lebih besar untuk kesan premium
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.2 : 0.05),
            blurRadius: isActive ? 30 : 15,
            offset: Offset(0, isActive ? 15 : 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
              ),
            ),

            // 2. Gradient Overlay (Lebih dalam untuk banner besar)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.4, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Konten Teks (Font diperbesar agar seimbang dengan ukuran widget)
            Positioned(
              left: 28,
              bottom: 20,
              right: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20, // Ukuran Title diperbesar
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12, // Ukuran Subtitle diperbesar
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
