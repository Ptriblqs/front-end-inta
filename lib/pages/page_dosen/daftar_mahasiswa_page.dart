import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/controllers/daftar_mahasiswa_controller.dart';
import 'package:inta301/pages/page_dosen/mahasiswa_card.dart';
import 'package:inta301/shared/shared.dart';
import 'package:intl/intl.dart';
import '../../pages/page_dosen/mahasiswa_card.dart';
import '../../pages/page_dosen/ajukan_bimbingan_modal.dart';

class DaftarMahasiswaPage extends StatelessWidget {
  const DaftarMahasiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DaftarMahasiswaController controller =
        Get.find<DaftarMahasiswaController>();


    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Bimbingan Mahasiswa',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Navigation
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildTab('Daftar\nMahasiswa', isActive: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTab('Daftar\nBimbingan', isActive: false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTab('Daftar\nAjuan', isActive: false),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.loadMahasiswa,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.mahasiswaList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada mahasiswa bimbingan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadMahasiswa,
                color: primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.mahasiswaList.length,
                  itemBuilder: (context, index) {
                    final mahasiswa = controller.mahasiswaList[index];
                    
                    return MahasiswaCard(
                      nama: mahasiswa.namaMahasiswa,
                      nim: mahasiswa.nim,
                      prodi: mahasiswa.programStudi,
                      onAjukanBimbingan: () {
                        _showAjukanBimbinganModal(
                          context: context,
                          mahasiswaId: mahasiswa.mahasiswaId,
                          namaMahasiswa: mahasiswa.namaMahasiswa,
                          controller: controller,
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? primaryColor : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.grey[700],
          height: 1.2,
        ),
      ),
    );
  }

  void _showAjukanBimbinganModal({
    required BuildContext context,
    required int mahasiswaId,
    required String namaMahasiswa,
    required DaftarMahasiswaController controller,
  }) {
    final judulCtrl = TextEditingController();
    final tanggalCtrl = TextEditingController();
    final waktuCtrl = TextEditingController();
    final lokasiCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    
                    // Title
                    const Center(
                      child: Text(
                        'Ajukan Bimbingan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Nama Mahasiswa
                    Center(
                      child: Text(
                        namaMahasiswa,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    // Fields
                    _buildField('Judul Bimbingan', judulCtrl),
                    _buildTanggalField(context, tanggalCtrl),
                    _buildField('Waktu (contoh: 10:30)', waktuCtrl),
                    _buildField('Lokasi', lokasiCtrl),
                    const SizedBox(height: 25),
                    
                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.createJadwal(
                            mahasiswaId: mahasiswaId,
                            judulBimbingan: judulCtrl.text.trim(),
                            tanggal: tanggalCtrl.text.trim(),
                            waktu: waktuCtrl.text.trim(),
                            lokasi: lokasiCtrl.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dangerColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Ajukan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: primaryColor.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTanggalField(BuildContext context, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanggal',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
                locale: const Locale('id', 'ID'),
              );
              if (picked != null) {
                ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: ctrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: primaryColor.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}