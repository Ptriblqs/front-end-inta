import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'api_config.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AjukanPembimbingService {
  static final String baseUrl = ApiConfig.baseUrl;

  /// ===============================
  /// GET daftar dosen berdasarkan prodi
  /// ===============================
  static Future<Map<String, dynamic>> daftarDosen({
    required int prodiId,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/ajuan-dospem/dosen/prodi/$prodiId");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200,
        "data": data["data"] ?? [],
        "message": data["message"] ?? "",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ===============================
  /// POST ajukan dosen pembimbing (WEB & ANDROID)
  /// ===============================
  static Future<Map<String, dynamic>> ajukanDosen({
    required int idMahasiswa,
    required int idDosen,
    required String judulTugas,
    required String deskripsi,
    required String alasan,
    required int prodiId,
    required String token,
    File? portofolioFile,
    Uint8List? portofolioBytes,
    String? fileName,
  }) async {
    final url = Uri.parse("$baseUrl/ajuan-dospem");

    try {
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      request.fields.addAll({
        "program_studis_id": prodiId.toString(),
        "id_mahasiswa": idMahasiswa.toString(),
        "id_dosen": idDosen.toString(),
        "judul_ta": judulTugas,
        "deskripsi_ta": deskripsi,
        "alasan": alasan,
      });

      // Upload file
      if (kIsWeb && portofolioBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'portofolio',
            portofolioBytes,
            filename:
                fileName ??
                'portofolio_${DateTime.now().millisecondsSinceEpoch}.pdf',
          ),
        );
      } else if (!kIsWeb && portofolioFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('portofolio', portofolioFile.path),
        );
      } else {
        return {"success": false, "message": "File portofolio tidak ditemukan"};
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 || response.statusCode == 201,
        "message": data["message"] ?? "",
        "data": data["data"],
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ===============================
  /// GET detail ajuan
  /// ===============================
  static Future<Map<String, dynamic>> getDetailAjuan({
    required int id,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/ajuan-dospem/$id");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200,
        "data": data["data"],
        "message": data["message"] ?? "",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ===============================
  /// TERIMA ajuan (DOSEN)
  /// ===============================
  static Future<Map<String, dynamic>> terimaAjuan({
    required int id,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/ajuan-dospem/$id/terima");

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200,
        "message": data["message"] ?? "",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ===============================
  /// TOLAK ajuan (DOSEN)
  /// ===============================
  static Future<Map<String, dynamic>> tolakAjuan({
    required int id,
    required String catatanDosen,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/ajuan-dospem/$id/tolak");

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"catatan_dosen": catatanDosen}),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200,
        "message": data["message"] ?? "",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ===============================
  /// GET ajuan masuk dosen
  /// ===============================
  static Future<Map<String, dynamic>> getAjuanMasukDosen({
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl/ajuan-dospem/masuk");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200,
        "data": data["data"] ?? [],
        "message": data["message"] ?? "",
      };
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /// ===============================
  /// GET DAFTAR MAHASISWA BIMBINGAN (DOSEN)
  /// ===============================
  static Future<Map<String, dynamic>> getDaftarMahasiswa({
    required String token,
  }) async {
    try {
      final url = '$baseUrl/bimbingan/mahasiswa';

      print('🔍 Fetching daftar mahasiswa...');
      print('🔗 URL: $url');
      print('🔑 Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Anda belum terdaftar sebagai dosen',
          'data': [],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal memuat data',
          'data': [],
        };
      }
    } catch (e) {
      print('❌ Error getDaftarMahasiswa: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e', 'data': []};
    }
  }

  /// ===============================
  /// CREATE JADWAL BIMBINGAN (DOSEN)
  /// ===============================
  static Future<Map<String, dynamic>> createJadwalBimbingan({
    required int mahasiswaId,
    required String judulBimbingan,
    required String tanggal,
    required String waktu,
    required String lokasi,
    required String token,
    String? jenis,
    String? keterangan,
  }) async {
    try {
      final url = '$baseUrl/bimbingan/jadwal';

      print('📤 Creating jadwal bimbingan...');
      print('🔗 URL: $url');

      final body = {
        'mahasiswa_id': mahasiswaId,
        'judul_bimbingan': judulBimbingan,
        'tanggal': tanggal,
        'waktu': waktu,
        'lokasi': lokasi,
        // ensure created jadwal starts with 'menunggu' status
        'status': 'menunggu',
      };

      if (jenis != null) body['jenis'] = jenis;
      if (keterangan != null) body['keterangan'] = keterangan;

      print('📦 Request body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat jadwal',
        };
      }
    } catch (e) {
      print('❌ Error createJadwalBimbingan: $e');
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
