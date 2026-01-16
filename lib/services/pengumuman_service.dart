import 'dart:convert';
import 'package:http/http.dart' as http;

class PengumumanService {
  final String baseUrl = 'http://10.239.133.112:8000/api';

  Future<List<Map<String, dynamic>>> getPengumuman() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengumuman'),
        headers: {'Accept': 'application/json'},
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final list = List<Map<String, dynamic>>.from(jsonData['data']);
          
          // Debug: print setiap item
          for (var item in list) {
            print('✅ Item: ${item['judul']}');
            print('   Attachment: ${item['attachment']}');
            print('   Attachment Name: ${item['attachment_name']}'); // ← TAMBAHKAN LOG INI
          }
          
          return list;
        }
      }
      
      throw Exception('Failed to load pengumuman');
    } catch (e) {
      print('❌ Service Error: $e');
      rethrow;
    }
  }
}