import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../models/dosen_model.dart';
import '../services/ajukan_pembimbing_service.dart';

class AjukanPembimbingController extends GetxController {
  final judulController = TextEditingController();
  final deskripsiController = TextEditingController();
  final alasanController = TextEditingController();

  var isLoading = false.obs;
  var dosenList = <DosenModel>[].obs;
  var errorMessage = ''.obs;

  // ✅ UBAH JADI RxString dengan .obs
  final fileName = ''.obs;
  
  File? portofolioFile;
  Uint8List? portofolioBytes;

  /// ===============================
  /// PILIH FILE (WEB & ANDROID)
  /// ===============================
  Future<void> pilihPortofolio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: kIsWeb,
      );

      if (result == null) {
        print("❌ File picker dibatalkan");
        return;
      }

      final file = result.files.single;

      // ✅ SET NAMA FILE
      fileName.value = file.name;
      print("✅ File dipilih: ${fileName.value} (${file.size} bytes)");

      if (kIsWeb) {
        portofolioBytes = file.bytes;
        portofolioFile = null;
        print("📱 Platform: WEB - menggunakan bytes");
      } else {
        if (file.path != null) {
          portofolioFile = File(file.path!);
          portofolioBytes = null;
          print("📱 Platform: MOBILE - menggunakan file path");
        }
      }

      update();
      
      Get.snackbar(
        "Berhasil",
        "File ${fileName.value} berhasil dipilih",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print("❌ Error pilih file: $e");
      Get.snackbar(
        "Error",
        "Gagal memilih file: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
    }
  }

  /// ===============================
  /// GET DOSEN
  /// ===============================
  Future<void> getDosen() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final prodiId = prefs.getInt('prodi_id') ?? 0;

      print("🔑 Token: ${token.isNotEmpty ? 'Ada' : 'Kosong'}");
      print("🎓 Prodi ID: $prodiId");

      if (token.isEmpty || prodiId == 0) {
        errorMessage.value = "Token / Prodi tidak ditemukan. Silakan login ulang.";
        return;
      }

      final result = await AjukanPembimbingService.daftarDosen(
        prodiId: prodiId,
        token: token,
      );

      if (result['success'] == true) {
        dosenList.value = (result['data'] as List)
            .map((e) => DosenModel.fromJson(e))
            .toList();
        print("✅ Dosen berhasil dimuat: ${dosenList.length} dosen");
      } else {
        errorMessage.value = result['message'] ?? 'Gagal memuat dosen';
        print("❌ Error: ${errorMessage.value}");
      }
    } catch (e) {
      errorMessage.value = "Terjadi kesalahan: $e";
      print("❌ Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ===============================
  /// AJUKAN DOSEN (WEB & ANDROID)
  /// ===============================
  Future<void> ajukanBimbingan({
    required int idMahasiswa,
    required DosenModel dosen,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final prodiId = prefs.getInt('prodi_id') ?? 0;

      if (token.isEmpty || prodiId == 0) {
        Get.snackbar(
          "Error",
          "Sesi login tidak valid. Silakan login ulang.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
        return;
      }

      // ✅ VALIDASI FILE
      if (portofolioBytes == null && portofolioFile == null) {
        Get.snackbar(
          "Error",
          "File portofolio wajib diupload",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
        return;
      }

      print("📤 Memulai upload...");
      print("👤 ID Mahasiswa: $idMahasiswa");
      print("👨‍🏫 ID Dosen: ${dosen.id}");
      print("📄 File: ${fileName.value}");

      isLoading.value = true;

      final result = await AjukanPembimbingService.ajukanDosen(
        idMahasiswa: idMahasiswa,
        idDosen: dosen.id,
        judulTugas: judulController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
        alasan: alasanController.text.trim(),
        prodiId: prodiId,
        token: token,
        portofolioFile: portofolioFile,
        portofolioBytes: portofolioBytes,
        fileName: fileName.value,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        print("✅ Pengajuan berhasil!");
        
        // ✅ Reset form
        judulController.clear();
        deskripsiController.clear();
        alasanController.clear();
        portofolioFile = null;
        portofolioBytes = null;
        fileName.value = '';
        
        Get.snackbar(
          "Berhasil",
          result['message'] ?? "Pengajuan berhasil dikirim",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
      } else {
        print("❌ Pengajuan gagal: ${result['message']}");
        Get.snackbar(
          "Gagal",
          result['message'] ?? "Terjadi kesalahan",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
      }
    } catch (e) {
      isLoading.value = false;
      print("❌ Exception di ajukanBimbingan: $e");
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
    }
  }

  @override
  void onClose() {
    judulController.dispose();
    deskripsiController.dispose();
    alasanController.dispose();
    super.onClose();
  }
}