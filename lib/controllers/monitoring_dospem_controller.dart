import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonitoringDospemController extends GetxController {
  var isLoading = false.obs;

  /// data ajuan aktif (nullable)
  final Rxn<Map<String, dynamic>> ajuanAktif =
      Rxn<Map<String, dynamic>>();

  /// data dosen pembimbing aktif untuk mahasiswa (nullable)
  final Rxn<Map<String, dynamic>> dospemAktif =
      Rxn<Map<String, dynamic>>();

  // base url API (samakan dengan backend kamu)
   // final String baseUrl = 'http://127.0.0.1:8000/api';

// base url API (samakan dengan backend kamu)
   final String baseUrl = 'http://10.239.133.112:8000/api';
  

  Future<void> fetchAjuan() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        ajuanAktif.value = null;
        return;
      }

      final response = await GetConnect().get(
        '$baseUrl/ajuan-dospem',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 &&
          response.body != null &&
          response.body['data'] != null &&
          response.body['data'].isNotEmpty) {
        /// ambil ajuan terakhir
        ajuanAktif.value = response.body['data'][0];
      } else {
        ajuanAktif.value = null;
      }
    } catch (e) {
      ajuanAktif.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch active supervisor for the logged-in mahasiswa
  Future<void> fetchDospemAktif() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        dospemAktif.value = null;
        return;
      }
 

      final response = await GetConnect().get(
        '$baseUrl/mahasiswa/{userId}/dospem-aktif',
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 && response.body != null) {
        // Assume backend returns { data: { ...dosen... } } or data null
        final body = response.body;
        if (body is Map && body['data'] != null) {
          dospemAktif.value = Map<String, dynamic>.from(body['data']);
        } else {
          dospemAktif.value = null;
        }
      } else {
        dospemAktif.value = null;
      }
    } catch (e) {
      dospemAktif.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
