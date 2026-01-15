import 'package:flutter/material.dart';
import 'package:inta301/shared/shared.dart';

class JadwalCard extends StatelessWidget {
  final String title;
  final String mahasiswa;
  final String tanggal;
  final String waktu;
  final String lokasi;

  const JadwalCard({
    super.key,
    required this.title,
    required this.mahasiswa,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // jarak antar card
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          // 🔹 Shadow lebih jelas & lembut
          BoxShadow(
            color: Colors.grey.withOpacity(0.35),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Judul (misal: Bimbingan BAB 1)
          Text(
            title,
            style: const TextStyle(
              color: dangerColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 Mahasiswa
          Text(
            "Nama: $mahasiswa",
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),

          // 🔹 Tanggal
          Text(
            "Tanggal: $tanggal",
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),

          // 🔹 Waktu
          Text(
            "Waktu: $waktu",
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),

          // 🔹 Lokasi
          Text(
            "Tempat: $lokasi",
            style: const TextStyle(
              fontSize: 14.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
