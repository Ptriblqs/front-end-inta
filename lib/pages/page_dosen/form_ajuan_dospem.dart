import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/services/ajukan_pembimbing_service.dart';
import 'package:inta301/services/file_download_service.dart';
import 'package:inta301/services/api_config.dart';

class FormAjuanDospemPage extends StatefulWidget {
  final int ajuanId;

  const FormAjuanDospemPage({
    super.key,
    required this.ajuanId,
  });

  @override
  State<FormAjuanDospemPage> createState() => _FormAjuanDospemPageState();
}

class _FormAjuanDospemPageState extends State<FormAjuanDospemPage> {
  Map<String, dynamic>? ajuanData;
  bool isLoading = true;
  final TextEditingController catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => isLoading = false);
        Get.snackbar(
          'Error',
          'Token tidak ditemukan. Silakan login ulang.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      print('🔄 Loading detail ajuan ID: ${widget.ajuanId}');

      final result = await AjukanPembimbingService.getDetailAjuan(
        id: widget.ajuanId,
        token: token,
      );

      print('📊 Detail result: $result');

      if (result['success'] == true) {
        setState(() {
          ajuanData = result['data'];
          isLoading = false;
        });
        print('✅ Detail loaded successfully');
      } else {
        setState(() => isLoading = false);
        Get.snackbar(
          'Error',
          result['message'] ?? 'Gagal memuat detail',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('❌ Exception: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // ✅ Helper methods untuk ambil data nested dengan aman
  String _getNamaMahasiswa() {
    try {
      if (ajuanData!['mahasiswa'] is Map) {
        return ajuanData!['mahasiswa']['nama_lengkap']?.toString() ?? '-';
      }
      return ajuanData!['nama_mahasiswa']?.toString() ?? '-';
    } catch (e) {
      print('Error getting nama mahasiswa: $e');
      return '-';
    }
  }

  String _getProgramStudi() {
    try {
      if (ajuanData!['program_studi'] is Map) {
        return ajuanData!['program_studi']['nama_prodi']?.toString() ?? '-';
      }
      if (ajuanData!['programStudi'] is Map) {
        return ajuanData!['programStudi']['nama_prodi']?.toString() ?? '-';
      }
      return ajuanData!['program_studi']?.toString() ?? '-';
    } catch (e) {
      print('Error getting program studi: $e');
      return '-';
    }
  }

  /// 🔥 DOWNLOAD + OPEN FILE
  Future<void> _downloadPortofolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.snackbar('Error', 'Token tidak ditemukan');
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final url =
          "${ApiConfig.baseUrl}/ajuan-dospem/${widget.ajuanId}/download";

      final fileName =
          ajuanData!['portofolio'].toString().split('/').last;

      await FileDownloadService.downloadAndOpen(
        url: url,
        fileName: fileName,
        token: token,
      );

       Get.back();
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Gagal download file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleTerima() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Terima Ajuan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menerima ajuan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
             'Batal', 
              style: TextStyle(color: Colors.black),
              ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Ya, Terima',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _prosesAjuan('terima');
    }
  }

  Future<void> _handleTolak() async {
    final result = await Get.dialog<String>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Tolak Ajuan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: TextField(
          controller: catatanController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Masukkan alasan penolakan',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.black)
              ),
          ),
          ElevatedButton(
            onPressed: () {
              if (catatanController.text.length < 10) {
                Get.snackbar(
                  'Peringatan',
                  'Masukkan alasan penolakan',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                );
                return;
              }
              Get.back(result: catatanController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Tolak',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      _prosesAjuan('tolak', catatan: result);
    }
  }

  Future<void> _prosesAjuan(String aksi, {String? catatan}) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Token tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      Map<String, dynamic> result;

      if (aksi == 'terima') {
        result = await AjukanPembimbingService.terimaAjuan(
          id: widget.ajuanId,
          token: token,
        );
      } else {
        result = await AjukanPembimbingService.tolakAjuan(
          id: widget.ajuanId,
          catatanDosen: catatan ?? '',
          token: token,
        );
      }

      Get.back();

      if (result['success'] == true) {
        Get.snackbar(
          'Berhasil',
          result['message'] ?? 'Ajuan berhasil diproses',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );

        Navigator.pop(context, true);
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Gagal memproses ajuan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Ajuan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : ajuanData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : Padding(
                  padding: const EdgeInsets.all(defaultMargin),
                  child: SingleChildScrollView(
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 20,
                      shadowColor: Colors.black.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReadonlyField(
                              "Nama Mahasiswa",
                              _getNamaMahasiswa(),
                            ),
                            _buildReadonlyField(
                              "NIM",
                              ajuanData!['nim']?.toString() ?? '-',
                            ),
                            _buildReadonlyField(
                              "Program Studi",
                              _getProgramStudi(),
                            ),
                            _buildReadonlyField(
                              "Alasan Memilih Dosen",
                              ajuanData!['alasan']?.toString() ?? '-',
                            ),
                            _buildReadonlyField(
                              "Rencana Judul TA",
                              ajuanData!['judul_ta']?.toString() ?? '-',
                            ),
                            _buildReadonlyField(
                              "Deskripsi TA",
                              ajuanData!['deskripsi_ta']?.toString() ?? '-',
                            ),
                            _buildFileField(
                              "Portofolio Mahasiswa",
                              ajuanData!['portofolio']
                                      ?.toString()
                                      .split('/')
                                      .last ??
                                  'Tidak ada file',
                            ),

                            const SizedBox(height: 16),
                            _buildStatusBadge(ajuanData!['status']?.toString() ?? 'menunggu'),

                            if (ajuanData!['status'] == 'menunggu') ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleTolak,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Tolak",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _handleTerima,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Setuju",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildReadonlyField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: label == "Portofolio Mahasiswa"
              ? _downloadPortofolio
              : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.isNotEmpty ? value : "Belum diisi",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildFileField(String label, String fileName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Get.snackbar(
                "Download",
                "File $fileName",
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.download, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    String label;

    switch (status) {
      case 'diterima':
        bgColor = Colors.green;
        label = 'DITERIMA';
        break;
      case 'ditolak':
        bgColor = Colors.red;
        label = 'DITOLAK';
        break;
      default:
        bgColor = Colors.orange;
        label = 'MENUNGGU';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }
}