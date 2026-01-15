import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/controllers/ajukan_pembimbing_controller.dart';
import 'package:inta301/pages/detail_pengumuman.dart';

// 🧩 Import halaman mahasiswa
import 'package:inta301/pages/page_mahasiswa/home_page.dart';
import 'package:inta301/pages/page_mahasiswa/jadwal_pages.dart';
import 'package:inta301/pages/page_mahasiswa/kanban_page.dart';
import 'package:inta301/pages/page_mahasiswa/notifikasi_page.dart';
import 'package:inta301/pages/page_mahasiswa/profile_page.dart';
import 'package:inta301/pages/page_mahasiswa/dokumen_page.dart';
import 'package:inta301/pages/page_mahasiswa/form_jadwal.dart';
import 'package:inta301/pages/page_mahasiswa/kelola_akun_page.dart';
import 'package:inta301/pages/page_mahasiswa/informasi_dospem_page.dart';
import 'package:inta301/pages/page_mahasiswa/lengkapi_data_page.dart';
import 'package:inta301/pages/page_mahasiswa/pilih_dosen_page.dart';
import 'package:inta301/pages/page_mahasiswa/dokumen_controller.dart';
import 'package:inta301/pages/page_mahasiswa/mahasiswa_controller.dart';
import 'package:inta301/pages/page_mahasiswa/register_mahasiswa_page.dart';

// 🧩 Import halaman dosen
import 'package:inta301/pages/page_dosen/home_dosen_page.dart';
import 'package:inta301/pages/page_dosen/jadwal_dosen_page.dart';
import 'package:inta301/pages/page_dosen/bimbingan_dosen_page.dart';
import 'package:inta301/pages/page_dosen/dokumen_dosen_page.dart';
import 'package:inta301/pages/page_dosen/profile_dosen_page.dart';
import 'package:inta301/pages/page_dosen/register_dosen_page.dart';
import 'package:inta301/pages/page_dosen/notifikasi_dosen_page.dart';
import 'package:inta301/pages/page_dosen/kelola_akun_dosen_page.dart';

// 🧩 Import halaman umum
import 'package:inta301/pages/login_page.dart';
import 'package:inta301/pages/pilih_role_page.dart';
import 'package:inta301/pages/welcome_page.dart';
import 'package:inta301/pages/lupa_sandi_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.WELCOME;

  static final routes = [
    // 🏠 Halaman Awal
    GetPage(
      name: _Paths.WELCOME,
      page: () => const WelcomePage(),
    ),

    // 🧭 Pilih Role
    GetPage(
      name: _Paths.PILIH_ROLE,
      page: () => const PilihRolePage(),
    ),

    // 🔐 Login
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginPage(),
    ),

     // 🔑 Lupa Sandi (untuk Dosen & Mahasiswa)
    GetPage(
      name: _Paths.LUPA_SANDI, 
      page: () {
        final role = Get.arguments as String? ?? 'mahasiswa';
        return LupaSandiPage(role: role);
      },
    ),

    // 🧾 Register Mahasiswa
    GetPage(
      name: _Paths.REGISTER_MAHASISWA,
      page: () => const RegisterMahasiswaPage(),
    ),

    // 🧾 Register Dosen
    GetPage(
      name: _Paths.REGISTER_DOSEN,
      page: () => const RegisterDosenPage(),
    ),

        GetPage(
      name: Routes.DETAIL_PENGUMUMAN,
      page: () => const DetailPengumumanPage(),
    ),

    // 👨‍🎓 Halaman Mahasiswa
    GetPage(
      name: Routes.home,
      page: () {
        final hasDosen = Get.arguments as bool? ?? true;
        return HomePage(hasDosen: hasDosen);
      },
    ),
    GetPage(
      name: _Paths.JADWAL,
      page: () => JadwalPage(),
    ),
    GetPage(
      name: _Paths.KANBAN,
      page: () {
        final hasDosen = Get.arguments as bool? ?? true;
        return KanbanPage(hasDosen: hasDosen);
      },
    ),
    GetPage(
      name: _Paths.DOKUMEN,
      page: () {
        final hasDosen = Get.arguments as bool? ?? true;
        return DokumenPage(hasDosen: hasDosen);
      },
      binding: BindingsBuilder(() {
        Get.lazyPut<DokumenController>(() => DokumenController());
      }),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () {
        final hasDosen = Get.arguments as bool? ?? true;
        return ProfilePage(hasDosen: hasDosen);
      },
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiPage(),
    ),
    GetPage(
      name: _Paths.FORM_JADWAL,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        final jadwalId = args["jadwalId"] ?? 0;
        final mode = args["mode"] ?? "mahasiswa";
        return FormJadwalBimbinganPage(
          jadwalId: jadwalId,
          mode: mode,
        );
      },
    ),
    GetPage(
      name: _Paths.KELOLA_AKUN,
      page: () => const KelolaAkunPage(),
    ),
    GetPage(
      name: _Paths.INFORMASI_DOSPEM,
      page: () {
        final hasDosen = Get.arguments as bool? ?? true;
        if (hasDosen) {
          return const InformasiDospemPage();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text("Informasi Dosen Pembimbing"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: const Center(
            child: Text("Belum ada dosen pembimbing."),
          ),
        );
      },
    ),
    GetPage(
      name: _Paths.LENGKAPI_DATA,
      page: () => LengkapiDataPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MahasiswaController>(() => MahasiswaController());
      }),
    ),
    GetPage(
      name: _Paths.PILIH_DOSEN,
      page: () => const PilihDosenPage(),
      binding: BindingsBuilder(() {
        Get.put(AjukanPembimbingController());
      }),
    ),


    // 👨‍🏫 Halaman Dosen
    GetPage(
      name: Routes.HOME_DOSEN,
      page: () => const HomeDosenPage(),
    ),
    GetPage(
      name: Routes.JADWAL_DOSEN,
      page: () => const JadwalDosenPage(),
    ),
    GetPage(
      name: Routes.BIMBINGAN_DOSEN,
      page: () => const BimbinganDosenPage(),
    ),
    GetPage(
      name: Routes.DOKUMEN_DOSEN,
      page: () => const DokumenDosenPage(),
    ),
    GetPage(
      name: Routes.PROFILE_DOSEN,
      page: () => ProfileDosenPage(),
    ),

    GetPage(
      name: Routes.DOSEN_NOTIFIKASI,
      page: () => const NotifikasiDosenPage(),
    ),

    GetPage(
      name: Routes.KELOLA_AKUN_DOSEN,
      page: () => const KelolaAkunDosenPage(),
    ),
  ];
}