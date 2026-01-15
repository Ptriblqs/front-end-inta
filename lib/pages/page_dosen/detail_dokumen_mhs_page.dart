import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/services/dokumen_service.dart';
import 'package:inta301/shared/shared.dart';

import 'package:inta301/controllers/dosen_dokumen_controller.dart';
import 'package:inta301/pages/page_dosen/ubah_status_menunggu_modal.dart';
import 'package:inta301/pages/page_dosen/revisi_dokumen_modal.dart';

class DokumenMahasiswaPage extends StatefulWidget {
  final String nama;
  final String nim;
  final String jurusan;
  final int mahasiswaId;

  const DokumenMahasiswaPage({
    super.key,
    required this.nama,
    required this.nim,
    required this.jurusan,
    required this.mahasiswaId,
  });

  @override
  State<DokumenMahasiswaPage> createState() => _DokumenMahasiswaPageState();
}

class _DokumenMahasiswaPageState extends State<DokumenMahasiswaPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late DokumenDosenController controller;

  @override
  void initState() {
    super.initState();
    // Use existing controller if already registered, otherwise create it.
    controller = Get.isRegistered<DokumenDosenController>()
        ? Get.find<DokumenDosenController>()
        : Get.put(DokumenDosenController());

    tabController = TabController(length: 3, vsync: this);

    controller.fetchDokumenMahasiswa(
      mahasiswaId: widget.mahasiswaId,
      status: "Menunggu",
    );

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        final status = tabController.index == 0
            ? "Menunggu"
            : tabController.index == 1
                ? "Revisi"
                : "Disetujui";

        controller.fetchDokumenMahasiswa(
          mahasiswaId: widget.mahasiswaId,
          status: status,
        );
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Menunggu":
        return Colors.orange;
      case "Revisi":
        return Colors.red;
      case "Disetujui":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Dokumen Tugas Akhir',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(defaultMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Dokumen Mahasiswa",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        child: Icon(Icons.person, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded( 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 16
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${widget.nim} - ${widget.jurusan}",
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // TABBAR
            TabBar(
              controller: tabController,
              indicatorColor: primaryColor,
              labelColor: Colors.black,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Menunggu"),
                Tab(text: "Revisi"),
                Tab(text: "Disetujui"),
              ],
            ),

            const Divider(height: 1),

            Expanded(
              child: Obx(() {
                if (controller.isLoadingDokumen.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.dokumenList.isEmpty) {
                  return const Center(child: Text("Tidak ada dokumen"));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(defaultMargin),
                  itemCount: controller.dokumenList.length,
                  itemBuilder: (context, index) {
                    final d = controller.dokumenList[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                d["bab"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, 
                                  vertical: 4
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(d["status"]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  d["status"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("Judul: ${d["judul"]}"),
                          Text("Deskripsi: ${d["deskripsi"]}"),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download_rounded),
                                tooltip: "Download Dokumen",
                                onPressed: () async {
                                  try {
                                    await DokumenService.downloadDokumen(
                                      id: int.parse(d["id"].toString()),
                                      savePath: d["judul"] ?? "dokumen",
                                    );

                                    Get.snackbar(
                                      "Berhasil",
                                      "Dokumen berhasil diunduh",
                                      backgroundColor: Colors.green,     
                                      colorText: Colors.white,           
                                      snackPosition: SnackPosition.TOP,  
                                      snackStyle: SnackStyle.FLOATING,   
                                      margin: const EdgeInsets.all(16),
                                    );
                                  } catch (e) {
                                    Get.snackbar(
                                      "Gagal",
                                      "Gagal mengunduh dokumen",
                                      backgroundColor: Colors.red,        
                                      colorText: Colors.white,         
                                      snackPosition: SnackPosition.TOP,
                                      snackStyle: SnackStyle.FLOATING,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  }
                                },
                              ),
    
                              if (d["status"] == "Menunggu")
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => UbahStatusMenungguModal(
                                        dokumenId: int.parse(d["id"].toString()),
                                        judulDokumen: d["bab"],
                                        onSave: (status, catatan) {
                                          controller.fetchDokumenMahasiswa(
                                            mahasiswaId: widget.mahasiswaId,
                                            status: "Menunggu",
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}