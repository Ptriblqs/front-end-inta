import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class PilihRolePage extends StatelessWidget {
  const PilihRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient sama seperti LoginPage
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF88BDF2),
                  Color(0xFF384959),
                ],
              ),
            ),
          ),

          // Isi Halaman
          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 50),

                // Header teks
                Column(
                  children: const [
                    Text(
                      "Halo, Selamat Datang Di InTA",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Pilih jenis pengguna untuk melanjutkan",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Card putih di bawah
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Pilih Jenis User!",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF384959),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Dua Card Role
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildRoleCard(
                            icon: Icons.school_rounded, // 🎓 Mahasiswa
                            iconBackground: const Color(0xFF88BDF2),
                            title: "Mahasiswa",
                            color: const Color(0xFF88BDF2),
                            onTap: () {
                              // Arahkan ke halaman registrasi mahasiswa
                              Get.toNamed(
                                Routes.REGISTER_MAHASISWA,
                                arguments: {'role': 'Mahasiswa'},
                              );
                            },
                          ),
                          _buildRoleCard(
                            icon: Icons.co_present_rounded, // 👨‍🏫 Dosen
                            iconBackground: const Color(0xFFB2E6B2),
                            title: "Dosen",
                            color: const Color(0xFFB2E6B2),
                            onTap: () {
                              // Arahkan ke halaman registrasi dosen
                              Get.toNamed(Routes.REGISTER_DOSEN);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Widget Kartu Role =====
  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color iconBackground,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: color.withOpacity(0.4),
      child: Container(
        width: 130,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 Background lingkaran untuk icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: iconBackground.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: const Color(0xFF384959),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF384959),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
