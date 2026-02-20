import 'package:flutter/material.dart';

class PrintSuccessDialog extends StatelessWidget {
  final String fileName;
  final VoidCallback onPrintTap;

  const PrintSuccessDialog({
    Key? key,
    required this.fileName,
    required this.onPrintTap,
  }) : super(key: key);

  // Helper static method untuk memanggil dialog lebih ringkas
  static void show(BuildContext context, {required String fileName, required VoidCallback onPrintTap}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: PrintSuccessDialog(
            fileName: fileName,
            onPrintTap: onPrintTap,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.picture_as_pdf_outlined, size: 70, color: Color(0xFF2F80ED)),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onPrintTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified, color: Color(0xFF00C853), size: 20),
                SizedBox(width: 6),
                Text(
                  "File Berhasil Terunduh",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2F80ED),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}