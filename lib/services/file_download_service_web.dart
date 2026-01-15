import 'download_file_web.dart' as web_downloader;

class FileDownloadService {
  static Future<void> downloadAndOpen({
    required String url,
    required String fileName,
    String? token,
  }) async {
    // Use the authenticated web downloader which handles arraybuffer and wrappers
    await web_downloader.downloadFileAuthenticated(url, fileName, token: token);
  }
}
