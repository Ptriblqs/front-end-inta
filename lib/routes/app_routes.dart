part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  //  Halaman Umum
  static const WELCOME = _Paths.WELCOME;
  static const PILIH_ROLE = _Paths.PILIH_ROLE;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER_MAHASISWA = _Paths.REGISTER_MAHASISWA;
  static const REGISTER_DOSEN = _Paths.REGISTER_DOSEN;
  static const SPLASH = _Paths.SPLASH; 
  static const LUPA_SANDI = _Paths.LUPA_SANDI;
  static const DETAIL_PENGUMUMAN = '/detail-pengumuman';

  //  Halaman Mahasiswa
  static const home = _Paths.home;
  static const JADWAL = _Paths.JADWAL;
  static const KANBAN = _Paths.KANBAN;
  static const DOKUMEN = _Paths.DOKUMEN;
  static const PROFILE = _Paths.PROFILE;
  static const NOTIFIKASI = _Paths.NOTIFIKASI;
  static const FORM_JADWAL = _Paths.FORM_JADWAL;
  static const KELOLA_AKUN = _Paths.KELOLA_AKUN;
  static const INFORMASI_DOSPEM = _Paths.INFORMASI_DOSPEM;
  static const LENGKAPI_DATA = _Paths.LENGKAPI_DATA;
  static const PILIH_DOSEN = _Paths.PILIH_DOSEN;
  static const AJUKAN_PEMBIMBING = _Paths.AJUKAN_PEMBIMBING; // ✅ TAMBAHKAN INI

  // Halaman Dosen
  static const HOME_DOSEN = _Paths.HOME_DOSEN;
  static const LOGIN_DOSEN = _Paths.LOGIN_DOSEN;
  static const JADWAL_DOSEN = _Paths.JADWAL_DOSEN;
  static const BIMBINGAN_DOSEN = _Paths.BIMBINGAN_DOSEN; 
  static const DOKUMEN_DOSEN = _Paths.DOKUMEN_DOSEN;
  static const PROFILE_DOSEN = _Paths.PROFILE_DOSEN;
  static const DOSEN_NOTIFIKASI = _Paths.DOSEN_NOTIFIKASI;
  static const KELOLA_AKUN_DOSEN = _Paths.kelolaAkunDosen;
  static const DAFTAR_AJUAN_DOSEN = _Paths.DAFTAR_AJUAN_DOSEN; // ✅ TAMBAHKAN INI JUGA
}

abstract class _Paths {
  _Paths._();

  // Halaman Umum
  static const WELCOME = '/welcome';
  static const PILIH_ROLE = '/pilih-role';
  static const LOGIN = '/login';
  static const REGISTER_MAHASISWA = '/register-mahasiswa';
  static const REGISTER_DOSEN = '/register-dosen';
  static const SPLASH = '/splash';
  static const LUPA_SANDI = '/lupa-sandi'; 

  // Halaman Mahasiswa
  static const home = '/home';
  static const JADWAL = '/jadwal';
  static const KANBAN = '/kanban';
  static const DOKUMEN = '/dokumen';
  static const PROFILE = '/profile';
  static const NOTIFIKASI = '/notifikasi';
  static const FORM_JADWAL = '/form-jadwal';
  static const KELOLA_AKUN = '/kelola-akun';
  static const INFORMASI_DOSPEM = '/informasi-dospem';
  static const LENGKAPI_DATA = '/lengkapi-data';
  static const PILIH_DOSEN = '/pilih-dosen';
  static const MENUNGGU_DOSEN = '/menunggu-dosen';
  static const AJUKAN_PEMBIMBING = '/ajukan-pembimbing'; // ✅ TAMBAHKAN INI

  // Halaman Dosen
  static const HOME_DOSEN = '/home-dosen';
  static const LOGIN_DOSEN = '/login-dosen';
  static const JADWAL_DOSEN = '/jadwal-dosen';
  static const BIMBINGAN_DOSEN = '/bimbingan-dosen'; 
  static const DOKUMEN_DOSEN = '/dokumen-dosen';
  static const PROFILE_DOSEN = '/profile-dosen';
  static const DOSEN_NOTIFIKASI = '/dosen-notifikasi'; 
  static const kelolaAkunDosen = '/kelola-akun-dosen';
  static const DAFTAR_AJUAN_DOSEN = '/daftar-ajuan-dosen'; // ✅ TAMBAHKAN INI JUGA
}