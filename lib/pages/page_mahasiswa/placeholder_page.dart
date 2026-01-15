import 'package:flutter/material.dart';

class PlaceholderPage extends StatelessWidget {
  final String title; // Judul header
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di MainMahasiswaPage tetap muncul, jadi bisa kosong di sini
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.hourglass_empty,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                "Belum tersedia",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
