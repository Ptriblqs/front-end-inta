import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void showRegisterModal(BuildContext context) {
  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final idC = TextEditingController();
  final prodiC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();

  // Level Password 02: Validasi password kuat
  bool validatePassword(String pass) {
    return pass.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(pass) &&
        RegExp(r'[a-z]').hasMatch(pass) &&
        RegExp(r'[0-9]').hasMatch(pass) &&
        RegExp(r'[!@#\$&*~%]').hasMatch(pass);
  }

  // Hashing untuk Data Integrity
  // String hash(String pass) => sha256.convert(utf8.encode(pass)).toString();

  Future<void> saveAccount() async {
    if (namaC.text.isEmpty ||
        emailC.text.isEmpty ||
        idC.text.isEmpty ||
        prodiC.text.isEmpty ||
        passC.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Semua field harus diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
      return;
    }

    if (passC.text != confirmC.text) {
      Get.snackbar(
        "Error",
        "Konfirmasi password tidak cocok",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
      return;
    }

    if (!validatePassword(passC.text)) {
      Get.snackbar(
        "Error",
        "Password harus 8+ char, uppercase, angka & simbol",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
      return;
    }

    final authC = Get.find<AuthController>();

    await authC.register(
      nama: namaC.text,
      email: emailC.text,
      username: idC.text,
      prodi: prodiC.text,
      password: passC.text,
      passwordConfirmation: confirmC.text,
    );
    Get.snackbar(
      "Sukses",
      "Akun berhasil dibuat",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP, 
    );

    Navigator.pop(context);
  }

  // Backup Data
  Future<void> backupData() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {
      'nama': prefs.getString('nama'),
      'email': prefs.getString('email'),
      'id_learning': prefs.getString('id_learning'),
      'prodi': prefs.getString('prodi'),
      'role': prefs.getString('role'),
      'password': prefs.getString('password'),
    };
    print("Backup JSON: ${jsonEncode(data)}"); // Bukti fungsi
  }

  // Restore Data
  Future<void> restoreData(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = jsonDecode(jsonData);
    await prefs.setString('nama', data['nama']);
    await prefs.setString('email', data['email']);
    await prefs.setString('id_learning', data['id_learning']);
    await prefs.setString('prodi', data['prodi']);
    await prefs.setString('role', data['role']);
    await prefs.setString('password', data['password']);
    print("Restore berhasil");
  }

  // UI Modal
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scroll) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Buat Akun Baru",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: namaC,
                  decoration: InputDecoration(labelText: "Nama Lengkap"),
                ),
                TextField(
                  controller: emailC,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: idC,
                  decoration: InputDecoration(labelText: "ID Learning"),
                ),
                TextField(
                  controller: prodiC,
                  decoration: InputDecoration(labelText: "Program Studi"),
                ),
                TextField(
                  controller: passC,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmC,
                  decoration: InputDecoration(labelText: "Konfirmasi Password"),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(onPressed: saveAccount, child: Text("Daftar")),
              ],
            ),
          ),
        );
      },
    ),
  );
}
