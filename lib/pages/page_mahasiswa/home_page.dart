import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/controllers/auth_controller.dart';
import 'package:inta301/controllers/monitoring_dospem_controller.dart';
import 'package:inta301/services/bimbingan_service.dart';
import 'package:inta301/services/pengumuman_service.dart';

// Global
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';

// Menu controller
import 'package:inta301/controllers/menu_controller.dart' as myCtrl;
import 'package:inta301/widgets/progress_bar_chart.dart';

class HomePage extends StatefulWidget {
  final bool hasDosen;

  const HomePage({super.key, required this.hasDosen});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final menuC = Get.find<myCtrl.MenuController>();
  final monitoringC = Get.put(MonitoringDospemController());
  final BimbinganService _bimbinganService = BimbinganService();
  final PengumumanService _pengumumanService = PengumumanService();

  bool isLoadingJadwal = true;
  List<Map<String, dynamic>> jadwalDisetujui = [];

  bool isLoadingPengumuman = true;
  List<Map<String, dynamic>> pengumumanList = [];


  @override
  void initState() {
    super.initState();
    monitoringC.fetchAjuan();
    _loadJadwalDisetujui();
    _loadPengumuman(); 
  }
  
  Future<void> _loadPengumuman() async {
  try {
    final data = await _pengumumanService.getPengumuman();
    setState(() {
    pengumumanList = data;
     isLoadingPengumuman = false;
    });
  } catch (e) {
    debugPrint(e.toString());
  }

  setState(() => isLoadingPengumuman = false);
}


  Future<void> _loadJadwalDisetujui() async {
    try {
      final res = await _bimbinganService.getJadwalMahasiswa();

      if (res['success'] == true && res['data'] is List) {
        final list = List<Map<String, dynamic>>.from(res['data']);

        jadwalDisetujui = list.where((item) {
          final s = (item['status'] ?? '').toString().toLowerCase();
          return s.contains('diterima') ||
              s.contains('disetujui') ||
              s.contains('dijadwalkan');
        }).toList();
      }
    } catch (_) {}

    setState(() => isLoadingJadwal = false);
  }

  bool get isMenunggu {
    final data = monitoringC.ajuanAktif.value;
    if (data == null) return false;
    return data['status'] == 'menunggu';
  }

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF88BDF2);
    menuC.setPage(myCtrl.PageType.home);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 25),

              const Text(
                "Pengumuman",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
              height: 160,
              child: isLoadingPengumuman
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pengumumanList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _InfoCard(
                          data: pengumumanList[index],
                          mainBlue: mainBlue,
                        );
                      },
                    ),
            ),

              const SizedBox(height: 25),
              _buildMonitoringCard(),

              const SizedBox(height: 25),
              const ProgressBarChart(),

              if (!isLoadingJadwal && jadwalDisetujui.isNotEmpty) ...[
                const SizedBox(height: 25),
                _buildUpcomingList(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// ================= UPCOMING LIST =================
  Widget _buildUpcomingList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...jadwalDisetujui.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUpcomingCard(item),
          ),
        ),
      ],
    );
  }

  /// ================= UPCOMING CARD =================
  Widget _buildUpcomingCard(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['judul'] ?? '-',
            style: const TextStyle(
              fontSize: 17, 
              fontWeight: FontWeight.w700,
              color: dangerColor,
              ),
          ),
          const SizedBox(height: 12),
Row(
  children: [
    const Icon(Icons.calendar_today, size: 16, color: Colors.black),
    const SizedBox(width: 8),
    Text(
      item['tanggal'] ?? '-',
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black,
         fontWeight: FontWeight.w500, 
      ),
    ),
  ],
),
const SizedBox(height: 6),
Row(
  children: [
    const Icon(Icons.access_time, size: 16, color: Colors.black),
    const SizedBox(width: 8),
    Text(
      item['waktu'] ?? '-',
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black,
         fontWeight: FontWeight.w500, 
      ),
    ),
  ],
),

          //  const SizedBox(height: 12),

          // Row(
          //   children: [
          //     const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
          //     const SizedBox(width: 8),
          //     Text(item['tanggal'] ?? '-', style: const TextStyle(fontSize: 13)),
          //   ],
          // ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  /// ================= MONITORING =================
  Widget _buildMonitoringCard() {
    return Obx(() {
      if (monitoringC.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = monitoringC.ajuanAktif.value;
      if (data == null) {
        return const Center(child: Text("Belum ada pengajuan dosen pembimbing"));
      }

      final status = data['status'] ?? 'menunggu';
      final color = status == 'diterima'
          ? Colors.green
          : status == 'ditolak'
              ? Colors.red
              : Colors.orange;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.45),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Monitoring Pengajuan Dosen Pembimbing",
            style: TextStyle(fontWeight: FontWeight.bold, color: dangerColor, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text("Dosen: ${data['dosen']?['user']?['nama_lengkap'] ?? '-'}"),
          Text("Prodi: ${data['program_studi']?['nama_prodi'] ?? '-'}"),
          const SizedBox(height: 8),
          Text("Status: ${status.toUpperCase()}", style: TextStyle(color: color)),
          const SizedBox(height: 8),
          if (status == 'ditolak') ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.PILIH_DOSEN),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Cari Dosen Pembimbing", style: TextStyle(color: Colors.white)),
            ),
          ],
        ]),
      );
    });
  }

  Widget _buildGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.45), blurRadius: 12),
        ],
      ),
      child: Obx(() {
        final authC = Get.find<AuthController>();

        final user = authC.user.value;
        final nama = authC.user['nama_lengkap'] ?? 'Mahasiswa';
        return Text("Halo, $nama 👋",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700));
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [primaryColor, dangerColor]),
        ),
      ),
      title: const Text('Beranda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () => Get.toNamed(Routes.NOTIFIKASI),
        ),
      ],
    );
  }

  /// ===================== FIXED LOCK =====================
  /// Bottom nav lock aktif untuk status menunggu, pending, ditolak
  bool get isLocked {
    final data = monitoringC.ajuanAktif.value;
    if (data == null) return false;

    final status = (data['status'] ?? '').toString().toLowerCase();
    return status == 'menunggu' || status == 'pending' || status == 'ditolak';
  }

  Widget _buildBottomNav() {
    return Obx(() {
      final lock = isLocked;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [primaryColor, dangerColor]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(icon: Icons.home, label: "Beranda", isActive: true),
            _BottomNavItem(
                icon: Icons.calendar_month,
                label: "Jadwal",
                isDisabled: lock,
                onTap: () => Get.offAllNamed(Routes.JADWAL)),
            _BottomNavItem(
                icon: Icons.bar_chart_outlined,
                label: "Kanban",
                isDisabled: lock,
                onTap: () => Get.offAllNamed(Routes.KANBAN)),
            _BottomNavItem(
                icon: Icons.description_outlined,
                label: "Dokumen",
                isDisabled: lock,
                onTap: () => Get.offAllNamed(Routes.DOKUMEN)),
            _BottomNavItem(
                icon: Icons.person_outline,
                label: "Profile",
                onTap: () => Get.offAllNamed(Routes.PROFILE)),
          ],
        ),
      );
    });
  }
}

/// ================= HELPER =================
class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color mainBlue;

  const _InfoCard({
    required this.data,
    required this.mainBlue,
  });

  @override
  Widget build(BuildContext context) {
   return Container(
  width: 160,
  padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: Colors.grey.withOpacity(0.15), // sangat halus
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data['judul'] ?? '-',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: dangerColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('🚀 Navigating to detail with data:');
              print('   Judul: ${data['judul']}');
              print('   Isi: ${data['isi']}');
              print('   Attachment: ${data['attachment']}');
              print('   Attachment Name: ${data['attachment_name']}'); // ← CEK INI
              print('   Full Data: $data');
              Get.toNamed(
                Routes.DETAIL_PENGUMUMAN,
                arguments: data,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: mainBlue),
            child: const Text("Lihat", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isDisabled;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDisabled ? Colors.grey : isActive ? Colors.yellow : Colors.white;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}