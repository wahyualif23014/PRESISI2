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
    _pageController = PageController(viewportFraction: 0.95, initialPage: 0);

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
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
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
                        child: child,
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
        const SizedBox(height: 14),
        _buildIndicator(),
        const SizedBox(height: 6),
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
          width: _currentPage == index ? 26 : 6,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.25),
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

  const _CarouselBannerItem({
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.18 : 0.08),
            blurRadius: isActive ? 30 : 18,
            spreadRadius: -6,
            offset: Offset(0, isActive ? 14 : 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                frameBuilder: (
                  context,
                  child,
                  frame,
                  wasSynchronouslyLoaded,
                ) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF111827),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 40,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.55, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
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