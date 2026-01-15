import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

final String baseUrl = ApiConfig.baseUrl;

class NotificationService {
  // Helper untuk get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET semua notifikasi
  static Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final token = await _getToken();

      print('🔔 Fetching notifications with token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/notifikasi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔔 Fetch notifications response: ${response.statusCode}');
      print('🔔 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          List<Map<String, dynamic>> notifications = [];

          for (var item in data['data']) {
            // Prefer explicit waktu from backend if available, otherwise use created_at
            String waktu = '';
            if (item['waktu'] != null && item['waktu'].toString().isNotEmpty) {
              waktu = item['waktu'].toString();
            } else if (item['created_at'] != null) {
              try {
                final dt = DateTime.parse(item['created_at'].toString());
                waktu = DateFormat('HH:mm – dd MMMM yyyy', 'id_ID').format(dt);
              } catch (_) {
                waktu = item['created_at'].toString();
              }
            }

            notifications.add({
              'id': item['id'],
              'jenis': item['jenis'],
              'pesan': item['pesan'],
              'waktu': waktu,
              'created_at': item['created_at'],
              'read': item['read'] ?? item['is_read'] ?? false,
            });
          }

          print('🔔 Total notifications: ${notifications.length}');
          return notifications;
        }
      }
      
      // Jika gagal → Kembalikan list kosong saja (tanpa error)
      print('🔔 Returning empty list');
      return [];
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      // Jika error jaringan, server mati, token null → tetap return kosong
      return [];
    }
  }

  // MARK AS READ for a single notification
  static Future<Map<String, dynamic>> markAsRead(int id) async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/notifikasi/$id/read'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Notifikasi ditandai terbaca',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menandai notifikasi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // MARK ALL AS READ
  static Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      final token = await _getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/notifikasi/read-all'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Semua notifikasi ditandai terbaca',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menandai semua notifikasi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // GET jumlah notifikasi
  static Future<int> getNotificationCount() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/notifikasi/count'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔔 Count response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['count'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      print('❌ Error getting notification count: $e');
      return 0;
    }
  }

  // DELETE notifikasi
  static Future<Map<String, dynamic>> deleteNotification(int id) async {
    try {
      final token = await _getToken();

      print('🗑️ Deleting notification $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/notifikasi/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🗑️ Delete response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Notifikasi berhasil dihapus',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus notifikasi',
        };
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // DELETE semua notifikasi
  static Future<Map<String, dynamic>> deleteAllNotifications() async {
    try {
      final token = await _getToken();

      print('🗑️ Deleting all notifications');

      final response = await http.delete(
        Uri.parse('$baseUrl/notifikasi'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🗑️ Delete all response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Semua notifikasi berhasil dihapus',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus notifikasi',
        };
      }
    } catch (e) {
      print('❌ Error deleting all notifications: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}