import 'package:get/get.dart';

enum PageType { home, jadwal, kanban, dokumen, profile }

class MenuController extends GetxController {
  // Menyimpan halaman saat ini
  var currentPage = PageType.home.obs;

  void setPage(PageType page) {
    currentPage.value = page;
  }
}








