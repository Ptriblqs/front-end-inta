  import 'package:flutter/material.dart';
  import 'package:inta301/shared/shared.dart';
  import 'package:inta301/pages/page_mahasiswa/dokumen_controller.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:inta301/services/dokumen_service.dart';
  import 'package:get/get.dart';

  void showRevisiModal(BuildContext context, DokumenModel dokumen) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Catatan Revisi Dosen",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Catatan dosen
                    const Text(
                      "Catatan Dosen",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        dokumen.catatanDosen.isNotEmpty
                            ? dokumen.catatanDosen
                            : "Belum ada catatan dari dosen.",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Unduh dokumen
                    const Text(
                      "Unduh Dokumen",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dokumen.fileName.isNotEmpty
                                  ? dokumen.fileName
                                  : "Belum ada file",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (dokumen.fileName.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.download_rounded, color: Colors.black87),
                              tooltip: "Unduh dokumen",
                              onPressed: () async {
                                try {
                                  await Get.find<DokumenController>().downloadDokumen(dokumen);
                                } catch (e) {
                                  Get.snackbar('Gagal', 'Gagal mengunduh dokumen: $e');
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Tutup
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dangerColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "TUTUP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
