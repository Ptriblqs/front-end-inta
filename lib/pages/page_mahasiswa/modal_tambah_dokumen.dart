import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:inta301/shared/shared.dart';
import '../../services/dokumen_service.dart';
import 'dokumen_controller.dart';

class TambahDokumenModal extends StatefulWidget {
  final BuildContext parentContext;

  const TambahDokumenModal({super.key, required this.parentContext});

  @override
  State<TambahDokumenModal> createState() => _TambahDokumenModalState();
}

class _TambahDokumenModalState extends State<TambahDokumenModal> {
  final TextEditingController babController = TextEditingController();
  final TextEditingController subBabController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  Uint8List? fileBytes;
  String? filePath;
  String? fileName;

  bool isUploading = false;

  final String dosenId = "1"; // TODO: ganti dengan sistem login

  // ================= BAB & SUB-BAB =================
  final List<String> babList = [
    'BAB I', 'BAB II', 'BAB III', 'BAB IV', 'BAB V'
  ];

  final Map<String, List<String>> subBabMap = {
    'BAB I': [
      '1.1 Latar Belakang',
      '1.2 Rumusan Masalah',
      '1.3 Tujuan',
      '1.4 Batasan Masalah',
      '1.5 Manfaat',
    ],
    'BAB II': [
      '2.1 Penelitian Terkait',
      '2.2 Landasan Teori',
      '2.3 Metode Pengembangan Produk',
    ],
    'BAB III': ['3.1 Analisis Kebutuhan', '3.2 Perancangan'],
    'BAB IV': ['4.1 Hasil Implementasi', '4.2 Pengujian User Acceptance Testing (UAT)'],
    'BAB V': ['5.1 Kesimpulan', '5.2 Saran'],
  };

  String? selectedBab;
  String? selectedSubBab;

  // ================= PICK FILE =================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: kIsWeb,
    );

    if (result != null) {
      final file = result.files.single;

      setState(() {
        fileName = file.name;
        if (kIsWeb) {
          fileBytes = file.bytes;
          filePath = null;
        } else {
          filePath = file.path;
          fileBytes = null;
        }
      });
    }
  }

  // ================= UPLOAD =================
  Future<void> uploadDokumen() async {
    if (selectedBab == null || selectedSubBab == null || fileName == null) {
      Get.snackbar(
        "Gagal",
        "Sub-bab, Bab, dan file wajib diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final pf = PlatformFile(
        name: fileName!,
        bytes: fileBytes,
        path: filePath,
        size: fileBytes?.lengthInBytes ?? 0,
      );

      final resp = await DokumenService.uploadDokumen(
        dosenId: dosenId,
        judul: selectedSubBab!,
        bab: selectedBab!,
        deskripsi: deskripsiController.text,
        file: pf,
      );

      setState(() => isUploading = false);

      if (resp is Map && resp['alert'] == true) {
        final msg = resp['message'] ?? 'Perhatian dari server.';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Perhatian', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text(msg.toString(), style: const TextStyle(color: Colors.black87)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        return;
      }

      if (resp['success'] == true) {
        Get.find<DokumenController>().refresh();
        Get.back();

        Get.snackbar(
          "Berhasil",
          "Dokumen berhasil diupload",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Gagal",
          resp['message'] ?? "Gagal upload dokumen",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() => isUploading = false);
      Get.snackbar(
        "Error",
        "Gagal upload dokumen: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _buildLabel("Bab"),
            _buildBabDropdown(),
            const SizedBox(height: 16),
            _buildLabel("Sub-Bab / Judul"),
            _buildSubBabDropdown(),
            const SizedBox(height: 16),
            _buildLabel("Deskripsi"),
            _field(deskripsiController, "Deskripsi", "Opsional (tidak wajib)", maxLines: 3),
            const SizedBox(height: 16),
            _filePicker(),
            _uploadButton(),
          ],
        ),
      ),
    );
  }

  // ================= WIDGETS =================
  Widget _header() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Upload Dokumen Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
        ],
      );

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black)),
    );
  }

  Widget _buildBabDropdown() {
    return DropdownButtonFormField2<String>(
      value: selectedBab,
      isExpanded: true,
      hint: const Text("Pilih Bab", style: TextStyle(color: Colors.black54)),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF88BDF2).withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF88BDF2).withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF88BDF2).withOpacity(0.3))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: Color(0xFF88BDF2), width: 1.5)),
      ),
      buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,
        decoration: BoxDecoration(color: const Color(0xFFDDEEFF), borderRadius: BorderRadius.circular(16)),
      ),
      items: babList.map((bab) => DropdownMenuItem<String>(value: bab, child: Text(bab))).toList(),
      onChanged: (value) {
        setState(() {
          selectedBab = value;
          babController.text = value ?? '';
          selectedSubBab = null;
          subBabController.clear();
        });
      },
    );
  }

  Widget _buildSubBabDropdown() {
    final subBabOptions = selectedBab != null ? (subBabMap[selectedBab] ?? []) : [];

    return DropdownButtonFormField2<String>(
      value: selectedSubBab,
      isExpanded: true,
      hint: Text(
        selectedBab == null ? "Pilih Bab terlebih dahulu" : "Pilih Sub-Bab",
        style: TextStyle(color: selectedBab == null ? Colors.grey : Colors.black54),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF88BDF2).withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF88BDF2).withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF88BDF2).withOpacity(0.3))),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: Color(0xFF88BDF2), width: 1.5)),
      ),
      buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,
        decoration: BoxDecoration(color: const Color(0xFFDDEEFF), borderRadius: BorderRadius.circular(16)),
      ),
      items: subBabOptions.map((sub) => DropdownMenuItem<String>(value: sub, child: Text(sub))).toList(),
      onChanged: selectedBab == null ? null : (value) {
        setState(() {
          selectedSubBab = value;
          subBabController.text = value ?? '';
        });
      },
    );
  }

  Widget _field(TextEditingController c, String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFF88BDF2).withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF88BDF2).withOpacity(0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFF88BDF2).withOpacity(0.3))),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(color: Color(0xFF88BDF2), width: 1.5)),
        ),
      ),
    );
  }

  Widget _filePicker() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("File Dokumen"),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: const Color(0xFF88BDF2).withOpacity(0.3),
                    border: Border.all(color: const Color(0xFF88BDF2).withOpacity(0.3), width: 1.5),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                  ),
                  child: Text(
                    fileName ?? 'Belum ada file dipilih',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fileName != null ? Colors.black : Colors.grey),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF88BDF2),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    ),
                  ),
                  child: const Text("Pilih File", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _uploadButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isUploading ? null : uploadDokumen,
          style: ElevatedButton.styleFrom(
            backgroundColor: dangerColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isUploading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Upload",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    babController.dispose();
    subBabController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }
}
