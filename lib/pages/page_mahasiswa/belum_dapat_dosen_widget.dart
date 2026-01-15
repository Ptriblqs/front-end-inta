import 'package:flutter/material.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/pages/page_mahasiswa/ajukan_dosen_page.dart';
import '../../models/dosen_model.dart';

class BelumDapatDosenWidget extends StatelessWidget {
  const BelumDapatDosenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholderDosen = DosenModel(
      id: 0,
      namaLengkap: "Belum ada dosen",
      email: "-",
      program_studi: "-",
      kuota: 0,
      fotoProfil: "",
      prodi: "-",                   // field baru
      bimbingan: "0 dari 0 Mahasiswa", // field baru
      jumlahBimbingan: 0,           // field baru
      maksimalBimbingan: 0,         // field baru
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/menunggu.png', height: 180),
            const SizedBox(height: 20),

            const Text(
              "Belum ada dosen pembimbing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Silakan ajukan dosen pembimbing terlebih dahulu sebelum menggunakan fitur ini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AjukanDosenPage(dosen: placeholderDosen),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Ajukan Dosen",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}