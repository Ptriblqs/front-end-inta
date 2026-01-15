import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
 //static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const String baseUrl = 'http://10.239.133.112:8000/api';

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': role,
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        // Token
        await prefs.setString('token', data['access_token']);

        // Role
        await prefs.setString('role', data['user']['role']);

        // User ID
        await prefs.setInt('user_id', data['user']['id']);
        print("✔ user_id disimpan: ${data['user']['id']}");

        // Profile ID (Mahasiswa/Dosen)
        if (data['user']['profile_id'] != null) {
          await prefs.setInt('profile_id', data['user']['profile_id']);
          print("✔ profile_id disimpan: ${data['user']['profile_id']}");
        } else {
          print("⚠ profile_id TIDAK ditemukan");
        }

        // Mahasiswa ID
        if (data['user']['mahasiswa_id'] != null) {
          await prefs.setInt('id_mahasiswa', data['user']['mahasiswa_id']);
          print("✔ id_mahasiswa disimpan: ${data['user']['mahasiswa_id']}");
        } else {
          print("⚠ id_mahasiswa TIDAK ditemukan dalam response");
        }

        // prodi_id
        if (data['user'].containsKey('prodi_id') && data['user']['prodi_id'] != null) {
          await prefs.setInt('prodi_id', data['user']['prodi_id']);
          print("✔ prodi_id disimpan: ${data['user']['prodi_id']}");
        } else {
          print("⚠ prodi_id tidak ditemukan di response login");
        }

        print("=== DEBUG SHARED PREFERENCES AFTER LOGIN ===");
        print("token: ${prefs.getString('token')}");
        print("role: ${prefs.getString('role')}");
        print("user_id: ${prefs.getInt('user_id')}");
        print("profile_id: ${prefs.getInt('profile_id')}");
        print("id_mahasiswa: ${prefs.getInt('id_mahasiswa')}");
        print("prodi_id: ${prefs.getInt('prodi_id')}");
        print("================================================");

        return {
          'success': true,
          'message': data['message'],
          'access_token': data['access_token'],
          'user': data['user'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? "Login gagal"};
      }
    } catch (e) {
      return {
        'success': false,
        'message': "Tidak dapat terhubung ke server: $e",
      };
    }
  }

  static Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String username,
    required String programStudi,
    String? bidangKeahlian,
    String? jurusan,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'username': username,
        'nama_lengkap': nama,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'program_studis': int.tryParse(programStudi) ?? 0,
      };

      if (role.toLowerCase() == 'mahasiswa') {
        body['portofolio'] = "";
      }

      if (role.toLowerCase() == 'dosen') {
        body['bidang_keahlian'] = bidangKeahlian ?? "";
        body['jurusan'] = jurusan ?? "";
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'message': data['message'] ?? 'Registrasi berhasil',
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // GET PRODI
  static Future<List<Map<String, dynamic>>> getProgramStudi() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/program-studi'),
        headers: {"Accept": "application/json"},
      );

      if (res.statusCode == 200) {
        final parsed = jsonDecode(res.body);

        if (parsed is List) {
          return List<Map<String, dynamic>>.from(parsed);
        } else if (parsed is Map && parsed.containsKey('data')) {
          return List<Map<String, dynamic>>.from(parsed['data']);
        } else {
          throw Exception("Format response tidak sesuai");
        }
      } else {
        throw Exception("Status code: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Gagal mengambil data prodi: $e");
    }
  }

  // GET PROFILE MAHASISWA
  static Future<Map<String, dynamic>> getMahasiswaProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "data": data["data"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  // ==================================================
  // FORGOT / OTP / RESET PASSWORD (PUBLIC)
  // ==================================================
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': data['success'] ?? true, 'message': data['message'] ?? 'OTP dikirim ke email'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Gagal mengirim OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'OTP valid'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'OTP salah / kadaluarsa'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'Password berhasil diubah'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Gagal mereset password'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET PROFILE DOSEN
  static Future<Map<String, dynamic>> getDosenProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "data": data["data"]};
      } else {
        return {"success": false, "message": data["message"] ?? "Gagal"};
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  // UPDATE MAHASISWA
  static Future<Map<String, dynamic>> updateProfilMahasiswa({
    required String nama_lengkap,
    required String email,
    required String nim,
    required int prodi_id,
    XFile? fotoProfil,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final uri = Uri.parse("$baseUrl/profile");
      final request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nama_lengkap'] = nama_lengkap;
      request.fields['email'] = email;
      request.fields['nim'] = nim;
      request.fields['prodi_id'] = prodi_id.toString();

      if (fotoProfil != null) {
        final bytes = await fotoProfil.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'foto_profil',
          bytes,
          filename: fotoProfil.name,
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "message": data['message'] ?? 'Profil berhasil diperbarui',
          "data": data['data'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Gagal update profil"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  // UPDATE DOSEN
  static Future<Map<String, dynamic>> updateProfilDosen({
    required String nama_lengkap,
    required String email,
    required String nik,
    required String no_telepon,
    required int prodi_id,
    String? bidang_keahlian,
    XFile? fotoProfil,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final uri = Uri.parse("$baseUrl/profile");
      final request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nama_lengkap'] = nama_lengkap;
      request.fields['email'] = email;
      request.fields['nik'] = nik;
      request.fields['no_telepon'] = no_telepon;
      request.fields['prodi_id'] = prodi_id.toString();

      if (bidang_keahlian != null && bidang_keahlian.isNotEmpty) {
        request.fields['bidang_keahlian'] = bidang_keahlian;
      }

      if (fotoProfil != null) {
        final bytes = await fotoProfil.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'foto_profil',
          bytes,
          filename: fotoProfil.name,
        );

        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "message": data['message'] ?? 'Profil berhasil diperbarui',
          "data": data['data'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Gagal update"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Terjadi kesalahan: $e"};
    }
  }

  Future<List<Map<String, dynamic>>> getBimbinganMahasiswa() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/bimbingan/mahasiswa'),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Gagal mengambil data bimbingan");
    }
  }

  Future<Map<String, dynamic>> submitBimbingan(
    Map<String, dynamic> body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/bimbingan'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true};
    } else {
      final data = json.decode(response.body);
      return {
        "success": false,
        "message": data["message"] ?? "Gagal submit bimbingan",
      };
    }
  }
}
