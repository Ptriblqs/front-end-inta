import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart'; 

class AjukanDosenMenungguPage extends StatelessWidget {
  const AjukanDosenMenungguPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gambar ilustrasi
                Image.asset(
                  'assets/images/tunggu-image.png', 
                  height: 200,
                ),
                const SizedBox(height: 30),

                const Text(
                  "Sedang menunggu konfirmasi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                const Text(
                  "Pengajuan dosen pembimbing sedang diproses,\nHarap sabar sebentar ya!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // Tombol kembali ke beranda mahasiswa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F3E52),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // Navigasi ke beranda mahasiswa
                      Get.offAllNamed(Routes.home);
                    },
                    child: const Text(
                      "Kembali Ke Beranda",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
