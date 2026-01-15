import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kanban_task.dart';
import 'api_config.dart';

final String baseUrl = ApiConfig.baseUrl;

class KanbanService {

  // Helper untuk get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET semua tasks
  static Future<Map<String, List<KanbanTask>>> fetchTasks() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/kanban'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'todo': (data['data']['todo'] as List)
              .map((json) => KanbanTask.fromJson(json))
              .toList(),
          'in_progress': (data['data']['in_progress'] as List)
              .map((json) => KanbanTask.fromJson(json))
              .toList(),
          'done': (data['data']['done'] as List)
              .map((json) => KanbanTask.fromJson(json))
              .toList(),
        };
      }
      // Jika gagal → Kembalikan list kosong saja (tanpa error)
      return {'todo': [], 'in_progress': [], 'done': []};
    } catch (_) {
      // Jika error jaringan, server mati, token null → tetap return kosong
      return {'todo': [], 'in_progress': [], 'done': []};
    }
  }

  // CREATE task
  static Future<Map<String, dynamic>> createTask(KanbanTask task) async {
    try {
      final token = await _getToken();

      print('Creating task: ${task.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl/kanban'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toJson()),
      );

      print(
        'Create response: ${response.statusCode} - ${response.body}',
      ); // DEBUG

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'id': data['data']?['id'], // Ambil ID task yang baru dibuat
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menambahkan task',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // UPDATE task
  static Future<Map<String, dynamic>> updateTask(
    int id,
    KanbanTask task,
  ) async {
    try {
      final token = await _getToken();

      print('📝 Updating task $id: ${task.toJson()}');

      final response = await http.put(
        Uri.parse('$baseUrl/kanban/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(task.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate task',
        };
      }
    } catch (e) {
      print('Error updating task: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // DELETE task
  static Future<Map<String, dynamic>> deleteTask(int id) async {
    try {
      final token = await _getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/kanban/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus task',
        };
      }
    } catch (e) {
      print('Error deleting task: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
