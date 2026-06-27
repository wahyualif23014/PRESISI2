import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:KETAHANANPANGAN/core/theme/app_colors.dart';

class CustomErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final bool isNetworkError;

  const CustomErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.isNetworkError = false,
  });

  @override
  State<CustomErrorDialog> createState() => _CustomErrorDialogState();
}

class _CustomErrorDialogState extends State<CustomErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Lottie Animation URLs
  static const String _noInternetLottie =
      'https://lottie.host/5a0c64df-9e2b-4b2a-8742-83b6f00ab38b/44k0qTymR8.json';
  static const String _errorLottie =
      'https://lottie.host/801a2386-db83-485a-8b89-21666ffc2e0b/9B12iXg81J.json';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String lottieUrl =
        widget.isNetworkError ? _noInternetLottie : _errorLottie;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation / Fallback Section
            Container(
              height: 140,
              width: 140,
              alignment: Alignment.center,
              child: Lottie.network(
                lottieUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback offline widget yang estetik dan beranimasi
                  return ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.isNetworkError
                            ? AppColors.warningBg
                            : AppColors.errorBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isNetworkError
                            ? Icons.wifi_off_rounded
                            : Icons.error_outline_rounded,
                        size: 64,
                        color: widget.isNetworkError
                            ? AppColors.warning
                            : AppColors.error,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.slate900,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.slate600,
                height: 1.5,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isNetworkError
                      ? AppColors.warning
                      : AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function untuk memanggil dialog secara instan
void showCustomErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  bool isNetworkError = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return CustomErrorDialog(
        title: title,
        message: message,
        isNetworkError: isNetworkError,
      );
    },
  );
}
