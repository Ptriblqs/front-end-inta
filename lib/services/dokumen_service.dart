import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

// Conditional helper: uses dart:html on web, dart:io on other platforms
import 'download_file_io.dart' if (dart.library.html) 'download_file_web.dart';

final String baseUrl = ApiConfig.baseUrl;

class DokumenService {
  // ============================================================
  // TOKEN
  // ============================================================
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _authHeader() async {
    final token = await _getToken();
    debugPrint('Auth token present: ${token != null}');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // MAHASISWA
  // ============================================================

  /// GET semua dokumen mahasiswa login
  static Future<Map<String, dynamic>> getAllDokumen() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dokumen'),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Gagal memuat dokumen');
  }

  /// UPLOAD dokumen (WEB & MOBILE)
  static Future<Map<String, dynamic>> uploadDokumen({
    required String dosenId,
    required String judul,
    required String bab,
    String? deskripsi,
    required PlatformFile file,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/dokumen'),
    );

    request.headers.addAll(await _authHeader());

    request.fields.addAll({
      'dosen_id': dosenId,
      'judul': judul,
      'bab': bab,
      if (deskripsi != null && deskripsi.isNotEmpty)
        'deskripsi': deskripsi,
    });

    // ================= FILE HANDLING =================
    if (kIsWeb) {
      if (file.bytes == null) {
        throw Exception('File bytes tidak tersedia (WEB)');
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );
    } else {
      if (file.path == null) {
        throw Exception('File path tidak tersedia (MOBILE)');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
        ),
      );
    }

    final response =
        await http.Response.fromStream(await request.send());

    // If backend returns success (200/201) decode and return
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }

    // If backend returned an error payload (JSON), try to decode and return it
    try {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic>) return body;
    } catch (_) {}

    throw Exception('Upload dokumen gagal');
  }

  /// UPLOAD revisi dokumen
  static Future<Map<String, dynamic>> uploadRevisi({
    required int dokumenId,
    required PlatformFile file,
    String? deskripsi,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/dokumen/$dokumenId/revisi'),
    );

    request.headers.addAll(await _authHeader());

    if (deskripsi != null && deskripsi.isNotEmpty) {
      request.fields['deskripsi'] = deskripsi;
    }

    if (kIsWeb) {
      if (file.bytes == null) {
        throw Exception('File bytes tidak tersedia (WEB)');
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );
    } else {
      if (file.path == null) {
        throw Exception('File path tidak tersedia (MOBILE)');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
        ),
      );
    }

    final response =
        await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Upload revisi gagal');
  }

  /// DELETE dokumen
  static Future<bool> deleteDokumen({
    required int dokumenId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/dokumen/$dokumenId'),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }

    throw Exception('Gagal menghapus dokumen');
  }

  /// UPDATE dokumen (judul / bab / file)
  static Future<Map<String, dynamic>> updateDokumen({
    required int dokumenId,
    String? judul,
    String? bab,
    String? deskripsi,
    PlatformFile? file,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/dokumen/$dokumenId'),
    );

    request.headers.addAll(await _authHeader());

    if (judul != null) request.fields['judul'] = judul;
    if (bab != null) request.fields['bab'] = bab;
    if (deskripsi != null) request.fields['deskripsi'] = deskripsi;

    if (file != null) {
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File bytes tidak tersedia (WEB)');
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        if (file.path == null) {
          throw Exception('File path tidak tersedia (MOBILE)');
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path!,
            filename: file.name,
          ),
        );
      }
    }

    final response =
        await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Update dokumen gagal');
  }

  /// DOWNLOAD dokumen (uses authenticated fetch on both web & IO)
  static Future<bool> downloadDokumen({
    required int id,
    required String savePath,
  }) async {
    final url = '$baseUrl/dokumen/$id/download';
    final token = await _getToken();
    // Debug logging for troubleshooting
    debugPrint('DownloadDokumen -> url: $url');
    debugPrint('DownloadDokumen -> token present: ${token != null}');

    // On web, `savePath` is treated as filename; on IO it's full path.
    try {
      await downloadFileAuthenticated(url, savePath, token: token);
    } catch (e) {
      debugPrint('DownloadDokumen failed: $e');
      rethrow;
    }
    return true;
  }

 /// 🔥 Get list mahasiswa bimbingan dosen
static Future<List<dynamic>> getMahasiswaList() async {
  final response = await http.get(
    Uri.parse('$baseUrl/dosen/dokumen/mahasiswa'),
    headers: await _authHeader(),
  );

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    // assume API returns { data: [...] }
    if (body is Map && body.containsKey('data')) {
      return body['data'] as List<dynamic>;
    }
    // fallback: if API returns list directly
    if (body is List) return body as List<dynamic>;
    return <dynamic>[];
  }

  throw Exception('Gagal memuat mahasiswa');
}

/// 🔥 Get dokumen mahasiswa berdasarkan NIM + STATUS (returns list)
static Future<List<dynamic>> getDokumenMahasiswa({
  required int mahasiswaId,
  String status = '',
}) async {
  // Build URI for route: /dosen/dokumen/mahasiswa/{mahasiswaId}
  final baseUri = Uri.parse(baseUrl);
  // Only include 'status' as a query parameter when provided by caller.
  final queryParams = <String, String>{};
  if (status.trim().isNotEmpty) queryParams['status'] = status;

  final uri = baseUri.replace(
    path: '${baseUri.path}/dosen/dokumen/mahasiswa/$mahasiswaId',
    queryParameters: queryParams.isNotEmpty ? queryParams : null,
  );

  final headers = await _authHeader();

  // Debug: print request info
  debugPrint('GET DokumenMahasiswa -> $uri');
  debugPrint('Headers keys: ${headers.keys.toList()}');

  final response = await http.get(uri, headers: headers);

  debugPrint('Response status: ${response.statusCode}');
  debugPrint('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    // Handle backend that returns success:false with message "Dokumen tidak ditemukan"
    if (body is Map && body.containsKey('success') && body['success'] == false) {
      return <dynamic>[];
    }
    if (body is Map && body.containsKey('data')) {
      return body['data'] as List<dynamic>;
    }
    if (body is List) return body as List<dynamic>;
    return <dynamic>[];
  }

  // Try to parse error message from server response
  try {
    final body = json.decode(response.body);
    if (body is Map && body.containsKey('message')) {
      throw Exception(body['message'].toString());
    }
  } catch (_) {}

  throw Exception('Gagal memuat dokumen mahasiswa');
}

static Future<Map<String, dynamic>> updateStatusDokumen({
  required int dokumenId,
  required String status,
  String? catatanRevisi,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/dosen/dokumen/$dokumenId/status'),
    headers: {
      ...await _authHeader(),
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'status': status,
      if (catatanRevisi != null && catatanRevisi.isNotEmpty)
        'catatan_revisi': catatanRevisi,
    }),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  }

  throw Exception('Update status dokumen gagal');
}

  /// GET progress dokumen mahasiswa (per bab + overall)
  static Future<Map<String, dynamic>> getProgress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dokumen/progress'),
      headers: await _authHeader(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }

    // Try to decode error body for better message
    try {
      final body = json.decode(response.body);
      if (body is Map<String, dynamic>) return body;
    } catch (_) {}

    throw Exception('Gagal memuat progress dokumen');
  }
} 