import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/services/bimbingan_service.dart';

class FormAjuanBimbinganPage extends StatefulWidget {
  const FormAjuanBimbinganPage({super.key});

  @override
  State<FormAjuanBimbinganPage> createState() => _FormAjuanBimbinganPageState();
}

class _FormAjuanBimbinganPageState extends State<FormAjuanBimbinganPage> {
  final BimbinganService _bimbinganService = BimbinganService();
  final TextEditingController _alasanController = TextEditingController();
  
  bool isLoading = true;
  Map<String, dynamic>? detailBimbingan;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() => isLoading = true);
    
    try {
      // Ambil jadwalId dari arguments yang dikirim dari jadwal_page
      final args = Get.arguments;
      final int jadwalId = args['jadwalId'];
      
      final response = await _bimbinganService.getDetailBimbingan(jadwalId);
      
      if (response['success']) {
        setState(() {
          detailBimbingan = response['data'];
        });
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal memuat detail');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleTerima() async {
    try {
      final jadwalId = detailBimbingan?['id'];
      final response = await _bimbinganService.terimaAjuanDosen(jadwalId);
      
      if (response['success']) {
        Get.back(result: true); // Kembali dengan result true
        Get.snackbar(
          "Berhasil",
          response['message'] ?? 'Ajuan bimbingan disetujui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal menyetujui ajuan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyetujui ajuan: $e');
    }
  }

  Future<void> _handleTolak() async {
    // Show dialog untuk input alasan
    _alasanController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Alasan Penolakan',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _alasanController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tuliskan alasan penolakan...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (_alasanController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Alasan penolakan harus diisi');
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final jadwalId = detailBimbingan?['id'];
                final response = await _bimbinganService.tolakAjuanDosen(
                  jadwalId,
                  _alasanController.text.trim(),
                );
                
                if (response['success']) {
                  Get.back(result: true);
                  Get.snackbar(
                    "Ditolak",
                    response['message'] ?? 'Ajuan bimbingan ditolak',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                } else {
                  Get.snackbar('Error', response['message'] ?? 'Gagal menolak ajuan');
                }
              } catch (e) {
                Get.snackbar('Error', 'Gagal menolak ajuan: $e');
              }
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (detailBimbingan == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        backgroundColor: backgroundColor,
        body: const Center(
          child: Text(
            'Data tidak ditemukan',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
          ),
        ),
      );
    }

    final String tanggal = detailBimbingan!['tanggal'] ?? '-';
    final String tanggalFormatted = tanggal != '-'
        ? DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(tanggal))
        : '-';

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(defaultMargin),
        child: SingleChildScrollView(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 12,
            shadowColor: Colors.black.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadonlyField(
                    "Judul Bimbingan",
                    detailBimbingan!['judul'] ?? '-',
                  ),
                  _buildReadonlyField(
                    "Dosen Pembimbing",
                    detailBimbingan!['dosen_pembimbing'] ?? '-',
                  ),
                  _buildReadonlyField("Tanggal", tanggalFormatted),
                  _buildReadonlyField(
                    "Waktu",
                    detailBimbingan!['waktu'] ?? '-',
                  ),
                  _buildReadonlyField(
                    "Jenis Bimbingan",
                    detailBimbingan!['jenis_bimbingan']?.toUpperCase() ?? '-',
                  ),
                  _buildReadonlyField(
                    "Lokasi",
                    detailBimbingan!['lokasi'] ?? '-',
                  ),
                  if (detailBimbingan!['catatan'] != null &&
                      detailBimbingan!['catatan'].toString().isNotEmpty)
                    _buildReadonlyField(
                      "Catatan",
                      detailBimbingan!['catatan'],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleTolak,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Tolak",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Setuju",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Detail Ajuan Bimbingan",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, dangerColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
          Container(
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
        ],
      ),
    );
  }
}