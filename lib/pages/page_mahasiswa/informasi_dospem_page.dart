import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Global imports
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';
import 'package:inta301/controllers/monitoring_dospem_controller.dart';

class InformasiDospemPage extends StatefulWidget {
  const InformasiDospemPage({super.key});

  @override
  State<InformasiDospemPage> createState() => _InformasiDospemPageState();
}

class _InformasiDospemPageState extends State<InformasiDospemPage> {
  final monitoringC = Get.put(MonitoringDospemController());

  @override
  void initState() {
    super.initState();
    monitoringC.fetchDospemAktif();
  }

  String _field(Map<String, dynamic>? m, List<String> keys, String def) {
    if (m == null) return def;
    for (final k in keys) {
      if (m.containsKey(k) && m[k] != null && m[k].toString().isNotEmpty) {
        return m[k].toString();
      }
    }
    return def;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, dangerColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Back + Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        "Informasi Dosen Pembimbing",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Avatar
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: primaryColor),
                ),

                const SizedBox(height: 10),

                // Nama Dosen (dynamic)
                Obx(() {
                  final dospem = monitoringC.dospemAktif.value;
                  final name = _field(dospem, ['nama', 'nama_dosen', 'nama_lengkap'], 'Belum ada dosen pembimbing');
                  final title = _field(dospem, ['jabatan', 'prodi', 'bidang'], 'Dosen');

                  return Column(
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          // ================= BODY DETAIL =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: Obx(() {
                if (monitoringC.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final dospem = monitoringC.dospemAktif.value;

                if (dospem == null) {
                  return const Text(
                    'Belum ada dosen pembimbing aktif.',
                    style: TextStyle(fontSize: 16),
                  );
                }

                final email = _field(dospem, ['email'], '-');
                final phone = _field(dospem, ['telepon', 'no_hp', 'phone'], '-');
                final expertise = _field(dospem, ['bidang_keahlian', 'keahlian', 'expertise'], '-');
           

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informasi Kontak",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInfoTile("Email", email, Icons.email),
                    _buildInfoTile("No. Telepon", phone, Icons.phone),
                    _buildInfoTile("Bidang Keahlian", expertise, Icons.science_outlined),
                  ],
                );
              }),
            ),
          ),
        ],
      ),

      // ================= BOTTOM NAVIGATION =================
      bottomNavigationBar: Container(
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
              label: "Beranda",
              onTap: () => Get.offAllNamed(Routes.home),
            ),
            _BottomNavItem(
              icon: Icons.calendar_month,
              label: "Jadwal",
              onTap: () => Get.offAllNamed(Routes.JADWAL),
            ),
            _BottomNavItem(
              icon: Icons.bar_chart_outlined,
              label: "Kanban",
              onTap: () => Get.offAllNamed(Routes.KANBAN),
            ),
            _BottomNavItem(
              icon: Icons.description_outlined,
              label: "Dokumen",
              onTap: () => Get.offAllNamed(Routes.DOKUMEN),
            ),
            _BottomNavItem(
              icon: Icons.person_outline,
              label: "Profile",
              onTap: () => Get.offAllNamed(Routes.PROFILE),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENT TILE =================
  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 26),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= BOTTOM NAV ITEM =================
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
