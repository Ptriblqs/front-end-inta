import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/controllers/daftar_mahasiswa_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';
import 'package:inta301/controllers/menu_dosen_controller.dart';
import 'package:inta301/services/ajukan_pembimbing_service.dart';
import 'package:intl/intl.dart';
import 'package:inta301/services/bimbingan_service.dart';
import 'package:inta301/models/mahasiswa_bimbingan_model.dart';

// Import widget card & page
import 'package:inta301/pages/page_dosen/mahasiswa_card.dart';
import 'package:inta301/pages/page_dosen/bimbingan_card.dart';
import 'package:inta301/pages/page_dosen/form_ajuan_bimbingan_page.dart';
import 'package:inta301/pages/page_dosen/form_ajuan_dospem.dart';
import 'package:inta301/pages/page_dosen/ajukan_bimbingan_modal.dart';

/// ======================== BIMBINGAN DOSEN PAGE ========================
class BimbinganDosenPage extends GetView<MenuDosenController> {
  const BimbinganDosenPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Set halaman controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setPage(PageTypeDosen.bimbingan);
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Bimbingan Mahasiswa",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Poppins',
          ),
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
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _DaftarMahasiswaTab(),
                  _DaftarBimbinganTab(),
                  const DaftarAjuanDosenTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => _BottomNavDosen(currentPage: controller.currentPage.value),
      ),
    );
  }

  /// Tab Bar Widget
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: defaultMargin, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: 'Poppins',
        ),
        tabs: const [
          Tab(child: _TabLabel(title: "Mahasiswa")),
          Tab(child: _TabLabel(title: "Bimbingan")),
          Tab(child: _TabLabel(title: "Ajuan")),
        ],
      ),
    );
  }
}

// Top-level helpers so other widgets in this file can reuse status formatting
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'menunggu':
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
  switch (status.toLowerCase()) {
    case 'menunggu':
      return 'Menunggu';
    case 'diterima':
      return 'Diterima';
    case 'ditolak':
      return 'Ditolak';
    default:
      return status;
  }
}

/// Tab Label Widget
class _TabLabel extends StatelessWidget {
  final String title;
  const _TabLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Daftar", style: TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// ======================== DAFTAR MAHASISWA ========================
class _DaftarMahasiswaTab extends StatelessWidget {
  // Inisialisasi controller GetX
  final controller = Get.put(DaftarMahasiswaController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading indicator
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      }

      // Jika daftar mahasiswa kosong
      if (controller.mahasiswaList.isEmpty) {
        return Center(
          child: Text(
            controller.errorMessage.value.isEmpty
                ? "Belum ada mahasiswa"
                : controller.errorMessage.value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
            ),
          ),
        );
      }

      // List mahasiswa
      return ListView.builder(
        padding: const EdgeInsets.all(defaultMargin),
        itemCount: controller.mahasiswaList.length,
        itemBuilder: (context, index) {
          final mhs = controller.mahasiswaList[index];

          // Pastikan properti model tidak null
          final nama = mhs.namaMahasiswa;
          final nim = mhs.nim;
          final prodi = mhs.programStudi;

          return MahasiswaCard(
            nama: nama,
            nim: nim,
            prodi: prodi,
            onAjukanBimbingan: () => _showAjukanDialog(context, mhs),
          );
        },
      );
    });
  }

  void _showAjukanDialog(BuildContext context, MahasiswaBimbinganModel mhs) {
    showAjukanBimbinganModal(
      context: context,
      onSubmit: (data) async {
        try {
          final String tanggalInput = (data['tanggal'] ?? '').toString().trim();
          String formattedDate;

          // Accept either already-formatted 'yyyy-MM-dd' from modal or localized display 'EEEE, dd MMMM yyyy'
          if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(tanggalInput)) {
            formattedDate = tanggalInput;
          } else {
            final DateFormat inputFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
            final DateTime parsedDate = inputFormat.parse(tanggalInput);
            formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
          }

          final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
          final String waktuStr = (data['waktu'] ?? '').toString().trim();
          if (!timeRegex.hasMatch(waktuStr)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Format waktu harus HH:mm (contoh: 10:30)'),
              backgroundColor: Colors.red,
            ));
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token == null) throw 'Token tidak ditemukan';

          final result = await AjukanPembimbingService.createJadwalBimbingan(
            mahasiswaId: mhs.mahasiswaId,
            judulBimbingan: (data['judul'] ?? '').toString().trim(),
            tanggal: formattedDate,
            waktu: waktuStr,
            lokasi: (data['lokasi'] ?? '').toString().trim(),
            token: token,
            jenis: (data['jenis'] ?? '').toString().trim().isEmpty ? null : (data['jenis'] ?? '').toString().trim(),
            keterangan: (data['catatan'] ?? '').toString().trim().isEmpty ? null : (data['catatan'] ?? '').toString().trim(),
          );

       if (result['success'] == true) {
  Get.snackbar(
    'Sukses', // judul snackbar
    result['message'] ?? 'Jadwal bimbingan berhasil diajukan', // isi pesan
    snackPosition: SnackPosition.TOP, // tampil di atas
    backgroundColor: Colors.green, // hijau untuk sukses
    colorText: Colors.white, // teks putih supaya kontras
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
  );

         } else {
  Get.snackbar(
    'Gagal',
    result['message'] ?? 'Gagal mengajukan jadwal',
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.red,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
  );
}} catch (e) {
  Get.snackbar(
    'Error', // judul snackbar
    'Gagal mengajukan jadwal: $e', // pesan error
    snackPosition: SnackPosition.TOP, // tampil di atas
    backgroundColor: Colors.red,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
  );
}

      },
    );
  }
}

/// ======================== DAFTAR BIMBINGAN ========================
class _DaftarBimbinganTab extends StatefulWidget {
  @override
  State<_DaftarBimbinganTab> createState() => _DaftarBimbinganTabState();
}

class _DaftarBimbinganTabState extends State<_DaftarBimbinganTab> {
  final BimbinganService _service = BimbinganService();
  List<Map<String, dynamic>> _bimbinganList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBimbingan();
  }

  Future<void> _loadBimbingan() async {
    setState(() => _loading = true);
    final result = await _service.getBimbinganDosen();
    if (result['success'] == true) {
      dynamic raw = result['data'] ?? [];
      List list = [];
      if (raw is List) list = raw;
      else if (raw is Map && raw['bimbingan'] is List) list = raw['bimbingan'];

      setState(() {
        _bimbinganList = List<Map<String, dynamic>>.from(list);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      Get.snackbar('Error', result['message'] ?? 'Gagal memuat bimbingan', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: primaryColor));

    if (_bimbinganList.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada bimbingan",
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBimbingan,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(defaultMargin),
        itemCount: _bimbinganList.length,
          itemBuilder: (context, index) {
          final bimbingan = _bimbinganList[index];

          // Map API variations to our UI fields. The API may return keys like
          // `jadwalId`, `judul`, `mahasiswa`, `nim`, `status`, etc.
          final String nama = (bimbingan['mahasiswa'] ?? bimbingan['nama_mahasiswa'] ?? bimbingan['nama'] ?? bimbingan['judul'] ?? '-').toString();
          final String nim = (bimbingan['nim'] ?? '-').toString();
          // Use `judul` as a secondary line if available, otherwise fallback to program_studi/prodi/status
          final String prodi = (bimbingan['judul'] ?? bimbingan['program_studi'] ?? bimbingan['prodi'] ?? bimbingan['status'] ?? '-').toString();

          return BimbinganCard(
            nama: nama,
            nim: nim,
            prodi: prodi,
            onTap: () => _showBimbinganDetail(context, bimbingan),
          );
        },
      ),
    );
  }

  void _showBimbinganDetail(BuildContext context, Map<String, dynamic> bimbingan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalCtx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            String judul = (bimbingan['judul'] ?? bimbingan['title'] ?? '-').toString();
            String nama = (bimbingan['mahasiswa'] ?? bimbingan['nama_mahasiswa'] ?? bimbingan['nama'] ?? '-').toString();
            String nim = (bimbingan['nim'] ?? '-').toString();
            String tanggalRaw = (bimbingan['tanggal'] ?? bimbingan['date'] ?? '').toString();
String tanggal = '-';

if (tanggalRaw.isNotEmpty && tanggalRaw != '-') {
  try {
    final dt = DateTime.parse(tanggalRaw);
    tanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
  } catch (_) {
    tanggal = tanggalRaw; // fallback kalau parsing gagal
  }
}

            String waktu = (bimbingan['waktu'] ?? bimbingan['time'] ?? '-').toString();
            String lokasi = (bimbingan['lokasi'] ?? bimbingan['location'] ?? '-').toString();
            String status = (bimbingan['status'] ?? '-').toString();
            String keterangan = (bimbingan['keterangan'] ?? bimbingan['description'] ?? '').toString();

            return Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 12),
                    Text(judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(children: [CircleAvatar(radius: 22, backgroundColor: primaryColor.withOpacity(0.12), child: const Icon(Icons.person, color: primaryColor)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(nim, style: const TextStyle(color: Color(0xFF616161)))]))]),
                    const SizedBox(height: 14),
                    Row(children: [const Icon(Icons.calendar_today, size: 18, color: Colors.black), const SizedBox(width: 8), Text(tanggal)]),
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.access_time, size: 18, color: Colors.black), const SizedBox(width: 8), Text(waktu)]),
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.location_on, size: 18, color: Colors.black), const SizedBox(width: 8), Expanded(child: Text(lokasi))]),
                    const SizedBox(height: 12),
                    Row(children: [const Icon(Icons.info_outline, size: 18, color: Colors.black), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _getStatusColor(status), borderRadius: BorderRadius.circular(12)), child: Text(_getStatusLabel(status), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
                    if (keterangan.isNotEmpty) ...[const SizedBox(height: 12), const Text('Keterangan', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(keterangan)],
                    const SizedBox(height: 18),
                  SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: dangerColor, // 🔹 Merah mencolok
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: () => Navigator.of(modalCtx).pop(),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Tutup',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white, // Tulisan putih
        ),
      ),
    ),
  ),
),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ======================== DAFTAR AJUAN DOSEN ========================
class DaftarAjuanDosenTab extends StatefulWidget {
  const DaftarAjuanDosenTab({super.key});

  @override
  State<DaftarAjuanDosenTab> createState() => _DaftarAjuanDosenTabState();
}

class _DaftarAjuanDosenTabState extends State<DaftarAjuanDosenTab> {
  List<Map<String, dynamic>> ajuanList = [];
  bool isLoading = true;
  String filterStatus = 'semua'; // semua, menunggu, diterima, ditolak
  // Track processing ajuan ids to prevent duplicate actions
  final Set<int> _processingIds = {};

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

      final result = await AjukanPembimbingService.getAjuanMasukDosen(token: token);

      if (result['success'] == true) {
        setState(() {
          ajuanList = List<Map<String, dynamic>>.from(result['data'] ?? []);
          isLoading = false;
        });
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
    return ajuanList.where((ajuan) => ajuan['status'] == filterStatus).toList();
  }

  int get menungguCount => ajuanList.where((a) => a['status'] == 'menunggu').length;
  int get diterimaCount => ajuanList.where((a) => a['status'] == 'diterima').length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(child: _buildAjuanList()),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterChip('Semua', 'semua', ajuanList.length)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterChip('Menunggu', 'menunggu', menungguCount)),
          const SizedBox(width: 8),
          Expanded(child: _buildFilterChip('Diterima', 'diterima', diterimaCount)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
              count.toString(),
              style: TextStyle(
                color: isSelected ? Colors.red : Colors.white, // 🔴 Angka merah kalau dipilih, putih kalau tidak
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

  Widget _buildAjuanList() {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: primaryColor));

    if (filteredAjuan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Belum ada ajuan', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              filterStatus == 'semua'
                  ? 'Belum ada mahasiswa yang mengajukan'
                  : 'Tidak ada ajuan dengan status $filterStatus',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAjuan,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredAjuan.length,
        itemBuilder: (context, index) => _buildAjuanCard(filteredAjuan[index]),
      ),
    );
  }

  Widget _buildAjuanCard(Map<String, dynamic> ajuan) {
    final int intId = int.parse(ajuan['id'].toString());
    final status = (ajuan['status'] ?? '').toString().toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormAjuanDospemPage(ajuanId: ajuan['id'])),
              );

              if (result == true) _loadAjuan();
            },
            child: Row(
              children: [
                CircleAvatar(radius: 26, backgroundColor: primaryColor.withOpacity(0.12), child: const Icon(Icons.person, color: primaryColor, size: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ajuan['nama_mahasiswa'] ?? 'Tidak diketahui', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins')),
                      const SizedBox(height: 4),
                      Text(ajuan['nim'] ?? '-', style: const TextStyle(fontSize: 13, color: Color(0xFF616161), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(ajuan['program_studi'] ?? '-', style: const TextStyle(fontSize: 13, color: Color(0xFF616161), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (ajuan['status'] != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getStatusColor(ajuan['status']), borderRadius: BorderRadius.circular(12)),
                    child: Text(_getStatusLabel(ajuan['status']), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, color: Colors.black87, size: 18),
              ],
            ),
          ),


        ],
      ),
    );
  }

  void _confirmTerima(dynamic id) {
    Get.defaultDialog(
      title: 'Konfirmasi',
      middleText: 'Terima ajuan ini?',
      textConfirm: 'Ya',
      textCancel: 'Batal',
      onConfirm: () {
        Get.back();
        _terimaAjuan(id);
      },
    );
  }

  Future<void> _terimaAjuan(dynamic id) async {
    final int intId = int.parse(id.toString());
    if (_processingIds.contains(intId)) return;
    setState(() => _processingIds.add(intId));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw 'Token tidak ditemukan';

      final result = await AjukanPembimbingService.terimaAjuan(id: intId, token: token);

      if (result['success'] == true) {
        Get.snackbar('Sukses', result['message'] ?? 'Ajuan diterima', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);

        // Refresh ajuan list
        await _loadAjuan();

        // Try to refresh daftar mahasiswa but don't let failures block the flow or spam logs.
        try {
          // small delay to give backend time to finalize transaction
          await Future.delayed(const Duration(milliseconds: 700));
          final mahasiswaController = Get.isRegistered<DaftarMahasiswaController>() ? Get.find<DaftarMahasiswaController>() : Get.put(DaftarMahasiswaController());
          // call with a timeout so that a failing endpoint won't hang UI
          await mahasiswaController.loadMahasiswa().timeout(const Duration(seconds: 5));
        } catch (e) {
          // non-fatal: show info but don't treat as error
          Get.snackbar('Info', 'Daftar mahasiswa belum bisa diperbarui: $e', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Gagal', result['message'] ?? 'Gagal menerima ajuan', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _processingIds.remove(intId));
    }
  }

  void _showTolakDialog(dynamic id) {
    final controller = TextEditingController();

    Get.defaultDialog(
      title: 'Tolak Ajuan',
      content: Column(
        children: [
          const Text('Berikan catatan penolakan (opsional):'),
          const SizedBox(height: 8),
          TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Catatan...')),
        ],
      ),
      textCancel: 'Batal',
      textConfirm: 'Tolak',
      onConfirm: () async {
        final catatan = controller.text.trim();
        Get.back();
        await _tolakAjuan(id, catatan);
      },
    );
  }

  Future<void> _tolakAjuan(dynamic id, String catatan) async {
    final int intId = int.parse(id.toString());
    if (_processingIds.contains(intId)) return;
    setState(() => _processingIds.add(intId));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw 'Token tidak ditemukan';

      final result = await AjukanPembimbingService.tolakAjuan(id: intId, catatanDosen: catatan, token: token);

      if (result['success'] == true) {
        Get.snackbar('Sukses', result['message'] ?? 'Ajuan ditolak', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);
        await _loadAjuan();
      } else {
        Get.snackbar('Gagal', result['message'] ?? 'Gagal menolak ajuan', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _processingIds.remove(intId));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
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
    switch (status.toLowerCase()) {
      case 'menunggu':
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

/// ======================== BOTTOM NAV DOSEN ========================
class _BottomNavDosen extends StatelessWidget {
  final PageTypeDosen currentPage;
  const _BottomNavDosen({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MenuDosenController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, dangerColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(icon: Icons.home, label: "Beranda", isActive: currentPage == PageTypeDosen.home, onTap: () => Get.offAllNamed(Routes.HOME_DOSEN)),
          _BottomNavItem(icon: Icons.schedule_outlined, label: "Jadwal", isActive: currentPage == PageTypeDosen.jadwal, onTap: () => Get.offAllNamed(Routes.JADWAL_DOSEN)),
          _BottomNavItem(icon: Icons.school_outlined, label: "Bimbingan", isActive: currentPage == PageTypeDosen.bimbingan, onTap: () => Get.offAllNamed(Routes.BIMBINGAN_DOSEN)),
          _BottomNavItem(icon: Icons.description_outlined, label: "Dokumen", isActive: currentPage == PageTypeDosen.dokumen, onTap: () => Get.offAllNamed(Routes.DOKUMEN_DOSEN)),
          _BottomNavItem(icon: Icons.person_outline, label: "Profile", isActive: currentPage == PageTypeDosen.profile, onTap: () => Get.offAllNamed(Routes.PROFILE_DOSEN)),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  const _BottomNavItem({required this.icon, required this.label, required this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.yellow : Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? Colors.yellow : Colors.white, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
