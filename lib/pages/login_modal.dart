import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inta301/shared/shared.dart';
import 'text_field_builder.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../routes/app_pages.dart';

int failedAttempts = 0; // Tambahkan untuk Incident Response Plan

void showLoginModal(BuildContext context) {
  final idC = TextEditingController();
  final passC = TextEditingController();

  String hash(String pass) => sha256.convert(utf8.encode(pass)).toString();

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        String? idError;
        String? passError;

        Future<void> login() async {
          setState(() {
            idError = null;
            passError = null;
          });

          // Validate empty fields
          if (idC.text.isEmpty) {
            setState(() {
              idError = "NIM harus diisi";
            });
            return;
          }
          if (passC.text.isEmpty) {
            setState(() {
              passError = "Password harus diisi";
            });
            return;
          }

          // Incident Response: Lock akun jika gagal 3 kali
          if (failedAttempts >= 3) {
            Get.snackbar(
              "Error",
              "Akun terkunci sementara (Incident Response)",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP, 
            );
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          String? savedId = prefs.getString('nim');
          String? savedPass = prefs.getString('password');

          if (idC.text == savedId && hash(passC.text) == savedPass) {
            Get.snackbar(
              "Success",
              "Login Berhasil",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP, 
            );

            prefs.setBool('isLoggedIn', true);
            failedAttempts = 0; // Reset jika login berhasil
            Get.offAllNamed(Routes.home);
          } else {
            failedAttempts++; // Tambah jika gagal
            setState(() {
              idError = "NIM / Password salah ($failedAttempts kali)";
              passError = "NIM / Password salah ($failedAttempts kali)";
            });
          }
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          builder: (_, scroll) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: defaultMargin,
                vertical: 25,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: blackTextStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  buildTextField(
                    label: "NIM",
                    icon: Icons.badge_outlined,
                    controller: idC,
                    errorText: idError,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    label: "Password",
                    icon: Icons.lock_outline,
                    controller: passC,
                    isPassword: true,
                    errorText: passError,
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Masuk",
                        style: whiteTextStyle.copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
