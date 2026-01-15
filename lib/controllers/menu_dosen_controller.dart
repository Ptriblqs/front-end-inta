import 'package:get/get.dart';

enum PageTypeDosen { home, jadwal, bimbingan, dokumen, profile }

class MenuDosenController extends GetxController {
  var currentPage = PageTypeDosen.home.obs;

  void setPage(PageTypeDosen page) {
    currentPage.value = page;
  }
}
