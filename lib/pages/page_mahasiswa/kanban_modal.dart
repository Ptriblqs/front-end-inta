import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/models/kanban_task.dart';
import 'package:inta301/pages/page_mahasiswa/kanban_controller.dart';
import 'package:inta301/shared/shared.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

// Modal Add Task Kanban
void showAddKanbanModal(
  BuildContext context,
  KanbanController controller,
  String defaultColumn,
) {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueController = TextEditingController();

  String selectedColumn = defaultColumn;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Center(
                    child: Text(
                      "Tambah Task Kanban",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                 StatefulBuilder(
                    builder: (context, localSetState) {
                      return DropdownButtonFormField2<String>(
                        value: selectedColumn,
                        decoration: _fieldDecoration().copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        isExpanded: true,
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            color: Color(0xFFDDEEFF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: ["To Do", "In Progress", "Done"] // ✅ HANYA 3 STATUS
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                            .toList(),
                        onChanged: (value) {
                          localSetState(() {
                            selectedColumn = value!;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // Judul / Bab
                  const Text(
                    "Judul / Bab",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildField(controller: titleController),
                  const SizedBox(height: 15),

                  // Keterangan
                  const Text(
                    "Keterangan",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildField(controller: descriptionController, maxLines: 2),
                  const SizedBox(height: 15),

                  // Due Date
                  const Text(
                    "Due Date",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => pickDueDate(context, dueController),
                    child: AbsorbPointer(
                      child: _buildField(
                        controller: dueController,
                        hintText: "Pilih tanggal & waktu",
                        suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Tombol Tambah
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dangerColor,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (titleController.text.isEmpty ||
                            dueController.text.isEmpty) {
                          Get.snackbar(
                            "Gagal",
                            "Judul dan tanggal harus diisi!",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                       
                            borderRadius: 10,
                            margin: const EdgeInsets.all(10),
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        }

                        Navigator.pop(context);

                        await controller.addTaskWithDescription(
                          titleController.text,
                          dueController.text,
                          selectedColumn,
                          descriptionController.text,
                        );
                      },
                      child: const Text(
                        "Tambah",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Modal Edit Task Kanban
void showEditKanbanModal(
  BuildContext context,
  KanbanController controller,
  RxList<KanbanTask> tasks,
  int index,
  String column,
) {
  final task = tasks[index];

  final titleController = TextEditingController(text: task.title);
  final descriptionController = TextEditingController(text: task.description);
  final dueController = TextEditingController(text: task.formattedDueDate);

  String selectedColumn = column;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Center(
                    child: Text(
                      "Edit Task Kanban",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),

                  StatefulBuilder(
                    builder: (context, localSetState) {
                      return DropdownButtonFormField2<String>(
                        decoration: _fieldDecoration().copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        isExpanded: true,
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.zero,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            color: Color(0xFFDDEEFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: selectedColumn,
                        items: ["To Do", "In Progress", "Done"]
                            .map((item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ))
                            .toList(),
                        onChanged: (value) {
                          localSetState(() {
                            selectedColumn = value!;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  // Judul / Bab
                  const Text(
                    "Judul / Bab",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildField(controller: titleController),
                  const SizedBox(height: 15),

                  // Keterangan
                  const Text(
                    "Keterangan",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _buildField(controller: descriptionController, maxLines: 2),
                  const SizedBox(height: 15),

                  // Due Date
                  const Text(
                    "Due Date",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => pickDueDate(context, dueController),
                    child: AbsorbPointer(
                      child: _buildField(
                        controller: dueController,
                        hintText: "Pilih tanggal & waktu",
                        suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
                      ),
                    ),
                  ),


                  const SizedBox(height: 25),

                  // Tombol Hapus dan Simpan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dangerColor,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await controller.deleteTask(tasks, index);
                            },
                            child: const Text(
                              "Hapus",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (titleController.text.isEmpty ||
                                  dueController.text.isEmpty) {
                                Get.snackbar(
                                  "Gagal",
                                  "Judul dan tanggal harus diisi!",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.TOP,
                                
                                  borderRadius: 10,
                                  margin: const EdgeInsets.all(10),
                                  duration: const Duration(seconds: 2),
                                );
                                return;
                              }

                              Navigator.pop(context);

                              await controller.updateTaskWithDescription(
                                tasks,
                                index,
                                titleController.text,
                                dueController.text,
                                descriptionController.text,
                                column,
                                selectedColumn,
                              );
                            },
                            child: const Text(
                              "Simpan",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// FIELD DECORATION
InputDecoration _fieldDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: primaryColor.withOpacity(0.2),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: primaryColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: primaryColor.withOpacity(0.3),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: primaryColor,
        width: 1.5,
      ),
    ),
  );
}

// ✅ DENGAN VALIDASI - To Do tidak bisa tanggal lampau
Future<void> pickDueDate(BuildContext context, TextEditingController controller) async {
  DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(), // ✅ HANYA BISA PILIH HARI INI DAN SETELAHNYA
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (date == null) return;

  TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          timePickerTheme: TimePickerThemeData(
            dialHandColor: primaryColor,
            dialBackgroundColor: primaryColor.withOpacity(0.1),
            hourMinuteColor: primaryColor.withOpacity(0.1),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (time == null) return;

  DateTime finalDate = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  // ✅ VALIDASI: Tanggal tidak boleh di masa lampau
  if (finalDate.isBefore(DateTime.now())) {
    Get.snackbar(
      "Error",
      "Tanggal tidak boleh di masa lampau!",
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
 
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
    );
    return;
  }

  String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(finalDate);
  controller.text = formatted;
}

// FIELD INPUT
Widget _buildField({
  required TextEditingController controller,
  String? hintText,
  int maxLines = 1,
  Widget? suffixIcon,
}) {
   return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: _fieldDecoration().copyWith(
      hintText: hintText,
      suffixIcon: suffixIcon, // ← tambahan
    ),
  );
}

Future<void> pickDateTime(
  BuildContext context,
  TextEditingController controller,
) async {

  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2035),
  );

  if (date == null) return;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time == null) return;

  final finalDateTime = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  controller.text = formatDateTime(finalDateTime);
}
String formatDateTime(DateTime dt) {
  return "${dt.day}/${dt.month}/${dt.year} "
      "${dt.hour.toString().padLeft(2,'0')}:"
      "${dt.minute.toString().padLeft(2,'0')}";
}

Widget buildDateField(BuildContext context, TextEditingController controller) {
  return GestureDetector(
    onTap: () async {
      FocusScope.of(context).unfocus();
      await pickDateTime(context, controller);
    },
    child: AbsorbPointer(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Pilih tanggal & waktu",
          filled: true,
          fillColor: Colors.blue.shade50,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Icon(
            Icons.calendar_month,
            color: Colors.grey,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    ),
  );
}
