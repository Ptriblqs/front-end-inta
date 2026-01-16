import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:inta301/shared/shared.dart';

class DetailPengumumanPage extends StatefulWidget {
  const DetailPengumumanPage({super.key});

  @override
  State<DetailPengumumanPage> createState() => _DetailPengumumanPageState();
}

class _DetailPengumumanPageState extends State<DetailPengumumanPage> {
  bool isDownloading = false;
  double progress = 0.0;

  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = Get.arguments as Map<String, dynamic>;
  }

  // ===============================
  // MIME TYPE DETECTOR
  // ===============================
  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();

    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return '*/*';
    }
  }

  // ===============================
  // DOWNLOAD & OPEN FILE
  // ===============================
  Future<void> _downloadAndOpen(String url, String fileName) async {
    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
      });

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      await Dio().download(
        url,
        filePath,
        onReceiveProgress: (rec, total) {
          if (total > 0) {
            setState(() {
              progress = rec / total;
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
      });

      final mime = _getMimeType(fileName);

      await OpenFilex.open(
        filePath,
        type: mime,
      );
    } catch (e) {
      setState(() {
        isDownloading = false;
      });

      Get.snackbar(
        'Error',
        'Gagal membuka file',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool get hasAttachment =>
      data['attachment'] != null &&
      data['attachment'].toString().isNotEmpty &&
      data['attachment'].toString() != 'null';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Detail Pengumuman',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================
            // JUDUL
            // ===============================
            Text(
              data['judul'] ?? '-',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // ===============================
            // ISI
            // ===============================
            Text(
              data['isi'] ?? '-',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 24),

            // ===============================
            // LAMPIRAN
            // ===============================
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
                  const Row(
                    children: [
                      Icon(Icons.attach_file),
                      SizedBox(width: 8),
                      Text(
                        'Lampiran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    hasAttachment
                        ? data['attachment_name']
                        : 'Tidak ada lampiran',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  if (isDownloading) ...[
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 6),
                    Text(
                      'Downloading ${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,   // 🔵 tombol biru
                          foregroundColor: Colors.white,  // ⚪ teks & icon putih
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.download),
                        label: const Text('Buka Dokumen'),
                        onPressed: hasAttachment
                            ? () {
                                _downloadAndOpen(
                                  data['attachment'],
                                  data['attachment_name'],
                                );
                              }
                            : null,
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
