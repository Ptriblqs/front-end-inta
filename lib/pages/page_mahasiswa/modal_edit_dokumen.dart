import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:inta301/pages/page_mahasiswa/dokumen_controller.dart';
import 'package:inta301/shared/shared.dart';

class EditModal extends StatefulWidget {
  final DokumenModel dokumen;

  const EditModal({super.key, required this.dokumen});

  @override
  State<EditModal> createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  final _formKey = GlobalKey<FormState>();
  final DokumenController controller = Get.find();

  late TextEditingController _titleController;
  late TextEditingController _babController;
  late TextEditingController _descController;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.dokumen.title);
    _babController = TextEditingController(text: widget.dokumen.bab);
    _descController = TextEditingController(text: widget.dokumen.description);
    _fileName = widget.dokumen.fileName;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      controller.editDokumen(
        DokumenModel(
          title: _titleController.text,
          bab: _babController.text,
          description: _descController.text,
          status: widget.dokumen.status,
          fileName: _fileName ?? widget.dokumen.fileName,
          date: widget.dokumen.date,
          catatanDosen: widget.dokumen.catatanDosen,
          fileRevisi: widget.dokumen.fileRevisi,
        ),
      );
      Get.back();
      Get.snackbar(
        "", // Kosongkan title karena kita pakai titleText
        "",
        backgroundColor: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        titleText: const Text(
          "Berhasil",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: const Text(
          "Dokumen berhasil diperbarui",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
  }

  void _deleteDokumen() {
    controller.deleteDokumen(widget.dokumen);
    Get.back();
    Get.snackbar(
      "", // Kosongkan title karena kita pakai titleText
      "",
      backgroundColor: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      titleText: const Text(
        "Dihapus",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: const Text(
        "Dokumen berhasil dihapus",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus dokumen ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDokumen();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
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
            child: Form(
              key: _formKey,
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

                  const Center(
                    child: Text(
                      "Edit File Dokumen",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // File Picker
                  const Text("File Dokumen", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            border: Border.all(color: primaryColor.withOpacity(0.3)),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            _fileName ?? 'Belum ada file dipilih',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                          child: const Text("Pilih File", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildFieldLabel("Nama Dokumen"),
                  _buildTextFormField(_titleController, "Masukkan nama dokumen"),

                  const SizedBox(height: 16),
                  _buildFieldLabel("BAB"),
                  _buildTextFormField(_babController, "Contoh: BAB I"),

                  const SizedBox(height: 16),
                  _buildFieldLabel("Keterangan"),
                  _buildTextFormField(_descController, "Opsional", maxLines: 2),

                  const SizedBox(height: 25),
                  // Tombol Hapus & Simpan sejajar
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _confirmDelete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dangerColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("HAPUS",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("SIMPAN",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty && maxLines == 1 ? "Field wajib diisi" : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: primaryColor.withOpacity(0.2),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      ),
    );
  }
}
