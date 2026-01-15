import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mahasiswa_bimbingan_model.dart';
import '../services/ajukan_pembimbing_service.dart';

class DaftarMahasiswaController extends GetxController {
  var isLoading = false.obs;
  var mahasiswaList = <MahasiswaBimbinganModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMahasiswa();
  }

  /// ===============================
  /// LOAD DAFTAR MAHASISWA BIMBINGAN
  /// ===============================
  Future<void> loadMahasiswa() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        errorMessage.value = 'Token tidak ditemukan. Silakan login ulang.';
        Get.snackbar(
          'Error',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
        return;
      }

      print('🔄 Loading daftar mahasiswa...');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final result =
          await AjukanPembimbingService.getDaftarMahasiswa(token: token);

      print('📥 Result API: ${jsonEncode(result)}');

      if (result['success'] == true) {
        /// ===== PERBAIKAN UTAMA DI SINI =====
        dynamic rawData = result['data'];
        List listMahasiswa = [];

        // Jika backend langsung mengirim List
        if (rawData is List) {
          listMahasiswa = rawData;
        }
        // Jika backend mengirim Map { mahasiswa: [] }
        else if (rawData is Map && rawData['mahasiswa'] is List) {
          listMahasiswa = rawData['mahasiswa'];
        }

        // Jika backend mengirim Map { data: { mahasiswa: [] } }
        else if (rawData is Map &&
            rawData['data'] is Map &&
            rawData['data']['mahasiswa'] is List) {
          listMahasiswa = rawData['data']['mahasiswa'];
        }

        mahasiswaList.assignAll(
          listMahasiswa
              .map((e) => MahasiswaBimbinganModel.fromJson(e))
              .toList(),
        );

        print(
            '✅ Mahasiswa berhasil dimuat: ${mahasiswaList.length} mahasiswa');

        if (mahasiswaList.isEmpty) {
          errorMessage.value =
              result['message'] ?? 'Belum ada mahasiswa bimbingan';
        }
      } else {
        errorMessage.value =
            result['message'] ?? 'Gagal memuat daftar mahasiswa';

        print('❌ Error: ${errorMessage.value}');

        Get.snackbar(
          'Info',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      print('❌ Exception loadMahasiswa: $e');

      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ===============================
  /// CREATE JADWAL BIMBINGAN (DOSEN)
  /// ===============================
  Future<void> createJadwal({
    required int mahasiswaId,
    required String judulBimbingan,
    required String tanggal,
    required String waktu,
    required String lokasi,
    String? jenis,
    String? keterangan,
  }) async {
    try {
      if (judulBimbingan.isEmpty ||
          tanggal.isEmpty ||
          waktu.isEmpty ||
          lokasi.isEmpty) {
        Get.snackbar(
          'Error',
          'Semua field harus diisi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan. Silakan login ulang.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
        return;
      }

      print('📤 Membuat jadwal bimbingan...');
      print('👤 Mahasiswa ID : $mahasiswaId');
      print('📋 Judul        : $judulBimbingan');
      print('📅 Tanggal      : $tanggal');
      print('⏰ Waktu        : $waktu');
      print('📍 Lokasi       : $lokasi');

      isLoading.value = true;

      final result = await AjukanPembimbingService.createJadwalBimbingan(
        mahasiswaId: mahasiswaId,
        judulBimbingan: judulBimbingan,
        tanggal: tanggal,
        waktu: waktu,
        lokasi: lokasi,
        token: token,
        jenis: jenis,
        keterangan: keterangan,
      );

      if (result['success'] == true) {
        print('✅ Jadwal bimbingan berhasil dibuat');

        Get.back();

        Get.snackbar(
          'Berhasil',
          result['message'] ?? 'Jadwal bimbingan berhasil dibuat',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );

        await loadMahasiswa();
      } else {
        print('❌ Gagal membuat jadwal: ${result['message']}');

        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Terjadi kesalahan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP, 
        );
      }
    } catch (e) {
      print('❌ Exception createJadwal: $e');

      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP, 
      );
    } finally {
      isLoading.value = false;
    }
  }
}
