import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ajukan_dosen_menunggu_page.dart';

class AjukanDosenTerkirimPage extends StatelessWidget {
  const AjukanDosenTerkirimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/kirim-image.png',
                  height: 200,
                ),
                const SizedBox(height: 30),

                const Text(
                  "TERKIRIM",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Permintaan pengajuan dosen pembimbing mu sudah terkirim",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // langsung navigasi ke halaman menunggu
                      Get.to(() => const AjukanDosenMenungguPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F3E52),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Lihat Status Pengajuan",
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
