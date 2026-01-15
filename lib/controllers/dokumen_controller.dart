import 'package:get/get.dart';
import '../services/dokumen_service.dart';

class DokumenController extends GetxController {
  // =====================
  // STATE
  // =====================
  final isLoading = false.obs;

  /// list mahasiswa (dosen page)
  final mahasiswaList = <Map<String, dynamic>>[].obs;

  /// list dokumen (detail mahasiswa)
  final dokumenList = <Map<String, dynamic>>[].obs;

  // =====================
  // DOSEN
  // =====================

  /// ✅ Ambil list mahasiswa bimbingan dosen
  Future<void> fetchMahasiswa() async {
    try {
      isLoading.value = true;

      final result = await DokumenService.getMahasiswaList();

      mahasiswaList.assignAll(
        List<Map<String, dynamic>>.from(result.map((e) => e as Map<String, dynamic>)),
      );
    } catch (e) {
      mahasiswaList.clear();
      Get.snackbar(
        'Error',
        'Gagal memuat data mahasiswa',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Ambil dokumen mahasiswa by NIM + STATUS
  Future<void> fetchDokumenMahasiswa({
    required int mahasiswaId,
    required String status,
  }) async {
    try {
      isLoading.value = true;

      final result = await DokumenService.getDokumenMahasiswa(
        mahasiswaId: mahasiswaId,
        status: status,
      );

      dokumenList.assignAll(
        List<Map<String, dynamic>>.from(result.map((e) => e as Map<String, dynamic>)),
      );
    } catch (e) {
      dokumenList.clear();
      Get.snackbar(
        'Error',
        'Gagal memuat dokumen mahasiswa',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
