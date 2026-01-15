import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/pages/password_berhasil_page.dart';
import 'package:inta301/services/auth_service.dart';

class PasswordBaruPage extends StatefulWidget {
  final String email;
  final String otp;
  const PasswordBaruPage({super.key, required this.email, required this.otp});

  @override
  State<PasswordBaruPage> createState() => _PasswordBaruPageState();
}

class _PasswordBaruPageState extends State<PasswordBaruPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    "Password Baru",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
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
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password Baru",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF384959),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF88BDF2).withOpacity(0.4),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF384959),
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Konfirmasi Password",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF384959),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF88BDF2).withOpacity(0.4),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF384959),
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final password = passwordController.text.trim();
                            final confirm = confirmPasswordController.text.trim();

                            if (password.isEmpty || confirm.isEmpty) {
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
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                messageText: const Text(
                                  "Kolom password tidak boleh kosong.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (password != confirm) {
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
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                messageText: const Text(
                                  "Password tidak sama.",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              );
                              return;
                            }

                            final res = await AuthService.resetPassword(
                              widget.email,
                              widget.otp,
                              password,
                              confirm,
                            );

                            if (res['success'] == true) {
                              Get.offAll(() => const PasswordBerhasilPage());
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
                                  res['message'] ?? 'Gagal mereset password',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF384959),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Ubah Password",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
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
