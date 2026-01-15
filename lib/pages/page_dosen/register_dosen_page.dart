import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:inta301/controllers/auth_controller.dart';
import 'package:inta301/shared/shared.dart';
import '../../routes/app_pages.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RegisterDosenPage extends StatefulWidget {
  const RegisterDosenPage({super.key});

  @override
  State<RegisterDosenPage> createState() => _RegisterDosenPageState();
}

class _RegisterDosenPageState extends State<RegisterDosenPage> {
  final AuthController controller = Get.put(AuthController());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final nikController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> prodiList = [
    'Teknik Informatika',
    'Teknologi Geomatika',
    'Teknologi Rekayasa Multimedia',
    'Animasi',
    'Rekayasa Keamanan Siber',
    'Teknologi Rekayasa Perangkat Lunak',
    'Teknologi Permainan',
  ];

  int? selectedProdi; 

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
                Column(
                  children: const [
                    Text(
                      "Halo, Selamat Datang Dosen Di InTA",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Silahkan Isi Data Diri Anda Dengan Lengkap",
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

                      _buildLabel("Nama Lengkap"),
                      _buildField(controller: nameController),
                      const SizedBox(height: 15),

                      _buildLabel("Email"),
                      _buildField(controller: emailController),
                      const SizedBox(height: 15),

                      _buildLabel("NIK"),
                      _buildField(controller: nikController),
                      const SizedBox(height: 15),

                      _buildLabel("Program Studi"),
                      DropdownButtonFormField2<int>(
                        value: selectedProdi,
                        isExpanded: true,
                        hint: const Text(
                          "Pilih Program Studi",
                          style: TextStyle(color: Colors.black54),
                        ),
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
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(
                              color: Color(0xFF88BDF2),
                              width: 1.5,
                            ),
                          ),
                        ),
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.zero,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 250,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDEEFF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: List.generate(prodiList.length, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1, // ID Program Studi
                            child: Text(prodiList[index]),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            selectedProdi = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                    
                      _buildLabel("Password"),
                      _buildPasswordField(
                        controller: passwordController,
                        isVisible: _isPasswordVisible,
                        onToggle: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildLabel("Konfirmasi Password"),
                      _buildPasswordField(
                        controller: confirmController,
                        isVisible: _isConfirmPasswordVisible,
                        onToggle: () => setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            print("Nama: ${nameController.text}");
                            print("Email: ${emailController.text}");
                            print("NIK: ${nikController.text}");
                            print("Prodi ID: $selectedProdi");


                            if (nameController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                nikController.text.isEmpty ||
                                selectedProdi == null ||
                                passwordController.text.isEmpty ||
                                confirmController.text.isEmpty) {
                              Get.snackbar(
                                "Gagal",
                                "Semua field harus diisi",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (passwordController.text !=
                                confirmController.text) {
                              Get.snackbar(
                                "Gagal",
                                "Konfirmasi password tidak cocok",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final authC = Get.find<AuthController>();
                            await authC.register(
                              nama: nameController.text,
                              email: emailController.text,
                              username: nikController.text,
                              prodi: selectedProdi
                                  .toString(), // ID Program Studi
                              password: passwordController.text,
                              passwordConfirmation: confirmController.text,
                              role: 'dosen',
                            );

                            Get.offAllNamed(
                              Routes.LOGIN,
                              arguments: {'role': 'dosen'},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF384959),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Daftar",
                            style: whiteTextStyle.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Sudah punya akun? ",
                            style: blackTextStyle.copyWith(fontSize: 13),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: const TextStyle(
                                  color: Color(0xFF88BDF2),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    controller.selectedRole.value = 'dosen';
                                    Get.toNamed(
                                      Routes.LOGIN,
                                      arguments: {'role': 'Dosen'},
                                    );
                                  },
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
    );
  }

  // ===== Reusable Widgets =====
  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: Colors.black,
    ),
  );

  Widget _buildField({required TextEditingController controller}) => TextField(
    controller: controller,
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
    ),
  );

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) => TextField(
    controller: controller,
    obscureText: !isVisible,
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
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: const Color(0xFF384959),
        ),
        onPressed: onToggle,
      ),
    ),
  );
}
