import 'package:flutter/material.dart';
import 'package:inta301/shared/shared.dart';

class DokumenDosenCard extends StatelessWidget {
  final String nama;
  final String nim;
  final String jurusan;
  final VoidCallback? onTap;

  const DokumenDosenCard({
    super.key,
    required this.nama,
    required this.nim,
    required this.jurusan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryColor.withOpacity(0.12),
              child: Icon(Icons.person, color: primaryColor, size: 30),
            ),

            const SizedBox(width: 12),

            // Nama - NIM - Jurusan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nim,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    jurusan,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Arrow kanan
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black87,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
