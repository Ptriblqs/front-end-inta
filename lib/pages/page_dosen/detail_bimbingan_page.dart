import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/services/bimbingan_service.dart';

class DetailBimbinganDosenPage extends StatefulWidget {
  final int jadwalId;

  const DetailBimbinganDosenPage({
    super.key,
    required this.jadwalId,
  });

  @override
  State<DetailBimbinganDosenPage> createState() =>
      _DetailBimbinganDosenPageState();
}

class _DetailBimbinganDosenPageState extends State<DetailBimbinganDosenPage> {
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
      final response =
          await _bimbinganService.getDetailBimbingan(widget.jadwalId);

      print('📥 Detail Response: $response');

      if (response['success']) {
        setState(() {
          detailBimbingan = response['data'];
        });
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal memuat detail');
      }
    } catch (e) {
      print('❌ Error: $e');
      Get.snackbar('Error', 'Gagal memuat detail: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleTerima() async {
    try {
      final response =
          await _bimbinganService.terimaBimbinganMahasiswa(widget.jadwalId);

      if (response['success']) {
        Get.back(result: true);
        Get.snackbar(
          "Berhasil",
          response['message'] ?? 'Ajuan bimbingan disetujui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal menyetujui ajuan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyetujui ajuan: $e');
    }
  }

  Future<void> _handleTolak() async {
    _alasanController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Alasan Penolakan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: TextField(
          controller: _alasanController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tuliskan alasan penolakan...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
            style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (_alasanController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Alasan penolakan harus diisi');
                return;
              }

              Navigator.pop(context);

              try {
                final response =
                    await _bimbinganService.tolakBimbinganMahasiswa(
                  widget.jadwalId,
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
                    margin: const EdgeInsets.all(16),
                  );
                } else {
                  Get.snackbar(
                    'Error',
                    response['message'] ?? 'Gagal menolak ajuan',
                  );
                }
              } catch (e) {
                Get.snackbar('Error', 'Gagal menolak ajuan: $e');
              }
            },
            child: const Text(
              'Tolak',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleHapus() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Jadwal',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus jadwal bimbingan ini?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);

              try {
                final response =
                    await _bimbinganService.hapusBimbingan(widget.jadwalId);

             if (response['success']) {
  Get.rawSnackbar(
    title: "Berhasil",
    message: response['message'] ?? 'Jadwal berhasil dihapus',
    backgroundColor: Colors.green,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
  );

  Get.back(result: true);
}

                else {
                  Get.snackbar(
                    'Error',
                    response['message'] ?? 'Gagal menghapus jadwal',
                  );
                }
              } catch (e) {
                Get.snackbar('Error', 'Gagal menghapus jadwal: $e');
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
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
        body: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
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

    final String status = detailBimbingan!['status']?.toLowerCase() ?? '';
    final bool isMenunggu = status == 'menunggu';
    final bool isDiterima = status == 'diterima' || status == 'disetujui';
    final bool isDitolak = status == 'ditolak';

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Detail
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            detailBimbingan!['status'] ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildReadonlyField(
                        "Judul Bimbingan",
                        detailBimbingan!['judul'] ?? '-',
                      ),
                      _buildReadonlyField(
                        "Mahasiswa",
                        detailBimbingan!['mahasiswa'] ?? '-',
                      ),
                      _buildReadonlyField(
                        "Tanggal",
                        detailBimbingan!['tanggal'] ?? '-',
                      ),
                      _buildReadonlyField(
                        "Waktu",
                        detailBimbingan!['waktu'] ?? '-',
                      ),
                      _buildReadonlyField(
                        "Jenis Bimbingan",
                        detailBimbingan!['jenis_bimbingan']?.toUpperCase() ??
                            '-',
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
                      if (isDitolak &&
                          detailBimbingan!['alasan_penolakan'] != null)
                        _buildReadonlyField(
                          "Alasan Penolakan",
                          detailBimbingan!['alasan_penolakan'],
                          isError: true,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Buttons
              if (isMenunggu) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _handleTolak,
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text(
                          "Tolak",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _handleTerima,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          "Setuju",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (isDiterima || isDitolak) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleHapus,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text(
                      "Hapus Jadwal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        "Detail Bimbingan",
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

  Widget _buildReadonlyField(
    String label,
    String value, {
    bool isError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isError ? Colors.red : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isError
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: isError
                  ? Border.all(color: Colors.red.withOpacity(0.3))
                  : null,
            ),
            child: Text(
              value.isNotEmpty ? value : "Belum diisi",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: isError ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'diterima':
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'ajuan dosen':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}