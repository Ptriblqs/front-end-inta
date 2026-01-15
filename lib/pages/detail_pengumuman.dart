import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:inta301/shared/shared.dart';

class DetailPengumumanPage extends StatefulWidget {
  const DetailPengumumanPage({super.key});

  @override
  State<DetailPengumumanPage> createState() => _DetailPengumumanPageState();
}

class _DetailPengumumanPageState extends State<DetailPengumumanPage> {
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Debug: print data yang diterima
    final data = Get.arguments as Map<String, dynamic>;
    print('📦 Data diterima:');
    print('Judul: ${data['judul']}');
    print('Isi: ${data['isi']}');
    print('Attachment: ${data['attachment']}');
    print('Attachment Name: ${data['attachment_name']}');
  }

  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    try {
      setState(() {
        isDownloading = true;
        downloadProgress = 0.0;
      });

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Bersihkan nama file
      String cleanFileName = fileName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
      String filePath = '${directory!.path}/$cleanFileName';

      print('📥 Downloading from: $url');
      print('💾 Saving to: $filePath');

      // Download file dengan headers
      Dio dio = Dio();
      await dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            'Accept': '*/*',
            'User-Agent': 'Mozilla/5.0',
          },
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
      });

      // Show success message
      Get.snackbar(
        'Berhasil',
        'File berhasil didownload!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Open file
      final result = await OpenFilex.open(filePath);
      
      if (result.type != ResultType.done) {
        Get.snackbar(
          'Info',
          'File tersimpan di: $filePath',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
      
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      
      print('❌ Download error: $e');
      
      String errorMessage = 'Gagal mendownload file';
      if (e.toString().contains('403')) {
        errorMessage = 'File tidak dapat diakses. Hubungi admin.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'File tidak ditemukan di server';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  bool _hasAttachment(Map<String, dynamic> data) {
    final attachment = data['attachment'];
    return attachment != null && 
           attachment.toString().isNotEmpty && 
           attachment.toString() != 'null';
  }

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments as Map<String, dynamic>;
    final hasAttachment = _hasAttachment(data);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Detail Pengumuman",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            Text(
              data['judul'] ?? 'Tidak ada judul',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: dangerColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Deskripsi
            Text(
              data['isi'] ?? 'Tidak ada deskripsi',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),

            // // Debug info (hapus ini setelah testing)
            // Container(
            //   padding: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: Colors.yellow[100],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text('DEBUG INFO:', style: TextStyle(fontWeight: FontWeight.bold)),
            //       Text('Has Attachment: $hasAttachment'),
            //       Text('Attachment: ${data['attachment']}'),
            //       Text('Attachment Name: ${data['attachment_name']}'),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 16),

            // Attachment Section - SELALU TAMPIL UNTUK TESTING
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_file, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Lampiran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    hasAttachment 
                      ? (data['attachment_name'] ?? 'File') 
                      : 'Tidak ada lampiran',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (isDownloading) ...[
                    LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Downloading... ${(downloadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: hasAttachment 
                          ? () {
                              _downloadAndOpenFile(
                                data['attachment'],
                                data['attachment_name'] ?? 'pengumuman_file.pdf',
                              );
                            }
                          : null, // disabled jika tidak ada attachment
                        icon: const Icon(Icons.download, color: Colors.white),
                        label: Text(
                          hasAttachment ? 'Download & Buka' : 'Tidak Ada File',
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasAttachment ? Colors.blue[700] : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}