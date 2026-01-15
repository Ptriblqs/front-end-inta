import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/pages/page_mahasiswa/cari_dosen_page.dart';


class LengkapiDataPage extends StatefulWidget {
  const LengkapiDataPage({super.key});

  @override
  State<LengkapiDataPage> createState() => _LengkapiDataPageState();
}

class _LengkapiDataPageState extends State<LengkapiDataPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nimController = TextEditingController();
  final TextEditingController prodiController = TextEditingController();
  final TextEditingController keahlianController = TextEditingController();
  String? selectedFileName;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFileName = result.files.single.name;
      });
    }
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: primaryColor.withOpacity(0.2),
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
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
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF88BDF2),
                  Color(0xFF384959),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 40),

                //  Header
                Column(
                  children: const [
                    Text(
                      "Lengkapi Data Diri Anda",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Pastikan data yang Anda isi sudah benar",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // Card putih isi form
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultMargin,
                    vertical: 25,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        "Nama Lengkap",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: namaController,
                        decoration:
                            _fieldDecoration(hintText: "Masukkan nama lengkap"),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "NIM",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nimController,
                        decoration:
                            _fieldDecoration(hintText: "Masukkan NIM Anda"),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Program Studi",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: prodiController,
                        decoration: _fieldDecoration(
                            hintText: "Masukkan program studi Anda"),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Bidang Keahlian",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: keahlianController,
                        decoration: _fieldDecoration(
                            hintText: "Masukkan bidang keahlian Anda"),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Portofolio",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16), 
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  selectedFileName ?? 'Belum ada file dipilih',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16), 
                                  bottomRight: Radius.circular(16), 
                                ),
                              ),
                              child: TextButton(
                                onPressed: pickFile,
                                child: const Text(
                                  "Pilih File",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tombol Simpan 
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAll(() => const CariDosenPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dangerColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16), 
                            ),
                          ),
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
