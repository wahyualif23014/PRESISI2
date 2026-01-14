// features/dashboard/presentation/widgets/carousel.dart

import 'package:flutter/material.dart';
import 'package:widget_slider/widget_slider.dart';
import '../../data/model/carousel_item_model.dart'; // Import Model

class PromoCarousel extends StatefulWidget {
  final List<CarouselItemModel> items; 
  final Function(CarouselItemModel)? onTap;

  const PromoCarousel({
    Key? key,
    required this.items,
    this.onTap,
  }) : super(key: key);

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final controller = SliderController(duration: const Duration(milliseconds: 600));

  @override
  Widget build(BuildContext context) {
    return WidgetSlider(
      fixedSize: 320,
      aspectRatio: 1.5,
      controller: controller,
      itemCount: widget.items.length,
      proximity: 0.7,
      itemBuilder: (context, index, activeIndex) {
        final item = widget.items[index];
        final isActive = index == activeIndex;

        return GestureDetector(
          onTap: () => widget.onTap?.call(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isActive ? 0.2 : 0.05),
                  blurRadius: isActive ? 15 : 5,
                  offset: const Offset(0, 8),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(item.imageUrl),
                fit: BoxFit.cover,
                colorFilter: isActive 
                    ? null 
                    : ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.6, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}