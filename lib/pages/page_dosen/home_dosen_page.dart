import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inta301/services/api_config.dart';
import 'package:intl/intl.dart';

// Import global
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';

// Import controller khusus dosen
import 'package:inta301/controllers/menu_dosen_controller.dart' as myCtrl;

Future<Map<String, dynamic>> _fetchDosenHomeStats() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse('${ApiConfig.baseUrl}/home');
    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      if (body is Map && body['success'] == true && body['data'] != null) {
        final d = body['data'];
        return {
          'mahasiswa_dibimbing': (d['mahasiswa_dibimbing'] ?? 0) as int,
          'dokumen_menunggu': (d['dokumen_menunggu'] ?? 0) as int,
          'bimbingan_disetujui': (d['bimbingan_disetujui'] ?? 0) as int,
          'bimbingan_disetujui_list': d['bimbingan_disetujui_list'] ?? [],
        };
      }
    }
  } catch (e) {
    // ignore and return zeros
  }

  return {
    'mahasiswa_dibimbing': 0,
    'dokumen_menunggu': 0,
    'bimbingan_disetujui': 0,
    'bimbingan_disetujui_list': [],
  };
}

class HomeDosenPage extends GetView<myCtrl.MenuDosenController> {
  const HomeDosenPage({super.key});

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF88BDF2);

    // 🔧 solusi aman: panggil setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setPage(myCtrl.PageTypeDosen.home);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
          'Beranda',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Get.toNamed(Routes.DOSEN_NOTIFIKASI),
          ),
        ],
      ),

      // ================= BODY =================
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    defaultMargin,
                    defaultMargin,
                    defaultMargin,
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= Halo Dosen =================
                      Container(
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
                        child: const Text(
                          "Halo, Dosen! 👋",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ================= Statistik (dari API) =================
                      FutureBuilder<Map<String, dynamic>>(
                        future: _fetchDosenHomeStats(),
                        builder: (context, snapshot) {
                          final loading = !snapshot.hasData;

                          final mahasiswa = loading
                              ? "-"
                              : snapshot.data!['mahasiswa_dibimbing']!.toString();
                          final dokumen = loading
                              ? "-"
                              : snapshot.data!['dokumen_menunggu']!.toString();
                          final bimbingan = loading
                              ? "-"
                              : snapshot.data!['bimbingan_disetujui']!.toString();

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      title: "Mahasiswa",
                                      count: mahasiswa,
                                      icon: Icons.people,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _StatCard(
                                      title: "Pending Review",
                                      count: dokumen,
                                      icon: Icons.pending_actions_outlined,
                                      color: dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      title: "Bimbingan Disetujui",
                                      count: bimbingan,
                                      icon: Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // ================= Alur Pendaftaran TA =================
                      const Text(
                        "Lihat Alur Pendaftaran Tugas Akhir",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Ubah dari ListView horizontal ke Row + Expanded
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: "Buku Panduan",
                              color: mainBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              title: "Jadwal Sidang",
                              color: mainBlue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // ================= Upcoming Bimbingan =================
                      const Text(
                        "Upcoming Bimbingan",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _fetchDosenHomeStats(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Column(
                              children: const [
                                _UpcomingCard(
                                  title: "Memuat...",
                                  date: "-",
                                  time: "-",
                                ),
                              ],
                            );
                          }

                          final list = snapshot.data!['bimbingan_disetujui_list'];

                          if (list == null || (list is List && list.isEmpty)) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Text(
                                'Belum ada bimbingan disetujui.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            );
                          }

                          return Column(
                            children: List<Widget>.from(
                              (list as List).map((item) {
                                final title = (item['judul'] ?? '-') +
                                    ' - ' +
                                    (item['mahasiswa'] ?? '-');
                                final date = item['tanggal'] ?? '-';
                                final time = item['waktu'] ?? '-';

                                return Column(
                                  children: [
                                    _UpcomingCard(
                                      title: title,
                                      date: date,
                                      time: time,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // ================= Bottom Navigation =================
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

// ================== COMPONENTS ==================
class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 14,
              height: 1.2,
              color: dangerColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Color color;

  const _InfoCard({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145, // samakan dengan _StatCard
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.45),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: dangerColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 35), // ⬅️ DIBESARKAN AGAR TOMBOL TURUN

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(100, 35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Lihat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;

  const _UpcomingCard({
    required this.title,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = date;
    String formattedTime = time;

    try {
      if (date.isNotEmpty) {
        final dt = DateTime.parse(date).toLocal();
        formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
      }
    } catch (e) {
      // leave as-is
    }

    try {
      if (time.isNotEmpty) {
        // try parsing HH:mm:ss
        DateTime t = DateFormat('HH:mm:ss').parse(time);
        formattedTime = DateFormat('HH:mm').format(t);
      }
    } catch (e) {
      // fallback: take first 5 chars if possible
      if (time.length >= 5) formattedTime = time.substring(0, 5);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: dangerColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.black, size: 18),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.black, size: 18),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
