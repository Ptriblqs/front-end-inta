import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<void> saveFileBytes(String savePath, Uint8List bytes) async {
  final file = File(savePath);
  final dir = file.parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  await file.writeAsBytes(bytes);
}

String? _extFromContentType(String? contentType) {
  if (contentType == null) return null;
  final ct = contentType.split(';').first.trim().toLowerCase();
  switch (ct) {
    case 'application/pdf':
      return 'pdf';
    case 'application/msword':
      return 'doc';
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return 'docx';
    case 'application/zip':
      return 'zip';
    case 'image/png':
      return 'png';
    case 'image/jpeg':
      return 'jpg';
    case 'text/plain':
      return 'txt';
    default:
      return null;
  }
}

/// Authenticated download implementation for IO platforms (Android / iOS / desktop)
Future<void> downloadFileAuthenticated(String url, String fileName, {String? token}) async {
  final headers = <String, String>{};
  if (token != null) headers['Authorization'] = 'Bearer $token';

  final response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode != 200) {
    throw Exception('Download failed: status ${response.statusCode}');
  }

  var bytes = response.bodyBytes;

  // Try to determine filename from Content-Disposition header if present
  final cd = response.headers['content-disposition'];
  String finalName = fileName;
  if (cd != null && cd.isNotEmpty) {
    final cdRegex = RegExp(r'''filename\*=(?:UTF-8'')?([^;\n]+)|filename="?([^";]+)"?''', caseSensitive: false);
    final match = cdRegex.firstMatch(cd);
    if (match != null) {
      final extracted = match.group(1) ?? match.group(2);
      if (extracted != null && extracted.trim().isNotEmpty) {
        try {
          finalName = Uri.decodeComponent(extracted.trim());
        } catch (_) {
          finalName = extracted.trim();
        }
      }
    }
  }

  // Ensure filename has an extension when possible
  if (!finalName.contains('.')) {
    final ext = _extFromContentType(response.headers['content-type']);
    if (ext != null && ext.isNotEmpty) finalName = '$finalName.$ext';
  }

  // Choose an appropriate save directory depending on platform
  Directory? baseDir;
  try {
    if (Platform.isAndroid) {
      // Prefer system Downloads folder when available
      final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (dirs != null && dirs.isNotEmpty) {
        baseDir = dirs.first;
      } else {
        // fallback to external storage root + Download
        final ext = await getExternalStorageDirectory();
        if (ext != null) baseDir = Directory(p.join(ext.path, 'Download'));
      }
    } else if (Platform.isIOS) {
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      // Windows / Linux / macOS
      baseDir = await getDownloadsDirectory();
    }
  } catch (_) {}

  baseDir ??= await getApplicationDocumentsDirectory();

  final savePath = p.join(baseDir.path, finalName);

  await saveFileBytes(savePath, bytes);
}
