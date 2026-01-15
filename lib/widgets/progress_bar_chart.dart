import 'package:flutter/material.dart';
import 'package:inta301/services/dokumen_service.dart';
import 'package:inta301/shared/shared.dart';

class ProgressBarChart extends StatelessWidget {
  const ProgressBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DokumenService.getProgress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat progress: ${snapshot.error}'));
        }

        final data = snapshot.data;
        if (data == null || data['success'] != true) {
          return const Center(child: Text('Data progress tidak tersedia'));
        }

        final overallNum = data['data']?['overall_percent'];
        final overall = (overallNum is num) ? overallNum.toDouble() : 0.0;

        final barColor = overall >= 75
            ? Colors.green
            : overall >= 40
                ? Colors.orange
                : Colors.red;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Progres Tugas Akhir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: dangerColor)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Overall', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('${overall.toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final innerWidth = (overall.clamp(0, 100) / 100) * width;
                return Stack(
                  children: [
                    Container(
                      width: width,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: innerWidth,
                      height: 18,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
