import 'package:flutter/material.dart';
import '../models/notification_model.dart'; // Sesuaikan path

class NotificationItemWidget extends StatefulWidget {
  final NotificationModel item;
  final VoidCallback onRemove;

  const NotificationItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<NotificationItemWidget> {
  bool _isExpanded = false; // State untuk cek apakah sedang melebar

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        widget.onRemove(); 
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: GestureDetector(
        // 2. Logika Expand ketika ditekan
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Animasi halus
          color: Colors.transparent, 
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- LOGO SECTION ---
              _buildLogoSection(),
              
              const SizedBox(width: 12),

              // --- TEXT SECTION (Expandable) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.body,
                      maxLines: _isExpanded ? null : 2, // null artinya unlimited
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    if (!_isExpanded && widget.item.body.length > 50)
                      const Text(
                        "Selengkapnya...",
                        style: TextStyle(fontSize: 10, color: Colors.blue),
                      )
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // --- ACTION & TIME ---
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1D2730), width: 2),
            color: Colors.white,
          ),
          child: const Center(
            child: Icon(Icons.security, size: 30, color: Colors.orange),
          ),
        ),
        if (widget.item.badgeCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.item.badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Tombol hapus manual (opsional, karena sudah ada swipe)
        InkWell(
          onTap: widget.onRemove,
          child: const Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: 26,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.item.time,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}