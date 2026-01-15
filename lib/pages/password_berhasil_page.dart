import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class PasswordBerhasilPage extends StatefulWidget {
  const PasswordBerhasilPage({super.key});

  @override
  State<PasswordBerhasilPage> createState() => _PasswordBerhasilPageState();
}

class _PasswordBerhasilPageState extends State<PasswordBerhasilPage> {
  @override
  void initState() {
    super.initState();

    // 🔹 Arahkan otomatis ke halaman login setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed(Routes.LOGIN);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF88BDF2), // 🎨 Biru lembut
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Lingkaran putih dengan ikon centang biru
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF88BDF2), // warna biru muda
                size: 60,
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Teks "Berhasil Diubah"
            const Text(
              "Berhasil Diubah",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(height: 8),

            // ✅ Subteks tambahan (opsional)
            const Text(
              "Kata sandi Anda telah berhasil diperbarui",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
