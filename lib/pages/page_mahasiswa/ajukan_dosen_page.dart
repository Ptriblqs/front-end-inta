import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/dosen_model.dart';
import '../../controllers/ajukan_pembimbing_controller.dart';
import 'ajukan_dosen_terkirim_page.dart';

class AjukanDosenPage extends StatefulWidget {
  final DosenModel dosen;

  const AjukanDosenPage({super.key, required this.dosen});

  @override
  State<AjukanDosenPage> createState() => _AjukanDosenPageState();
}

class _AjukanDosenPageState extends State<AjukanDosenPage> {
  final AjukanPembimbingController controller =
      Get.put(AjukanPembimbingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// 🔹 HEADER GRADIENT
          Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF88BDF2), Color(0xFF384959)],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 45),
                const Center(
                  child: Text(
                    "Pengajuan Dosen",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                /// 🔹 CONTENT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      _label("Dosen Pembimbing"),
                      _dosenBox(),

                      const SizedBox(height: 16),

                      _label("Alasan Memilih Dosen"),
                      _buildField(
                        controller: controller.alasanController,
                        hint:
                            "Contoh: sesuai dengan bidang keahlian dan topik penelitian",
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      _label("Rencana Judul TA"),
                      _buildField(
                        controller: controller.judulController,
                        hint: "Masukkan rencana judul tugas akhir",
                      ),

                      const SizedBox(height: 16),

                      _label("Deskripsi TA"),
                      _buildField(
                        controller: controller.deskripsiController,
                        hint:
                            "Jelaskan gambaran umum, tujuan, dan metode penelitian",
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      _label("Upload Portofolio"),
                      const SizedBox(height: 8),
                      _uploadBox(),

                      const SizedBox(height: 30),

                      /// 🔹 BUTTON KIRIM
                      Obx(() {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    if (!_validateInput()) return;

                                    final prefs =
                                        await SharedPreferences.getInstance();

                                    int? idMahasiswa =
                                        prefs.getInt('mahasiswa_id') ??
                                        prefs.getInt('id_mahasiswa') ??
                                        prefs.getInt('profile_id');

                                    if (idMahasiswa == null ||
                                        idMahasiswa == 0) {
                                      Get.snackbar(
                                        "Error",
                                        "ID Mahasiswa tidak ditemukan. Silakan login ulang.",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }

                                    await controller.ajukanBimbingan(
                                      idMahasiswa: idMahasiswa,
                                      dosen: widget.dosen,
                                    );

                                    if (!controller.isLoading.value) {
                                      Get.off(() =>
                                          const AjukanDosenTerkirimPage());
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF384959),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Kirim",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      }),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 BACK BUTTON
          Positioned(
            top: 50,
            left: 15,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 VALIDASI INPUT
  bool _validateInput() {
    if (controller.alasanController.text.trim().isEmpty ||
        controller.judulController.text.trim().isEmpty ||
        controller.deskripsiController.text.trim().isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Semua field wajib diisi",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (controller.fileName.value.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Portofolio wajib diupload",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// 🔹 LABEL
  static Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  /// 🔹 BOX DOSEN (PLACEHOLDER MANUAL)
  Widget _dosenBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF88BDF2).withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        widget.dosen.namaLengkap.isEmpty
            ? "Dosen belum dipilih"
            : widget.dosen.namaLengkap,
        style: TextStyle(
          color: widget.dosen.namaLengkap.isEmpty
              ? Colors.grey
              : Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 🔹 UPLOAD BOX
  Widget _uploadBox() {
    return Obx(() {
      String displayText = controller.fileName.value.isEmpty
          ? 'Belum ada file dipilih'
          : controller.fileName.value;

      return Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: const Color(0xFF88BDF2).withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                border: Border.all(
                  color: const Color(0xFF88BDF2).withOpacity(0.3),
                ),
              ),
              child: Text(
                displayText,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: controller.fileName.value.isEmpty
                      ? Colors.grey
                      : Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: controller.pilihPortofolio,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF88BDF2),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              child: const Text(
                "UPLOAD",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 🔹 TEXTFIELD DENGAN PLACEHOLDER
  static Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFF88BDF2).withOpacity(0.2),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
