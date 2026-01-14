import 'package:flutter/material.dart';

class KelolaLahan extends StatelessWidget {
  const KelolaLahan({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Halaman Data Lahan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
