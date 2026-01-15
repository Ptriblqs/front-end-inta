import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxString selectedRole = "mahasiswa".obs;
  RxBool isLoading = false.obs;

  RxMap<String, dynamic> user = <String, dynamic>{}.obs;

  Future<void> login() async {
    isLoading.value = true;

    final prefs = await SharedPreferences.getInstance();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final role = selectedRole.value.toLowerCase();

    if (username.isEmpty || password.isEmpty) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "NIM/NIK dan password wajib diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
      return;
    }

    final response = await AuthService.login(
      username: username,
      password: password,
      role: role,
    );

    isLoading.value = false;

    if (response['success'] == true) {
      // SIMPAN TOKEN
      await prefs.setString("token", response['access_token'] ?? "");

      // SIMPAN ROLE
      await prefs.setString("role", role);

      // SIMPAN USER MAP
      user.value = response['user'] ?? {};
      await prefs.setString('user', jsonEncode(user.value));

      // ===== PERBAIKAN UTAMA =====
      int userId = response['user']['id'] ?? 0;
      await prefs.setInt("user_id", userId);
      await prefs.setInt("profile_id", response['user']['profile_id'] ?? userId);

      // SIMPAN MAHASISWA_ID dari response langsung (bukan dari nested object)
      if (role == "mahasiswa") {
        int? mahasiswaId = response['user']['mahasiswa_id'];
        
        if (mahasiswaId != null && mahasiswaId != 0) {
          await prefs.setInt("mahasiswa_id", mahasiswaId);
          await prefs.setInt("id_mahasiswa", mahasiswaId);
          print("✅ mahasiswa_id berhasil disimpan: $mahasiswaId");
        } else {
          print("⚠️ mahasiswa_id NULL atau 0 di response");
          print("⚠️ Response user: ${response['user']}");
        }
      }

      // SIMPAN DOSEN_ID jika role dosen
      if (role == "dosen") {
        int? dosenId = response['user']['dosen_id'];
        
        if (dosenId != null && dosenId != 0) {
          await prefs.setInt("dosen_id", dosenId);
          await prefs.setInt("id_dosen", dosenId);
          print("✅ dosen_id berhasil disimpan: $dosenId");
        } else {
          print("⚠️ dosen_id NULL atau 0 di response");
        }
      }

      // SIMPAN PRODI ID
      int? prodiId = response['user']['prodi_id'];
      if (prodiId != null && prodiId != 0) {
        await prefs.setInt("prodi_id", prodiId);
        print("✅ prodi_id berhasil disimpan: $prodiId");
      } else {
        print("⚠️ prodi_id NULL atau 0");
      }

      // ===== DEBUG SETELAH SIMPAN =====
      print("=== DEBUG SETELAH LOGIN ===");
      print("TOKEN: ${prefs.getString('token') != null ? 'Ada' : 'Tidak Ada'}");
      print("ROLE: ${prefs.getString('role')}");
      print("USER_ID: ${prefs.getInt('user_id')}");
      print("PROFILE_ID: ${prefs.getInt('profile_id')}");
      print("MAHASISWA_ID: ${prefs.getInt('mahasiswa_id')}");
      print("ID_MAHASISWA: ${prefs.getInt('id_mahasiswa')}");
      print("DOSEN_ID: ${prefs.getInt('dosen_id')}");
      print("PRODI_ID: ${prefs.getInt('prodi_id')}");
      print("All Keys: ${prefs.getKeys()}");
      print("===========================");

      // Ambil status pembimbing
      String? statusPembimbing = user['status_pembimbing'];

      // Arahkan berdasarkan role + status pembimbing
      if (role == "mahasiswa") {
        if (statusPembimbing == null || statusPembimbing == "belum_ajukan") {
          Get.offAllNamed(Routes.PILIH_DOSEN);

        } else if (statusPembimbing == "pending" || statusPembimbing == "menunggu") {
          Get.offAllNamed(Routes.home);

        } else if (statusPembimbing == "diterima") {
          Get.offAllNamed(Routes.home);

        } else if (statusPembimbing == "ditolak") {
          Get.offAllNamed(Routes.PILIH_DOSEN);
          Get.snackbar(
            "Ditolak",
            "Pengajuan sebelumnya ditolak, silakan ajukan ulang.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP, 
          );

        } else {
          Get.offAllNamed(Routes.PILIH_DOSEN);
        }

      } else if (role == "dosen") {
        Get.offAllNamed(Routes.HOME_DOSEN);
      }

      Get.snackbar(
        "Berhasil",
        response['message'] ?? "Login berhasil",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );

    } else {
      Get.snackbar(
        "Login gagal",
        response['message'] ?? "NIM / NIK atau password salah",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
    }
  }

  Future<void> logout() async {
    isLoading.value = true;

    bool logoutSuccess = false;
    try {
      logoutSuccess = await AuthService.logout();
    } catch (_) {}

    isLoading.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    usernameController.clear();
    passwordController.clear();
    selectedRole.value = "mahasiswa";
    user.clear();

    Get.offAllNamed(Routes.WELCOME);

    if (logoutSuccess) {
      Get.snackbar(
        "Logout Berhasil",
        "Anda berhasil keluar",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
    }
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String username,
    required String prodi,
    required String password,
    required String passwordConfirmation,
    String? bidangKeahlian,
    String? jurusan,
    String? role,
  }) async {
    isLoading.value = true;

    final response = await AuthService.register(
      nama: nama,
      email: email,
      username: username,
      programStudi: prodi,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role ?? selectedRole.value,
      bidangKeahlian: bidangKeahlian,
      jurusan: jurusan,
    );

    isLoading.value = false;

    if (response['success'] == true) {
      Get.snackbar(
        "Sukses",
        response['message'] ?? "Akun berhasil dibuat",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );

      Get.offAllNamed(
        Routes.LOGIN,
        arguments: {'role': role ?? selectedRole.value},
      );
    } else {
      Get.snackbar(
        "Gagal",
        response['message'] ?? "Registrasi gagal",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
    }

    return response;
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user')) {
      final data = jsonDecode(prefs.getString('user')!);
      user.value = data;
    }
  }
}