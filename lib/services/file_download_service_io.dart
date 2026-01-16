import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class FileDownloadService {
  /// Download dan buka file (support Android, iOS, dan Web)
  static Future<void> downloadAndOpen({
    required String url,
    required String fileName,
    String? token,
  }) async {
    try {
      final dio = Dio();

      // Set authorization header jika ada token
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Set timeout
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);

      // Request permission untuk Android
      if (Platform.isAndroid) {
        // Cek versi Android
        if (await _isAndroid13OrAbove()) {
          // Android 13+ tidak perlu permission untuk download ke Downloads
          debugPrint('✓ Android 13+: No storage permission needed');
        } else {
          // Android 12 ke bawah: minta storage permission
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Permission storage ditolak. Izinkan akses storage di Settings.');
          }
          debugPrint('✓ Storage permission granted');
        }
      }

      // Tentukan direktori penyimpanan
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Android: simpan ke Downloads folder
        directory = Directory('/storage/emulated/0/Download');
        
        // Fallback jika tidak ada akses ke /storage/emulated/0/Download
        if (!await directory.exists()) {
          debugPrint('⚠️ Download folder tidak tersedia, gunakan external storage');
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS: simpan ke Documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // Fallback untuk platform lain
        directory = await getApplicationDocumentsDirectory();
      }

      final savePath = '${directory!.path}/$fileName';

      debugPrint('📥 Downloading from: $url');
      debugPrint('💾 Save to: $savePath');

      // Download file dengan progress callback
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('📊 Progress: $progress%');
          }
        },
      );

      debugPrint('✅ Download selesai: $savePath');

      // Verifikasi file berhasil tersimpan
      final file = File(savePath);
      if (!await file.exists()) {
        throw Exception('File gagal tersimpan');
      }

      final fileSize = await file.length();
      debugPrint('📦 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // Buka file setelah download
      final result = await OpenFilex.open(savePath);
      
      debugPrint('📂 Open file result: ${result.type}');
      debugPrint('📂 Message: ${result.message}');

      // Handle error dari OpenFilex
      if (result.type == ResultType.noAppToOpen) {
        throw Exception('Tidak ada aplikasi untuk membuka file ini.\nInstall Microsoft Word, WPS Office, atau Google Docs');
      } else if (result.type == ResultType.fileNotFound) {
        throw Exception('File tidak ditemukan setelah download');
      } else if (result.type == ResultType.permissionDenied) {
        throw Exception('Permission ditolak untuk membuka file');
      } else if (result.type != ResultType.done) {
        throw Exception('Gagal membuka file: ${result.message}');
      }

    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.type}');
      debugPrint('❌ Message: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Koneksi timeout. Cek koneksi internet Anda');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Download timeout. File terlalu besar atau koneksi lambat');
      } else if (e.response?.statusCode == 404) {
        throw Exception('File tidak ditemukan di server (404)');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Tidak memiliki akses ke file ini');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Error download: $e');
      rethrow;
    }
  }

  /// Cek apakah Android 13 atau lebih tinggi
  static Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      // Android 13 = API level 33
      final androidInfo = await _getAndroidVersion();
      return androidInfo >= 33;
    }
    return false;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidVersion() async {
    // Workaround: cek permission untuk tentukan versi
    // Android 13+ tidak memerlukan storage permission
    try {
      final status = await Permission.photos.status;
      return status.isDenied ? 33 : 30; // Simplified check
    } catch (_) {
      return 30; // Default to Android 12
    }
  }

  /// Cek apakah file sudah ada
  static Future<bool> fileExists(String fileName) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory!.path}/$fileName';
      return await File(filePath).exists();
    } catch (e) {
      debugPrint('Error checking file: $e');
      return false;
    }
  }

  /// Hapus file yang sudah didownload
  static Future<bool> deleteFile(String fileName) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory!.path}/$fileName';
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Get path ke file yang sudah didownload
  static Future<String?> getFilePath(String fileName) async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory!.path}/$fileName';
      
      if (await File(filePath).exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting file path: $e');
      return null;
    }
  }
}