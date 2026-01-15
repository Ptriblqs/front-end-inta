import 'package:get/get.dart';
import '../controllers/menu_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Inisialisasi MenuController global
    Get.put<MenuController>(MenuController());

    // Bisa tambah binding lain jika ada controller lain
    // Contoh: Get.put<AnotherController>(AnotherController());
  }
}
