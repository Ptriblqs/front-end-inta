import 'package:get/get.dart';

class MahasiswaController extends GetxController {
  // Contoh data diri yang nanti diisi di halaman "Lengkapi Data"
  var nama = ''.obs;
  var nim = ''.obs;
  var prodi = ''.obs;
  var email = ''.obs;
  var noHp = ''.obs;

  // Fungsi untuk simpan data mahasiswa
  void simpanData({
    required String namaBaru,
    required String nimBaru,
    required String prodiBaru,
    required String emailBaru,
    required String noHpBaru,
  }) {
    nama.value = namaBaru;
    nim.value = nimBaru;
    prodi.value = prodiBaru;
    email.value = emailBaru;
    noHp.value = noHpBaru;

    // Contoh log atau aksi
    print("Data mahasiswa disimpan: $namaBaru ($nimBaru)");
  }
}
