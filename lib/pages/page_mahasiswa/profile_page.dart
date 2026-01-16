import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/pages/page_mahasiswa/kelola_akun_page.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';
import 'package:inta301/pages/page_mahasiswa/logout_mahasiswa_modal.dart';
import 'package:inta301/services/auth_service.dart';
import 'package:inta301/controllers/monitoring_dospem_controller.dart';
import 'package:inta301/controllers/menu_controller.dart' as myCtrl;

class ProfilePage extends StatefulWidget {
  final bool hasDosen;

  const ProfilePage({super.key, required this.hasDosen});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final menuC = Get.find<myCtrl.MenuController>();
  final monitoringC = Get.put(MonitoringDospemController());

  final RxBool pushNotification = true.obs;

  String nama = "Nama Lengkap";
  String email = "";
  String nim = "";
  String? fotoUrl;
  bool isLoading = true;

  /// ================= STATUS LOCK =================
  bool get isMenunggu {
    final data = monitoringC.ajuanAktif.value;
    if (data == null) return false;
    return data['status'] == 'menunggu';
  }

  bool get isLocked {
    final data = monitoringC.ajuanAktif.value;
    if (data == null) return false;
    return data['status'] == 'ditolak';
  }

  @override
  void initState() {
    super.initState();
    monitoringC.fetchAjuan();
    _loadProfile();
    menuC.setPage(myCtrl.PageType.profile);
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final result = await AuthService.getMahasiswaProfile();
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          nama = data['nama_lengkap'] ?? nama;
          email = data['email'] ?? '';
          nim = data['nim'] ?? '';
          fotoUrl = data['foto_profil'];
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _goKelolaAkun() async {
    final result = await Get.toNamed(Routes.KELOLA_AKUN);
    if (result == true) {
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  _buildMenu(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 120),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 100, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, dangerColor],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: fotoUrl != null && fotoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                    "$fotoUrl?${DateTime.now().millisecondsSinceEpoch}", // <- tambahkan ini
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 50),
                    ),
                  )
                : const Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 10),
          Text(
            nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Mahasiswa",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// ================= MENU =================
  Widget _buildMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Obx(() => _ProfileMenuItem(
                icon: Icons.notifications_active,
                label: "Push Notifications",
                trailing: 
                Switch(
                 value: pushNotification.value,
                        activeThumbColor: primaryColor,
                        onChanged: (val) => pushNotification.value = val,
                ),
                onTap: () {},
              )),
          const SizedBox(height: 20),
          _ProfileMenuItem(
            icon: Icons.manage_accounts,
            label: "Kelola Akun",
            onTap: _goKelolaAkun,
          ),
          const SizedBox(height: 20),
          widget.hasDosen
              ? _ProfileMenuItem(
                  icon: Icons.person_search,
                  label: "Informasi Dosen Pembimbing",
                  onTap: () => Get.toNamed(Routes.INFORMASI_DOSPEM),
                )
              : _ProfileMenuItem(
                  icon: Icons.search,
                  label: "Cari Dosen Pembimbing",
                  onTap: () => Get.toNamed(Routes.PILIH_DOSEN),
                ),
          const SizedBox(height: 20),
          _ProfileMenuItem(
            icon: Icons.logout,
            label: "Keluar",
            onTap: () => showLogoutMahasiswaModal(context),
          ),
        ],
      ),
    );
  }

  /// ================= BOTTOM NAV (LOCKED) =================
  Widget _buildBottomNav() {
    return Obx(() {
      final lock = isMenunggu || isLocked;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, dangerColor],
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
              isDisabled: lock,
              onTap: lock ? null : () => Get.offAllNamed(Routes.JADWAL),
            ),
            _BottomNavItem(
              icon: Icons.bar_chart_outlined,
              label: "Kanban",
              isDisabled: lock,
              onTap: lock ? null : () => Get.offAllNamed(Routes.KANBAN),
            ),
            _BottomNavItem(
              icon: Icons.description_outlined,
              label: "Dokumen",
              isDisabled: lock,
              onTap: lock ? null : () => Get.offAllNamed(Routes.DOKUMEN),
            ),
            _BottomNavItem(
              icon: Icons.person_outline,
              label: "Profile",
              isActive: true,
              onTap: () {},
            ),
          ],
        ),
      );
    });
  }
}

/// ================= PROFILE MENU ITEM =================
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// ================= BOTTOM NAV ITEM =================
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
    final color = isDisabled
        ? Colors.grey.shade400
        : isActive
            ? Colors.yellow
            : Colors.white;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
