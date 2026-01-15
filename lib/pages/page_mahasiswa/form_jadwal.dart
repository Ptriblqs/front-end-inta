import 'package:flutter/material.dart';
import 'package:get/get.dart';

// global
import 'package:inta301/shared/shared.dart';

class FormJadwalBimbinganPage extends StatefulWidget {
  final int jadwalId;
  final String mode; // 'mahasiswa' atau 'dosen'

  const FormJadwalBimbinganPage({
    super.key,
    required this.jadwalId,
    required this.mode,
  });

  @override
  State<FormJadwalBimbinganPage> createState() =>
      _FormJadwalBimbinganPageState();
}

class _FormJadwalBimbinganPageState extends State<FormJadwalBimbinganPage> {
  InputDecoration _modalFieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint.isEmpty ? null : hint,
    hintStyle: const TextStyle(
      fontFamily: 'Poppins',
      color: Colors.black54,
    ),
    filled: true,
    fillColor: primaryColor.withOpacity(0.15), // warna khusus modal
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}

  final _judulController = TextEditingController();
  final _dosenController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _waktuController = TextEditingController();
  final _lokasiController = TextEditingController();
 
  @override
  void initState() {
    super.initState();
    _judulController.text = "Diskusi Revisi BAB II";
    _dosenController.text = "Sukma Evadini, S.T., M.Kom";
    _tanggalController.text = "Senin, 21 Oktober 2025";
    _waktuController.text = "09:00";
    _lokasiController.text = "Ruang B-203";
  }

// ======================================================
//                     MODAL TOLAK
// ======================================================
void _showTolakModal(BuildContext context) {
  final alasanCtrl = TextEditingController();

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
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Center(
                    child: Text(
                      "Alasan Penolakan Jadwal",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Tuliskan alasan Anda menolak jadwal ini:",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: alasanCtrl,
                    maxLines: 4,
                   decoration: _modalFieldDecoration(
  "Masukkan alasan penolakan..."
),

                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerColor, // tombol merah
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          "Ditolak",
                          "Jadwal ditolak dan dikirim ke mahasiswa",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      child: const Text(
                        "Kirim Penolakan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // teks lebih tegas
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  // ======================================================
  //                     BUILD UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final bool isDosenMode = widget.mode == 'dosen';

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          isDosenMode ? "Ajuan Dosen" : "Ajukan Jadwal Bimbingan",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ===================== CARD STYLE =====================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildLabeledField("Judul Bimbingan", _judulController,
                      readOnly: true),
                  _buildLabeledField("Dosen Pembimbing", _dosenController,
                      readOnly: true),
                  _buildTanggalField(true),
                  _buildLabeledField("Waktu", _waktuController, readOnly: true),
                  _buildLabeledField("Lokasi", _lokasiController, readOnly: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===================== BUTTON =====================
            // Only show dosen action buttons; mahasiswa 'Ajukan' removed
            if (isDosenMode) _buildButtonDosen(),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //               COMPONENT / WIDGET BUILDER
  // ======================================================
  Widget _buildButtonAjukan() {
    // Ajukan button removed — return an empty widget to satisfy return type
    return const SizedBox.shrink();
  }

  Widget _buildButtonDosen() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.snackbar(
                "Diterima",
                "Jadwal diterima mahasiswa",
                backgroundColor: Colors.white,
                colorText: Colors.black,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                icon: const Icon(Icons.check_circle_outline, color: Colors.black),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Terima",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showTolakModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Tolak",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
    {bool readOnly = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold, // lebih tegas
            fontSize: 14,
            color: Colors.black, // hitam pekat
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold, // teks field juga tegas
            color: Colors.black, // hitam pekat
          ),
          decoration: _fieldDecoration(""),
        ),
      ],
    ),
  );
}


  Widget _buildTanggalField(bool readOnly) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tanggal",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _tanggalController,
          readOnly: true,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.bold, // bikin tulisannya lebih tegas
            color: Colors.black87,       // warna hitam tegas
          ),
          decoration: _fieldDecoration("").copyWith(
            suffixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}


  // ======================================================
  //                   DECORATION
  // ======================================================
  InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint.isEmpty ? null : hint,
    hintStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.black54),
    filled: true,
    fillColor: Colors.grey.shade200, // abu muda
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}
}
