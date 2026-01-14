import 'package:flutter/material.dart';

class Datarecap extends StatelessWidget {
  const Datarecap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Halaman Data Rekapitulasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
