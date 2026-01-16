import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileDownloadService {
  static Future<void> downloadAndOpen({
    required String url,
    required String fileName,
    required String token,
  }) async {
    final dio = Dio();

    dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Accept': '*/*',
    };

    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';

    final response = await dio.get(
      url,
      options: Options(
        responseType: ResponseType.bytes, // 🔴 INI WAJIB
        followRedirects: true,
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    final file = File(savePath);
    await file.writeAsBytes(response.data);

    await OpenFilex.open(savePath);
  }
}
