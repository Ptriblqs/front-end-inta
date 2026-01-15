import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class FileDownloadService {
  static Future<void> downloadAndOpen({
    required String url,
    required String fileName,
    String? token,
  }) async {
    final dio = Dio();

    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    final dir = await getApplicationDocumentsDirectory();
    final savePath = "${dir.path}/$fileName";

    await dio.download(url, savePath);

    // buka file setelah download
    OpenFilex.open(savePath);
  }
}
