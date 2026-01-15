import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/services/auth_service.dart';
import '../routes/app_pages.dart';
import 'package:inta301/pages/konfirmasi_akun_page.dart';


class LupaSandiPage extends StatelessWidget {
  final String role;
  const LupaSandiPage({super.key, this.role = 'Mahasiswa'});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔹 Background gradient
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

          // 🔹 Isi halaman
          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 40),

                // 🔹 Header (teks bawah dihapus)
                const Column(
                  children: [
                    Text(
                      "Lupa Password",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // 🔹 Card putih di bawah (sama style kayak login)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultMargin,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Reset Password?",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF384959),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Masukkan email Anda untuk mengatur ulang sandi.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // 🔹 Field email — disamakan dengan style login
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF88BDF2).withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF88BDF2).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF88BDF2).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: Color(0xFF88BDF2),
                              width: 1.5,
                            ),
                          ),
                          hintText: "example@example.com",
                        ),
                      ),

                      const SizedBox(height: 25),

                    // 🔹 Tombol lanjut
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final email = emailController.text.trim();
                            if (email.isEmpty) {
                              Get.snackbar(
                                "",
                                "",
                                backgroundColor: Colors.red,
                                snackStyle: SnackStyle.FLOATING,
                                snackPosition: SnackPosition.TOP, 
                                borderRadius: 12,
                                margin: const EdgeInsets.all(16),
                                titleText: const Text(
                                  "Gagal",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                                messageText: const Text(
                                  "Masukkan email",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                              return;
                            }

                            final res = await AuthService.forgotPassword(email);

                            if (res['success'] == true) {
                              Get.to(() => KonfirmasiAkunPage(email: email));
                            } else {
                              Get.snackbar(
                                "",
                                "",
                                backgroundColor: Colors.red,
                                snackStyle: SnackStyle.FLOATING,
                                snackPosition: SnackPosition.TOP, 
                                borderRadius: 12,
                                margin: const EdgeInsets.all(16),
                                titleText: const Text(
                                  "Gagal",
                                  style: TextStyle(
                                      color: Colors.white),
                                ),
                                messageText: Text(
                                  res['message'] ?? 'Terjadi kesalahan',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF384959),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Lanjut",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

const SizedBox(height: 15),

                      // 🔹 Tombol kembali ke login
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.offAllNamed(Routes.LOGIN);
                          },
                          child: const Text(
                            "Kembali ke halaman login",
                            style: TextStyle(
                              color: Color(0xFF384959),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
}
