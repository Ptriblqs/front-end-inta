import 'package:flutter/material.dart';
import 'package:inta301/shared/shared.dart';

class MahasiswaCard extends StatelessWidget {
  final String nama;
  final String nim;
  final String prodi;
  final VoidCallback? onAjukanBimbingan;

  const MahasiswaCard({
    super.key,
    required this.nama,
    required this.nim,
    required this.prodi,
    this.onAjukanBimbingan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          CircleAvatar(
            radius: 26,
            backgroundColor: primaryColor.withOpacity(0.12),
            child: Icon(Icons.person, color: primaryColor, size: 30),
          ),
          const SizedBox(width: 12),
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
                  prodi,
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
          if (onAjukanBimbingan != null)
            ElevatedButton(
              onPressed: onAjukanBimbingan,
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(60, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                "Ajukan\nBimbingan",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                  height: 1.1,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
