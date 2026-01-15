import 'package:flutter/material.dart';
import 'package:inta301/models/kanban_task.dart';
import 'package:inta301/shared/shared.dart';

class KanbanCard extends StatelessWidget {
  final KanbanTask task;

  const KanbanCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ✅ HAPUS border merah
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Title
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: dangerColor,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Description
            if (task.description.isNotEmpty) ...[
              Text(
                "Keterangan : ${task.description}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  height: 1.4,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
            ],

            // ✅ Due Date & Label Terlambat (dalam 1 baris)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Due Date di kiri
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 15,
                      color: task.isExpired ? Colors.red : Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Due: ${task.formattedDueDate}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: task.isExpired ? Colors.red : Colors.black,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),

                // ✅ Label TERLAMBAT di kanan bawah
                if (task.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "TERLAMBAT",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}