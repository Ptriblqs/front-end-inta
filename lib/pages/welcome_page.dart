import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import '../routes/app_pages.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: defaultMargin,
            vertical: 20,
          ),
          children: [
            const SizedBox(height: 30),

            // Ilustrasi
            Center(
              child: Image.asset(
                'assets/images/login-image.png',
                height: 250,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 30),

            // Judul
            Text(
              "Selamat Datang di InTA",
              style: blackTextStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Deskripsi
            Text(
              "Aplikasi informasi tugas akhir mahasiswa Polibatam.",
              style: blackTextStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // Tombol Create Account
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                //  Arahkan ke halaman pilih role dulu
                onPressed: () => Get.toNamed(Routes.PILIH_ROLE),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Create Account",
                  style: whiteTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

          // Tombol Login
SizedBox(
  height: 55,
  width: double.infinity,
  child: ElevatedButton(
    // 🔹 Langsung ke halaman login
    onPressed: () => Get.toNamed(Routes.LOGIN),
    style: ElevatedButton.styleFrom(
      backgroundColor: dangerColor,
      foregroundColor: Colors.white,
      shadowColor: primaryColor.withOpacity(0.4),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: Text(
      "Login",
      style: whiteTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),


            const SizedBox(height: 40),

            /// 🧾 Footer
Text(
  "All rights reserved ©2025",
  textAlign: TextAlign.center,
  style: greyTextStyle.copyWith(
    fontSize: 12,
    color: const Color(0xFF616161),
    fontWeight: FontWeight.w600,
  ),
),
          ],
        ),
      ),
    );
  }
}

