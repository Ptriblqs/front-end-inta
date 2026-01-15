import 'package:get/get.dart';
import '../services/dokumen_service.dart';
import 'package:inta301/services/dokumen_service.dart';


class DokumenDosenController extends GetxController {
  // loading for mahasiswa
  final isLoadingMahasiswa = false.obs;

  // loading for dokumen
  final isLoadingDokumen = false.obs;

  final mahasiswaList = <Map<String, dynamic>>[].obs;
  final dokumenList = <Map<String, dynamic>>[].obs;
  final filteredMahasiswaList = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  void filterMahasiswa(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      filteredMahasiswaList.assignAll(mahasiswaList);
      return;
    }
    final q = query.toLowerCase();
    final filtered = mahasiswaList.where((m) {
      final nama = (m["nama"] ?? m["name"] ?? m["nama_mahasiswa"] ?? "-").toString().toLowerCase();
      final nim = (m["nim"] ?? m["npm"] ?? m["npm_nim"] ?? m["nim"] ?? "-").toString().toLowerCase();
      final jurusan = (m["jurusan"] ?? m["prodi"] ?? m["program_studi"] ?? "-").toString().toLowerCase();
      return nama.contains(q) || nim.contains(q) || jurusan.contains(q);
    }).toList();
    filteredMahasiswaList.assignAll(filtered);
  }

  Future<void> fetchMahasiswa() async {
    try {
      isLoadingMahasiswa.value = true;
      final result = await DokumenService.getMahasiswaList();
      mahasiswaList.assignAll(
        List<Map<String, dynamic>>.from(result.map((e) => e as Map<String, dynamic>)),
      );
      // initialize filtered list
      filteredMahasiswaList.assignAll(mahasiswaList);
    } catch (e) {
      mahasiswaList.clear();
      filteredMahasiswaList.clear();
      Get.snackbar('Error', 'Gagal memuat data mahasiswa', snackPosition: SnackPosition.TOP);
    } finally {
      isLoadingMahasiswa.value = false;
    }
  }

  Future<void> fetchDokumenMahasiswa({required int mahasiswaId, required String status}) async {
    try {
      isLoadingDokumen.value = true;
      final result = await DokumenService.getDokumenMahasiswa(
        mahasiswaId: mahasiswaId,
        status: status,
      );
      // Normalize result then filter by requested status locally as a fallback
      final all = List<Map<String, dynamic>>.from(result.map((e) => e as Map<String, dynamic>));
      if (status.trim().isNotEmpty) {
        final filtered = all.where((d) {
          final s = (d['status'] ?? '').toString().toLowerCase();
          return s == status.toLowerCase();
        }).toList();
        dokumenList.assignAll(filtered);
      } else {
        dokumenList.assignAll(all);
      }
    } catch (e) {
      dokumenList.clear();
      Get.snackbar('Error', 'Gagal memuat dokumen mahasiswa', snackPosition: SnackPosition.TOP);
    } finally {
      isLoadingDokumen.value = false;
    }
  }
}
