import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

// Global
import 'package:inta301/shared/shared.dart';

// File di folder yang sama
import 'package:inta301/pages/page_mahasiswa/dokumen_controller.dart';

class DokumenCard extends StatelessWidget {
  final DokumenModel dokumen;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final VoidCallback onDownload;
  final VoidCallback? onViewRevisi;

  const DokumenCard({
    super.key,
    required this.dokumen,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    required this.onDownload,
    this.onViewRevisi,
  });

  // Warna badge status solid seperti punya kawanmu
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "menunggu":
        return Colors.orange;
      case "revisi":
        return Colors.red;
      case "disetujui":
      case "selesai":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = dokumen.status.toLowerCase();

    // Format tanggal
    String formattedDate;
    try {
      formattedDate = DateFormat("d MMMM yyyy, HH.mm", 'id_ID')
          .format(DateTime.parse(dokumen.date));
    } catch (_) {
      formattedDate = dokumen.date;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul & status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dokumen.bab,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: dangerColor,
                      height: 1.3,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Status badge solid
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(dokumen.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dokumen.status,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Badge revisi
                    if (dokumen.revisi > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Revisi ${dokumen.revisi}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tanggal
            Row(
              children: [
                const Icon(Icons.access_time, size: 15, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Keterangan
            Text(
              "Keterangan : ${dokumen.description}",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),
            Container(height: 2, color: primaryColor),
            const SizedBox(height: 4),

            // Tombol aksi
            Row(
              children: [
                // Download — selalu tampil
                IconButton(
                  onPressed: () {
                    onDownload();

                    // Snackbar sukses download warna hijau solid
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
                            fontSize: 16),
                      ),
                      messageText: const Text(
                        "Dokumen berhasil diunduh",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, color: Colors.black87),
                  tooltip: "Download",
                ),

                // DELETE — hanya jika bukan selesai & bukan revisi
                if (status != "selesai" && status != "revisi") ...[
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.black87),
                    tooltip: "Hapus",
                  ),
                ],

                // LIHAT REVISI — hanya jika revisi
                if (status == "revisi" && onViewRevisi != null) ...[
                  IconButton(
                    onPressed: onViewRevisi,
                    icon: const Icon(Icons.remove_red_eye,
                        color: Colors.orange),
                    tooltip: "Lihat Revisi",
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
