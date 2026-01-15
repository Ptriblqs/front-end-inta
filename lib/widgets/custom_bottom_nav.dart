import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shared/shared.dart';
import '../routes/app_pages.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
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
            isActive: selectedIndex == 0,
            onTap: () => Get.offAllNamed(Routes.home),
          ),
          _BottomNavItem(
            icon: Icons.calendar_today_outlined,
            label: "Jadwal",
            isActive: selectedIndex == 1,
            onTap: () => Get.offAllNamed(Routes.JADWAL),
          ),
          _BottomNavItem(
            icon: Icons.bar_chart_outlined,
            label: "Kanban",
            isActive: selectedIndex == 2,
            onTap: () => Get.offAllNamed(Routes.KANBAN),
          ),
          _BottomNavItem(
            icon: Icons.file_copy_outlined,
            label: "Dokumen",
            isActive: selectedIndex == 3,
            onTap: () => Get.offAllNamed(Routes.DOKUMEN),
          ),
          _BottomNavItem(
            icon: Icons.person_outline,
            label: "Profile",
            isActive: selectedIndex == 4,
            onTap: () => Get.offAllNamed(Routes.PROFILE),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white70,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
