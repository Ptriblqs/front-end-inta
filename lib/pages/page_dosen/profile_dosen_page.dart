import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';
import 'package:inta301/pages/page_dosen/logout_dosen_modal.dart';
import 'package:inta301/services/auth_service.dart';

class ProfileDosenPage extends StatefulWidget {
  const ProfileDosenPage({super.key});

  @override
  State<ProfileDosenPage> createState() => _ProfileDosenPageState();
}

class _ProfileDosenPageState extends State<ProfileDosenPage> {
  final RxInt selectedIndex = 4.obs;
  final RxBool pushNotification = true.obs;

  String nama = "Nama Lengkap";
  String email = "";
  String nidn = "";
  String? fotoUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      final result = await AuthService.getDosenProfile();
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          nama = data['nama_lengkap'] ?? nama;
          email = data['email'] ?? '';
          nidn = data['nidn'] ?? '';
          fotoUrl = data['foto_profil'];
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER DOSEN =====
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, dangerColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: fotoUrl != null && fotoUrl!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      fotoUrl!,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person, size: 50),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: primaryColor,
                                    size: 60,
                                  ),
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
                            "Dosen",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // ===== MENU =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Obx(
                    () => _ProfileMenuItem(
                      icon: Icons.notifications,
                      label: "Push Notifications",
                      trailing: Switch(
                        value: pushNotification.value,
                        activeThumbColor: primaryColor,
                        onChanged: (val) => pushNotification.value = val,
                      ),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 20),

                  _ProfileMenuItem(
                    icon: Icons.manage_accounts,
                    label: "Kelola Akun",
                    onTap: () async {
                      final result =
                          await Get.toNamed(Routes.KELOLA_AKUN_DOSEN);
                      if (result == true) {
                        _loadProfile();
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  _ProfileMenuItem(
                    icon: Icons.logout,
                    label: "Keluar",
                    onTap: () => showLogoutDosenModal(context),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 120,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAV DOSEN =====
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
                isActive: selectedIndex.value == 0,
                onTap: () {
                  selectedIndex.value = 0;
                  Get.offAllNamed(Routes.HOME_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.schedule_outlined,
                label: "Jadwal",
                isActive: selectedIndex.value == 1,
                onTap: () {
                  selectedIndex.value = 1;
                  Get.offAllNamed(Routes.JADWAL_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.school_outlined,
                label: "Bimbingan",
                isActive: selectedIndex.value == 2,
                onTap: () {
                  selectedIndex.value = 2;
                  Get.offAllNamed(Routes.BIMBINGAN_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.description_outlined,
                label: "Dokumen",
                isActive: selectedIndex.value == 3,
                onTap: () {
                  selectedIndex.value = 3;
                  Get.offAllNamed(Routes.DOKUMEN_DOSEN);
                },
              ),
              _BottomNavItem(
                icon: Icons.person_outline,
                label: "Profile",
                isActive: selectedIndex.value == 4,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= MENU ITEM =================
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: primaryColor.withOpacity(0.9),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                  ),
                ),
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ================= BOTTOM NAV ITEM =================
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
