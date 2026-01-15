import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/dosen_model.dart';
import 'package:inta301/pages/page_mahasiswa/ajukan_dosen_page.dart';
import 'package:inta301/shared/shared.dart';

class DetailDosenPage extends StatelessWidget {
  final DosenModel dosen;

  const DetailDosenPage({super.key, required this.dosen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header gradient
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, dangerColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(
                child: Text(
                  "Pengajuan Dosen",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Foto profil dosen
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            backgroundImage: dosen.fotoProfil.isNotEmpty
                ? NetworkImage(dosen.fotoProfil)
                : null,
            child: dosen.fotoProfil.isEmpty
                ? const Icon(Icons.person, color: Colors.white, size: 60)
                : null,
          ),

          const SizedBox(height: 15),

          // Nama dosen
          Text(
            dosen.namaLengkap,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 20),

          // Informasi lengkap
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Informasi Lengkap",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  "Email : ${dosen.email}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Program Studi : ${dosen.prodi}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Bimbingan : ${dosen.bimbingan}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Tombol ajukan
          ElevatedButton(
            onPressed: () {
              Get.to(() => AjukanDosenPage(dosen: dosen));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Ajukan",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}