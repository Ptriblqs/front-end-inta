import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/services/ajukan_pembimbing_service.dart';
import 'package:inta301/pages/page_dosen/form_ajuan_dospem.dart';

class DaftarAjuanDosenPage extends StatefulWidget {
  const DaftarAjuanDosenPage({super.key});

  @override
  State<DaftarAjuanDosenPage> createState() => _DaftarAjuanDosenPageState();
}

class _DaftarAjuanDosenPageState extends State<DaftarAjuanDosenPage> {
  List<Map<String, dynamic>> ajuanList = [];
  bool isLoading = true;
  String filterStatus = 'semua'; // semua, menunggu, diterima, ditolak ✅ UBAH JADI menunggu

  @override
  void initState() {
    super.initState();
    _loadAjuan();
  }

  Future<void> _loadAjuan() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => isLoading = false);
        Get.snackbar(
          'Error',
          'Token tidak ditemukan. Silakan login ulang.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      print('🔄 Fetching ajuan masuk...');
      print('🔑 Token: $token');

      final result = await AjukanPembimbingService.getAjuanMasukDosen(
        token: token,
      );

      print('📊 Result from API: $result');

      if (result['success'] == true) {
        setState(() {
          ajuanList = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoading = false;
        });

        print('✅ Loaded ${ajuanList.length} ajuan');
        
        // ✅ DEBUG: Print semua status yang ada
        for (var ajuan in ajuanList) {
          print('📋 Ajuan ID ${ajuan['id']}: status = "${ajuan['status']}"');
        }
      } else {
        setState(() => isLoading = false);
        Get.snackbar(
          'Error',
          result['message'] ?? 'Gagal memuat data',
          snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  List<Map<String, dynamic>> get filteredAjuan {
    if (filterStatus == 'semua') return ajuanList;
    return ajuanList.where((ajuan) {
      // ✅ NORMALIZE: convert ke lowercase untuk compare
      final status = (ajuan['status'] ?? '').toString().toLowerCase();
      return status == filterStatus.toLowerCase();
    }).toList();
  }

  // ✅ UPDATE: Ganti 'pending' jadi 'menunggu'
  int get menunggungCount =>
      ajuanList.where((a) => (a['status'] ?? '').toString().toLowerCase() == 'menunggu').length;
  int get diterimaCount =>
      ajuanList.where((a) => (a['status'] ?? '').toString().toLowerCase() == 'diterima').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Daftar Ajuan Mahasiswa",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAjuan,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip('Semua', 'semua', ajuanList.length),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // ✅ UBAH JADI MENUNGGU
                  child: _buildFilterChip('Menunggu', 'menunggu', menunggungCount),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip('Diterima', 'diterima', diterimaCount),
                ),
              ],
            ),
          ),

          // List Ajuan
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : filteredAjuan.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada ajuan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filterStatus == 'semua'
                                  ? 'Belum ada mahasiswa yang mengajukan'
                                  : 'Tidak ada ajuan dengan status $filterStatus',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAjuan,
                        color: primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredAjuan.length,
                          itemBuilder: (context, index) {
                            final ajuan = filteredAjuan[index];
                            return _buildAjuanCard(ajuan);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

 Widget _buildFilterChip(String label, String value, int count) {
  final isSelected = filterStatus == value;

  return GestureDetector(
    onTap: () => setState(() => filterStatus = value),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // supaya ukuran chip sesuai konten
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 20,  // lingkaran merah
            height: 20,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 4), // jarak dari label
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildAjuanCard(Map<String, dynamic> ajuan) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormAjuanDospemPage(
              ajuanId: ajuan['id'],
            ),
          ),
        );

        if (result == true) {
          _loadAjuan();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryColor.withOpacity(0.12),
              child: const Icon(Icons.person, color: primaryColor, size: 30),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ajuan['nama_mahasiswa'] ?? 'Tidak diketahui',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ajuan['nim'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ajuan['program_studi'] ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            if (ajuan['status'] != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(ajuan['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(ajuan['status']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.black87,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    // ✅ NORMALIZE: convert ke lowercase
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return Colors.orange;
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    // ✅ NORMALIZE: convert ke lowercase
    switch (status.toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
}