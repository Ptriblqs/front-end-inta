import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

final String baseUrl = ApiConfig.baseUrl;

class BimbinganService {
  // ================== TOKEN & HEADER ==================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================== SAFE JSON DECODE ==================
  /// FIX UTAMA: Hindari Map<dynamic, dynamic>
  Map<String, dynamic> _decodeToMap(String body) {
    final decoded = json.decode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return {
      'success': false,
      'message': 'Invalid response format',
    };
  }

  // =====================================================
  // =================== MAHASISWA API ===================
  // =====================================================

  Future<Map<String, dynamic>> getBimbinganMahasiswa() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bimbingan'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _decodeToMap(response.body);
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'data': [],
          'message': 'Belum memiliki dosen pembimbing',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load bimbingan (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getBimbinganMahasiswa: $e',
      };
    }
  }

  /// New: fetch jadwal khusus endpoint (used by JadwalPage)
  Future<Map<String, dynamic>> getJadwalMahasiswa() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bimbingan/jadwal'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _decodeToMap(response.body);
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'data': [],
          'message': 'Belum ada jadwal',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load jadwal (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getJadwalMahasiswa: $e',
      };
    }
  }

  Future<Map<String, dynamic>> ajukanBimbinganMahasiswa({
    required String judul,
    required String tanggal,
    required String waktu,
    required String lokasi,
    required String jenisBimbingan,
    String? catatan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bimbingan/ajukan'),
        headers: await _getHeaders(),
        body: json.encode({
          'judul': judul,
          'tanggal': tanggal,
          'waktu': waktu,
          'lokasi': lokasi,
          'jenis_bimbingan': jenisBimbingan,
          'catatan': catatan,
        }),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error ajukanBimbinganMahasiswa: $e',
      };
    }
  }

  Future<Map<String, dynamic>> terimaAjuanDosen(int bimbinganId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId/terima'),
        headers: await _getHeaders(),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error terimaAjuanDosen: $e',
      };
    }
  }

  Future<Map<String, dynamic>> tolakAjuanDosen(
    int bimbinganId,
    String alasan,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId/tolak'),
        headers: await _getHeaders(),
        body: json.encode({'alasan_penolakan': alasan}),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error tolakAjuanDosen: $e',
      };
    }
  }

  /// Terima ajuan (aksi oleh mahasiswa terhadap ajuan dosen)
  Future<Map<String, dynamic>> terimaAjuanMahasiswa(int bimbinganId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId/terimamhs'),
        headers: await _getHeaders(),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error terimaAjuanMahasiswa: $e',
      };
    }
  }

  /// Tolak ajuan (aksi oleh mahasiswa terhadap ajuan dosen)
  Future<Map<String, dynamic>> tolakAjuanMahasiswa(
    int bimbinganId,
    String alasan,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId/tolakmhs'),
        headers: await _getHeaders(),
        body: json.encode({'alasan_penolakan': alasan}),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error tolakAjuanMahasiswa: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getKalenderMahasiswa() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bimbingan/kalender'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _decodeToMap(response.body);
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'data': [],
          'message': 'Kalender masih kosong',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load kalender',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getKalenderMahasiswa: $e',
      };
    }
  }

  // =====================================================
  // ===================== DOSEN API =====================
  // =====================================================

  Future<Map<String, dynamic>> getBimbinganDosen() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bimbingan'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _decodeToMap(response.body);
      }

      return {
        'success': false,
        'message': 'Failed to load bimbingan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getBimbinganDosen: $e',
      };
    }
  }

  Future<Map<String, dynamic>> terimaBimbinganMahasiswa(
    int bimbinganId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId/terima'),
        headers: await _getHeaders(),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error terimaBimbinganMahasiswa: $e',
      };
    }
  }

  Future<Map<String, dynamic>> tolakBimbinganMahasiswa(
    int bimbinganId,
    String alasan,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId/tolak'),
        headers: await _getHeaders(),
        body: json.encode({'alasan_penolakan': alasan}),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error tolakBimbinganMahasiswa: $e',
      };
    }
  }

  // =====================================================
  // ===================== SHARED API ====================
  // =====================================================

  Future<Map<String, dynamic>> getDetailBimbingan(
    int bimbinganId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return _decodeToMap(response.body);
      }

      return {
        'success': false,
        'message': 'Failed to load detail',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getDetailBimbingan: $e',
      };
    }
  }

  Future<Map<String, dynamic>> hapusBimbingan(int bimbinganId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/bimbingan/$bimbinganId'),
        headers: await _getHeaders(),
      );

      return _decodeToMap(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error hapusBimbingan: $e',
      };
    }
  }
}
