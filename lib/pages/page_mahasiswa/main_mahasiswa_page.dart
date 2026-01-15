import 'package:flutter/material.dart';

// Halaman yang sudah ada
import 'package:inta301/pages/page_mahasiswa/home_page.dart';
import 'package:inta301/pages/page_mahasiswa/profile_page.dart';
import 'package:inta301/pages/page_mahasiswa/kanban_page.dart';
import 'package:inta301/pages/page_mahasiswa/dokumen_page.dart';

// Placeholder
import 'package:inta301/pages/page_mahasiswa/placeholder_page.dart';

class MainMahasiswaPage extends StatefulWidget {
  const MainMahasiswaPage({super.key});

  @override
  State<MainMahasiswaPage> createState() => _MainMahasiswaPageState();
}

class _MainMahasiswaPageState extends State<MainMahasiswaPage> {
  int _currentIndex = 0;

  // Simulasi status mahasiswa sudah dapat dosen atau belum
  bool hasDosen = false;

  @override
  Widget build(BuildContext context) {
    // Daftar halaman berdasarkan menu
    final List<Widget> pages = [
      // HomePage selalu tampil, bisa menyesuaikan hasDosen untuk menampilkan status
      HomePage(hasDosen: hasDosen),

      // Jadwal (placeholder dulu sampai halaman jadwal tersedia)
      const PlaceholderPage(title: "Jadwal"),

      // Kanban, tampilkan placeholder kalau belum dapat dosen
      hasDosen ? KanbanPage(hasDosen: hasDosen) : const PlaceholderPage(title: "Kanban"),


      // Dokumen, tampilkan placeholder kalau belum dapat dosen
     hasDosen ? DokumenPage(hasDosen: hasDosen) : const PlaceholderPage(title: "Dokumen"),


      // ProfilePage, kirim parameter hasDosen
      ProfilePage(hasDosen: hasDosen),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF384959),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Jadwal",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Kanban",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: "Dokumen",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
