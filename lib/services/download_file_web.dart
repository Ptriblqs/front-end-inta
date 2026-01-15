import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';

String _bytesPreview(Uint8List bytes, [int len = 24]) {
  final take = bytes.length < len ? bytes.length : len;
  final hex = bytes.take(take).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  final ascii = bytes
      .take(take)
      .map((b) => (b >= 32 && b < 127) ? String.fromCharCode(b) : '.')
      .join();
  return 'hex: $hex | ascii: $ascii | length:${bytes.length}';
}

Uint8List? _tryExtractBase64(Uint8List bytes) {
  try {
    final text = utf8.decode(bytes, allowMalformed: true).trim();
    if (text.isEmpty) return null;

    // If JSON, try to find a base64 field
    try {
      final parsed = json.decode(text);
      if (parsed is Map) {
        for (final key in parsed.keys) {
          final val = parsed[key];
          if (val is String) {
            // data URL like data:application/pdf;base64,AAAA...
            final idx = val.indexOf('base64,');
            if (idx != -1) {
              final b64 = val.substring(idx + 7);
              try {
                return base64.decode(b64);
              } catch (_) {}
            }

            // Plain base64 string
            final cleaned = val.replaceAll('\n', '').replaceAll('\r', '').trim();
            if (cleaned.length > 100 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(cleaned)) {
              try {
                return base64.decode(cleaned);
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {}

    // If not JSON, check if the whole response is a data URL or base64 text
    final idx = text.indexOf('base64,');
    if (idx != -1) {
      final b64 = text.substring(idx + 7);
      try {
        return base64.decode(b64);
      } catch (_) {}
    }

    final cleaned = text.replaceAll('\n', '').replaceAll('\r', '').trim();
    if (cleaned.length > 100 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(cleaned)) {
      try {
        return base64.decode(cleaned);
      } catch (_) {}
    }
  } catch (_) {}
  return null;
}

String? _detectFileType(Uint8List bytes) {
  // Scan the first part of the buffer for known magic signatures.
  // Some servers may prepend whitespace or other bytes before the real file header,
  // so checking only at offset 0 can miss valid binaries.
  final limit = bytes.length < 1024 ? bytes.length : 1024;

  bool _matchAt(int offset, List<int> pattern) {
    if (offset + pattern.length > bytes.length) return false;
    for (var i = 0; i < pattern.length; i++) {
      if (bytes[offset + i] != pattern[i]) return false;
    }
    return true;
  }

  for (var i = 0; i <= limit - 4; i++) {
    // PDF: %PDF
    if (_matchAt(i, [0x25, 0x50, 0x44, 0x46])) return 'pdf';
    // ZIP / DOCX / XLSX / PPTX: PK..
    if (_matchAt(i, [0x50, 0x4B, 0x03, 0x04])) return 'zip';
    // JPG
    if (i <= limit - 3 && _matchAt(i, [0xFF, 0xD8, 0xFF])) return 'jpg';
    // PNG
    if (_matchAt(i, [0x89, 0x50, 0x4E, 0x47])) return 'png';
  }

  // MS Office legacy DOC (OLE) signature requires 8 bytes
  for (var i = 0; i <= limit - 8; i++) {
    if (_matchAt(i, [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1])) return 'doc';
  }

  return null;
}

int _findMagicOffset(Uint8List bytes) {
  final limit = bytes.length < 1024 ? bytes.length : 1024;

  bool _matchAt(int offset, List<int> pattern) {
    if (offset + pattern.length > bytes.length) return false;
    for (var i = 0; i < pattern.length; i++) {
      if (bytes[offset + i] != pattern[i]) return false;
    }
    return true;
  }

  for (var i = 0; i <= limit - 4; i++) {
    if (_matchAt(i, [0x25, 0x50, 0x44, 0x46])) return i; // %PDF
    if (_matchAt(i, [0x50, 0x4B, 0x03, 0x04])) return i; // PK..
    if (i <= limit - 3 && _matchAt(i, [0xFF, 0xD8, 0xFF])) return i; // JPG
    if (_matchAt(i, [0x89, 0x50, 0x4E, 0x47])) return i; // PNG
  }

  for (var i = 0; i <= limit - 8; i++) {
    if (_matchAt(i, [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1])) return i; // DOC OLE
  }

  return -1;
}

/// Map of file extensions to MIME types for proper document handling
const Map<String, String> mimeTypeMap = {
  'pdf': 'application/pdf',
  'doc': 'application/msword',
  'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'xls': 'application/vnd.ms-excel',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'ppt': 'application/vnd.ms-powerpoint',
  'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'txt': 'text/plain',
  'csv': 'text/csv',
  'zip': 'application/zip',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
};

String _getMimeType(String filename, String? contentTypeHeader) {
  if (contentTypeHeader != null && contentTypeHeader.isNotEmpty) {
    return contentTypeHeader.split(';')[0].trim();
  }
  final ext = filename.split('.').last.toLowerCase();
  return mimeTypeMap[ext] ?? 'application/octet-stream';
}

Future<void> saveFileBytes(String fileName, Uint8List bytes, {String? mimeType}) async {
  final blob = (mimeType != null) ? html.Blob([bytes], mimeType) : html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

/// Authenticated download using XHR (arraybuffer) to preserve raw bytes
/// IMPORTANT: Uses responseType: 'arraybuffer' to avoid UTF-8 corruption
Future<void> downloadFileAuthenticated(String url, String fileName, {String? token}) async {
  final headers = <String, String>{};
  if (token != null) headers['Authorization'] = 'Bearer $token';

  final req = await html.HttpRequest.request(
    url,
    method: 'GET',
    requestHeaders: headers,
    responseType: 'arraybuffer',
  );

  if (req.status != 200) {
    throw Exception('Download failed: status ${req.status}');
  }

  // Preserve raw bytes from arraybuffer response
  final buffer = req.response as ByteBuffer;
  var bytes = Uint8List.view(buffer);

  // Debug: print headers and a preview of the first bytes so we can diagnose encoding issues
  try {
    final contentType = req.getResponseHeader('content-type');
    final cd = req.getResponseHeader('content-disposition');
    print('downloadFileAuthenticated (web) -> url: $url');
    print('Headers: content-type=$contentType, content-disposition=$cd');
    print('First bytes preview: ${_bytesPreview(bytes, 32)}');
  } catch (_) {}

  // Try to detect JSON/base64 wrappers and decode to raw bytes
  try {
    final decoded = _tryExtractBase64(bytes);
    if (decoded != null) {
      print('downloadFileAuthenticated (web) -> detected base64/JSON wrapper, decoded ${decoded.length} bytes');
      bytes = decoded;
    }
  } catch (_) {}

  // If server returned JSON pointing to a file path, fetch that file instead
  try {
    final text = utf8.decode(bytes, allowMalformed: true);
    final parsed = json.decode(text);
    String? filePath;
    if (parsed is Map) {
      filePath = parsed['file_path'] ?? parsed['path'] ?? parsed['file'] ?? null;
      if (filePath == null && parsed.containsKey('data')) {
        final d = parsed['data'];
        if (d is List && d.isNotEmpty && d[0] is Map) {
          filePath = d[0]['file_path'] ?? d[0]['path'] ?? d[0]['file'];
        }
      }
    }

    if (filePath != null && filePath.isNotEmpty) {
      final resolved = Uri.parse(url).resolve(filePath).toString();
      final req2 = await html.HttpRequest.request(
        resolved,
        method: 'GET',
        requestHeaders: headers,
        responseType: 'arraybuffer',
      );
      if (req2.status == 200) {
        final buf2 = req2.response as ByteBuffer;
        bytes = Uint8List.view(buf2);
        print('downloadFileAuthenticated (web) -> fetched binary from $resolved');
      }
    }
  } catch (_) {}

  // Try to determine filename from Content-Disposition header if needed
  try {
    final cd = req.getResponseHeader('content-disposition') ?? '';
    if (cd.isNotEmpty) {
      final cdRegex = RegExp(r'''filename\*=(?:UTF-8'')?([^;\n]+)|filename="?([^";]+)"?''', caseSensitive: false);
      final match = cdRegex.firstMatch(cd);
      if (match != null) {
        final extracted = match.group(1) ?? match.group(2);
        if (extracted != null && extracted.trim().isNotEmpty) {
          try {
            // decode if encoded
            final decoded = Uri.decodeComponent(extracted.trim());
            fileName = decoded;
          } catch (_) {
            fileName = extracted.trim();
          }
        }
      }
    }
  } catch (_) {}

  final contentType = req.getResponseHeader('content-type');
  final mimeType = _getMimeType(fileName, contentType);
  // If bytes contain a leading junk prefix, trim it so the file header starts at 0
  try {
    final offset = _findMagicOffset(bytes);
    if (offset > 0) {
      print('downloadFileAuthenticated (web) -> trimming $offset leading bytes before saving');
      bytes = bytes.sublist(offset);
    }
  } catch (_) {}

  // If file is a Word document (by filename or content-type), save raw bytes directly
  final lowerName = fileName.toLowerCase();
  final ext = lowerName.contains('.') ? lowerName.split('.').last : '';
  final isWordByExt = ext == 'doc' || ext == 'docx';
  final isWordByContentType = contentType != null && (contentType.contains('msword') || contentType.contains('wordprocessingml'));
  if (isWordByExt || isWordByContentType) {
    await saveFileBytes(fileName, bytes, mimeType: mimeType);
    return;
  }

  // Validate by magic bytes if possible. If unknown, avoid overwriting target file
  final detected = _detectFileType(bytes);
  if (detected == null) {
    // Try to interpret as text to provide helpful error instead of saving corrupted file
    try {
      final text = utf8.decode(bytes, allowMalformed: true).trim();
      // If response looks like JSON or HTML, surface error
      if (text.startsWith('{') || text.startsWith('<') || text.length < 1024 && RegExp(r'^[\x09\x0A\x0D\x20-\x7E]+$').hasMatch(text)) {
        throw Exception('Server returned non-binary response while downloading. Response starts with: ${text.substring(0, text.length > 200 ? 200 : text.length)}');
      }
    } catch (_) {}

    // As a final safety, save original response to .orig for debugging and throw
    try {
      final blobOrig = html.Blob([bytes]);
      final urlOrig = html.Url.createObjectUrlFromBlob(blobOrig);
      final anchorOrig = html.document.createElement('a') as html.AnchorElement;
      anchorOrig.href = urlOrig;
      anchorOrig.download = '$fileName.orig';
      html.document.body?.append(anchorOrig);
      anchorOrig.click();
      anchorOrig.remove();
      html.Url.revokeObjectUrl(urlOrig);
      print('downloadFileAuthenticated (web) -> saved original response as $fileName.orig');
    } catch (_) {}

    throw Exception('Downloaded data does not match known binary signatures; saved original as $fileName.orig for inspection.');
  }

  await saveFileBytes(fileName, bytes, mimeType: mimeType);
}
