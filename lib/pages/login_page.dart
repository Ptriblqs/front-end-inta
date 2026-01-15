import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import '../routes/app_pages.dart';
import '../controllers/auth_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController controller = Get.find<AuthController>();

  String? selectedUser;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Reset role setiap kali halaman login dibuka
    controller.selectedRole.value = "";
    selectedUser = null; // reset dropdown lokal juga
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF88BDF2), Color(0xFF384959)],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 40),

                // Header
                Column(
                  children: [
                    const Text(
                      "Halo, Selamat Datang Di InTA",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Silakan masuk untuk melanjutkan",
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

                const SizedBox(height: 35),

                // Card isi form
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
                    vertical: 25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Jenis Pengguna
                      _buildLabel("Jenis Pengguna"),
                      const SizedBox(height: 6),

                      // hanya bagian build method yang penting diperbaiki, style tetap sama
                      DropdownButtonFormField2<String>(
                        value: selectedUser,
                        isExpanded: true,
                        hint: const Text("Pilih Jenis Pengguna"),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF88BDF2).withOpacity(0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: const Color(0xFF88BDF2),
                              width: 1.5,
                            ),
                          ),
                        ),
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.zero,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDEEFF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Mahasiswa",
                            child: Text("Mahasiswa"),
                          ),
                          DropdownMenuItem(
                            value: "Dosen",
                            child: Text("Dosen"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedUser = value!;
                            controller.selectedRole.value = value
                                .toLowerCase(); // fix role otomatis
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      _buildLabel(
                        controller.selectedRole.value == "mahasiswa"
                            ? "NIM"
                            : "NIK",
                      ),
                      _buildField(controller: controller.usernameController),
                      const SizedBox(height: 15),

                      _buildLabel("Password"),
                      _buildField(
                        controller: controller.passwordController,
                        isPassword: true,
                        obscureText: obscurePassword,
                        toggleVisibility: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),

                      const SizedBox(height: 30),

                      // Tombol Login
                      Obx(
                        () => SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.login();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF384959),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Login",
                                    style: whiteTextStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 🔹 Bagian bawah: Lupa sandi + Daftar
                      Center(
                        child: Column(
                          children: [
                            // 🔹 Tombol "Lupa kata sandi" diperbaiki
                            TextButton(
                              onPressed: () {
                                // Arahkan ke halaman lupa sandi
                                Get.toNamed('/lupa-sandi');
                              },
                              child: Text(
                                "Lupa kata sandi?",
                                style: blackTextStyle.copyWith(
                                  fontSize: 13,
                                  color: primaryColor,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Teks "Daftar Sekarang"
                            GestureDetector(
                              onTap: () {
                                if (selectedUser == "Mahasiswa") {
                                  Get.toNamed(
                                    Routes.REGISTER_MAHASISWA,
                                    arguments: {"role": "Mahasiswa"},
                                  );
                                } else {
                                  Get.toNamed(
                                    Routes.REGISTER_DOSEN,
                                    arguments: {"role": "Dosen"},
                                  );
                                }
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Belum punya akun? ",
                                  style: blackTextStyle.copyWith(fontSize: 13),
                                  children: const [
                                    TextSpan(
                                      text: "Daftar Sekarang",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
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
          ),
        ],
      ),
    );
  }
}

// ===== Reusable Widgets =====
Widget _buildLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Colors.black,
    ),
  );
}

Widget _buildField({
  required TextEditingController controller,
  bool isPassword = false,
  bool obscureText = false,
  VoidCallback? toggleVisibility,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      filled: true,
      fillColor: const Color(0xFF88BDF2).withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
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
        borderSide: BorderSide(color: Color(0xFF88BDF2), width: 1.5),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
              onPressed: toggleVisibility,
            )
          : null,
    ),
  );
}
