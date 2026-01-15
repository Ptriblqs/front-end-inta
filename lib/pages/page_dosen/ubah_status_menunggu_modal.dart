import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import '../../services/dokumen_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class UbahStatusMenungguModal extends StatefulWidget {
  final int dokumenId;
  final String judulDokumen;
  final Function(String, String?) onSave;

  const UbahStatusMenungguModal({
    super.key,
    required this.dokumenId,
    required this.judulDokumen,
    required this.onSave,
  });

  @override
  State<UbahStatusMenungguModal> createState() =>
      _UbahStatusMenungguModalState();
}

class _UbahStatusMenungguModalState extends State<UbahStatusMenungguModal> {
  String selectedStatus = "Menunggu";
  final TextEditingController catatanController = TextEditingController();
  bool isLoading = false;
  PlatformFile? pickedFile;

  Future<void> saveStatus() async {
    if (selectedStatus == "Revisi" && catatanController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Catatan revisi harus diisi",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await DokumenService.updateStatusDokumen(
        dokumenId: widget.dokumenId,
        status: selectedStatus,
        catatanRevisi:
            selectedStatus == "Revisi" ? catatanController.text : null,
      );

      setState(() => isLoading = false);

      if (response['success'] == true) {
        widget.onSave(selectedStatus,
            selectedStatus == 'Revisi' ? catatanController.text : null);
        Get.back();

        Get.snackbar(
          '',
          '',
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
          messageText: Text(
            "Status dokumen berhasil diubah menjadi $selectedStatus",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        "Gagal",
        "Gagal mengubah status: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> pickFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(withData: true);
      if (res != null && res.files.isNotEmpty) {
        setState(() {
          pickedFile = res.files.first;
        });
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal memilih file: $e',
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
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

                // Title
                Center(
                  child: Text(
                    "Ubah Status: ${widget.judulDokumen}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Dropdown Status
                const Text("Ubah Status",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButton2<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(
                        value: "Menunggu", child: Text("Menunggu")),
                    DropdownMenuItem(value: "Revisi", child: Text("Revisi")),
                    DropdownMenuItem(
                        value: "Disetujui", child: Text("Disetujui")),
                  ],
                  onChanged: (value) => setState(() => selectedStatus = value!),
                  buttonStyleData: ButtonStyleData(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDEEFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDEEFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                  ),
                  iconStyleData: const IconStyleData(
                      icon: Icon(Icons.keyboard_arrow_down, color: primaryColor)),
                ),
                const SizedBox(height: 20),

                // Catatan jika Revisi
                if (selectedStatus == "Revisi") ...[
                  const Text("Catatan Dosen",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDEEFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryColor.withOpacity(0.3)),
                    ),
                    child: TextField(
                      controller: catatanController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        border: InputBorder.none,
                        hintText: "Tulis catatan revisi di sini...",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // File revisi picker
                  const Text("File Revisi",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDEEFF),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            pickedFile?.name ?? 'Belum ada file dipilih',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                          ),
                          child: const Text(
                            "UPLOAD",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dangerColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SIMPAN",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }
}
