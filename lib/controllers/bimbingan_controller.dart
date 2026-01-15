import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inta301/services/api_config.dart';

class BimbinganController extends GetxController {
  final GetStorage storage = GetStorage();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl, // ✅ FIX FINAL
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  /// 🔹 Ajukan jadwal bimbingan (MAHASISWA)
  Future<Map<String, dynamic>> ajukanJadwal({
    required String judul,
    required String tanggal,
    required String waktu,
    required String lokasi,
    required String jenisBimbingan,
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(
        '/bimbingan/ajukan',
        data: {
          'judul': judul,
          'tanggal': tanggal,
          'waktu': waktu,
          'lokasi': lokasi,
          'jenis_bimbingan': jenisBimbingan,
          'catatan': catatan,
        },
        options: Options(
          headers: {
            if (storage.read('token') != null)
              'Authorization': 'Bearer ${storage.read('token')}',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {
            'success': false,
            'message': 'Terjadi kesalahan jaringan',
          };
    }
  }

  /// 🔹 Ambil jadwal mahasiswa
  Future<Map<String, dynamic>> getJadwalMahasiswa() async {
    try {
      final response = await _dio.get(
        '/bimbingan',
        options: Options(
          headers: {
            if (storage.read('token') != null)
              'Authorization': 'Bearer ${storage.read('token')}',
          },
        ),
      );

      return response.data;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil jadwal',
      };
    }
  }
}
