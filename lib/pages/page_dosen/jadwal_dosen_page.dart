import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';
import 'package:inta301/services/bimbingan_service.dart';
import 'package:inta301/controllers/menu_dosen_controller.dart' as myCtrl;

class JadwalDosenPage extends StatefulWidget {
  const JadwalDosenPage({super.key});

  @override
  State<JadwalDosenPage> createState() => _JadwalDosenPageState();
}

class _JadwalDosenPageState extends State<JadwalDosenPage> {
  late final myCtrl.MenuDosenController controller;
  final BimbinganService _bimbinganService = BimbinganService();

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  
  bool isLoading = true;
  List<dynamic> jadwalList = [];
  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<myCtrl.MenuDosenController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setPage(myCtrl.PageTypeDosen.jadwal);
    });
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final response = await _bimbinganService.getBimbinganDosen();
      
      if (response['success']) {
        setState(() {
          jadwalList = response['data'] ?? [];
          pendingCount = jadwalList
              .where((item) => item['status'] == 'Menunggu')
              .length;
        });
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

void _showDetailModal(Map<String, dynamic> item) {
  final TextEditingController alasanController = TextEditingController();

  // ===== Tentukan pengaju =====
  final String pengaju = (item['pengaju'] ?? '').toString().toLowerCase();
  final bool isFromMahasiswa = pengaju == 'mahasiswa';

  // ===== Status menunggu =====
  final String status = (item['status'] ?? '').toString().toLowerCase();
  final bool isPending = status == 'menunggu';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Detail Ajuan Bimbingan",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildDetailField("Mahasiswa", item['mahasiswa'] ?? '-'),
                  _buildDetailField("Judul", item['judul'] ?? '-'),
                  _buildDetailField("Tanggal", _formatTanggal(item['tanggal'])),
                  _buildDetailField("Waktu", item['waktu'] ?? '-'),
                  _buildDetailField(
                    "Jenis",
                    (item['jenis_bimbingan'] ?? 'offline').toUpperCase(),
                  ),
                  _buildDetailField("Lokasi", item['lokasi'] ?? '-'),
                  if (item['catatan'] != null && item['catatan'].toString().isNotEmpty)
                    _buildDetailField("Catatan", item['catatan']),
                  const SizedBox(height: 30),

                  // ===== Tombol hanya muncul untuk ajuan mahasiswa menunggu =====
                  if (isPending && isFromMahasiswa) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Get.back();
                              final int bimbinganId = item['id'] ?? item['jadwalId'];
                              _showRejectDialog(bimbinganId, alasanController);
                            },
                            child: const Text(
                              "Tolak",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Get.back();
                              final int bimbinganId = item['id'] ?? item['jadwalId'];
                              _handleApprove(bimbinganId);
                            },
                            child: const Text(
                              "Setuju",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
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
          );
        },
      );
    },
  );
}




  void _showRejectDialog(int bimbinganId, TextEditingController controller) {
    controller.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Alasan Penolakan',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Tuliskan alasan penolakan...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                Get.snackbar
                ('Error', 
                'Alasan penolakan harus diisi',
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16 ),
                );
                return;
              }
              Navigator.pop(context);
              _handleReject(bimbinganId, controller.text.trim());
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(int bimbinganId) async {
    try {
      final response = await _bimbinganService.terimaBimbinganMahasiswa(bimbinganId);
      
      if (response['success']) {
        Get.snackbar(
          "Berhasil",
          response['message'] ?? 'Bimbingan berhasil disetujui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        _loadData();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal menyetujui bimbingan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyetujui bimbingan: $e');
    }
  }

  Future<void> _handleReject(int bimbinganId, String alasan) async {
    try {
      final response = await _bimbinganService.tolakBimbinganMahasiswa(
        bimbinganId,
        alasan,
      );
      
      if (response['success']) {
        Get.snackbar(
          "Ditolak",
          response['message'] ?? 'Bimbingan ditolak',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        _loadData();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal menolak bimbingan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menolak bimbingan: $e');
    }
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal == '-') return '-';
    try {
      final date = DateTime.parse(tanggal);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return tanggal;
    }
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(Map<String, dynamic> item) {
    final status = item["status"] ?? "Menunggu";
    Color statusColor;

    switch (status) {
      case "Disetujui":
        statusColor = Colors.green;
        break;
      case "Ditolak":
        statusColor = Colors.red;
        break;
      case "Menunggu":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    final bool isPending = status == "Menunggu";

    return GestureDetector(
      onTap: () => _showDetailModal(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isPending ? Border.all(color: Colors.orange, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["judul"] ?? "-",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          fontFamily: 'Poppins',
                          color: dangerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["mahasiswa"] ?? "-",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${_formatTanggal(item["tanggal"])} | ${item["waktu"] ?? "-"}",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item["lokasi"] ?? "-",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build events map untuk calendar marker (include all jadwal yang punya tanggal)
    Map<DateTime, List<Map<String, dynamic>>> events = {};
    for (var jadwal in jadwalList) {
      if (jadwal['tanggal'] != null) {
        try {
          DateTime date = DateTime.parse(jadwal['tanggal']);
          date = DateTime(date.year, date.month, date.day);
          if (!events.containsKey(date)) events[date] = [];
          events[date]!.add(jadwal);
        } catch (e) {
          // Skip invalid dates
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 6,
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
          'Jadwal Bimbingan',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
       actions: [
  if (pendingCount > 0)
    const SizedBox.shrink(),
],

      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: primaryColor,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(defaultMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========== CALENDAR ==========
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TableCalendar(
                          locale: 'id_ID',
                          focusedDay: focusedDay,
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                          onDaySelected: (selected, focused) {
                            setState(() {
                              selectedDay = selected;
                              focusedDay = focused;
                            });
                          },
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: dangerColor,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: TextStyle(color: Colors.white),
                            selectedTextStyle: TextStyle(color: Colors.white),
                          ),
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, _) {
                              DateTime normalizedDate = DateTime(date.year, date.month, date.day);
                              if (events.containsKey(normalizedDate)) {
                                return Positioned(
                                  bottom: 1,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: dangerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ========== DAFTAR JADWAL ==========
                      Expanded(
                        child: jadwalList.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 60, color: Colors.grey),
                                    SizedBox(height: 15),
                                    Text(
                                      'Belum ada jadwal bimbingan',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: jadwalList.length,
                                itemBuilder: (context, index) {
                                  return _buildJadwalCard(jadwalList[index]);
                                },
                              ),
                      ),
                    ],
                  ),  
                ),
              ),
            ),

              

      // ===== BOTTOM NAVIGATION =====
      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home,
                label: "Home",
                isActive:
                    controller.currentPage.value == myCtrl.PageTypeDosen.home,
                onTap: () {
                  controller.setPage(myCtrl.PageTypeDosen.home);
                  Get.offAllNamed(Routes.HOME_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.schedule_outlined,
                label: "Jadwal",
                isActive:
                    controller.currentPage.value == myCtrl.PageTypeDosen.jadwal,
                onTap: () {
                  controller.setPage(myCtrl.PageTypeDosen.jadwal);
                  Get.offAllNamed(Routes.JADWAL_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.school_outlined,
                label: "Bimbingan",
                isActive:
                    controller.currentPage.value ==
                    myCtrl.PageTypeDosen.bimbingan,
                onTap: () {
                  controller.setPage(myCtrl.PageTypeDosen.bimbingan);
                  Get.offAllNamed(Routes.BIMBINGAN_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.description_outlined,
                label: "Dokumen",
                isActive:
                    controller.currentPage.value ==
                    myCtrl.PageTypeDosen.dokumen,
                onTap: () {
                  controller.setPage(myCtrl.PageTypeDosen.dokumen);
                  Get.offAllNamed(Routes.DOKUMEN_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.person_outline,
                label: "Profile",
                isActive:
                    controller.currentPage.value ==
                    myCtrl.PageTypeDosen.profile,
                onTap: () {
                  controller.setPage(myCtrl.PageTypeDosen.profile);
                  Get.offAllNamed(Routes.PROFILE_DOSEN);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== Bottom Navigation Item ==========
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.yellow : Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.yellow : Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}