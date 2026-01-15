import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class KelolaAkunController extends GetxController {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final nimController = TextEditingController();
  final nikController = TextEditingController();
  final noTeleponController = TextEditingController();

  var isLoading = false.obs;
  var nama = ''.obs;
  var prodiId = 0.obs; // prodi wajib untuk update

  @override
  void onInit() {
    super.onInit();
    namaController.addListener(() {
      nama.value = namaController.text;
    });
  }

  // ===== Mahasiswa =====
  Future<void> getProfileMahasiswa() async {
    try {
      isLoading.value = true;

      final profile = await AuthService.getMahasiswaProfile();
      final data = profile['data'];

      namaController.text = data['nama_lengkap'] ?? '';
      emailController.text = data['email'] ?? '';
      nimController.text = data['nim'] ?? '';
      prodiId.value = data['prodi_id'] ?? 0;
      nama.value = data['nama_lengkap'] ?? '';

      print(profile);
    } catch (e) {
      print("Error getProfileMahasiswa: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileMahasiswa() async {
    isLoading.value = true;

    final response = await AuthService.updateProfilMahasiswa(
      nama_lengkap: namaController.text,
      email: emailController.text,
      nim: nimController.text,
      prodi_id: prodiId.value,
      fotoProfil: null, // nanti bisa isi image picker
    );

    isLoading.value = false;
    print(response);

    if (response['success'] == true) {
      Get.snackbar("Berhasil", "Profil berhasil diperbarui",
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP,);
    } else {
      Get.snackbar("Gagal", response['message'] ?? "Gagal update",
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP,);
    }
  }

  // ===== Dosen =====
  Future<void> getProfileDosen() async {
    try {
      isLoading.value = true;

      final profile = await AuthService.getDosenProfile();
      final data = profile['data'];

      namaController.text = data['nama_lengkap'] ?? '';
      emailController.text = data['email'] ?? '';
      nikController.text = data['nik'] ?? '';
      noTeleponController.text = data['no_telepon'] ?? '';
      prodiId.value = data['prodi_id'] ?? 0;
      nama.value = data['nama_lengkap'] ?? '';

      print(profile);
    } catch (e) {
      print("Error getProfileDosen: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileDosen() async {
    isLoading.value = true;

    final response = await AuthService.updateProfilDosen(
      nama_lengkap: namaController.text,
      email: emailController.text,
      nik: nikController.text,
      no_telepon: noTeleponController.text,
      prodi_id: prodiId.value,
      fotoProfil: null,
    );

    isLoading.value = false;
    print(response);

    if (response['success'] == true) {
      Get.snackbar("Berhasil", "Profil berhasil diperbarui",
          backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP,);
    } else {
      Get.snackbar("Gagal", response['message'] ?? "Gagal update",
          backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP,);
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    emailController.dispose();
    nimController.dispose();
    nikController.dispose();
    noTeleponController.dispose();
    super.onClose();
  }
}
