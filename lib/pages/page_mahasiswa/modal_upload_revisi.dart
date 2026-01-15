import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:inta301/shared/shared.dart';
import '../../services/dokumen_service.dart';
import 'dokumen_controller.dart';

class UploadRevisiModal extends StatefulWidget {
  final int dokumenId;
  final String judulDokumen;
  final String catatanRevisi;

  const UploadRevisiModal({
    super.key,
    required this.dokumenId,
    required this.judulDokumen,
    required this.catatanRevisi,
  });

  @override
  State<UploadRevisiModal> createState() => _UploadRevisiModalState();
}

class _UploadRevisiModalState extends State<UploadRevisiModal> {
  final TextEditingController deskripsiController = TextEditingController();
  PlatformFile? selectedFile;
  String? fileName;
  bool isUploading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.first;
        fileName = result.files.first.name;
      });
    }
  }

  Future<void> uploadRevisi() async {
    if (selectedFile == null) {
      Get.snackbar(
        "Error",
        "Pilih file terlebih dahulu",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final response = await DokumenService.uploadRevisi(
        dokumenId: widget.dokumenId,
        file: selectedFile!,
        deskripsi: deskripsiController.text,
      );

      setState(() => isUploading = false);

      if (response['success'] == true) {
        // Refresh dokumen list
        Get.find<DokumenController>().refresh();
        
        Get.back();
        Get.snackbar(
          "",
          "",
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          titleText: const Text(
            "Berhasil",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          messageText: const Text(
            "Dokumen revisi berhasil diupload",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isUploading = false);
      Get.snackbar(
        "Gagal",
        "Gagal mengupload dokumen: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Upload Dokumen Revisi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Judul dokumen
            Text(
              widget.judulDokumen,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: dangerColor,
              ),
            ),
            const SizedBox(height: 12),

            // Catatan revisi dari dosen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Catatan Revisi dari Dosen:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.catatanRevisi,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // File picker
            GestureDetector(
              onTap: pickFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(12),
                  color: primaryColor.withOpacity(0.05),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName ?? "Pilih file revisi (PDF, DOC, DOCX)",
                        style: TextStyle(
                          color: fileName != null ? Colors.black : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi perubahan
            TextField(
              controller: deskripsiController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Deskripsi Perubahan (Opsional)",
                hintText: "Jelaskan perubahan yang telah dilakukan...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Upload
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUploading ? null : uploadRevisi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Upload Revisi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    deskripsiController.dispose();
    super.dispose();
  }
}