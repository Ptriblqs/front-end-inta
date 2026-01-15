import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../models/kanban_task.dart';
import '../../services/kanban_service.dart';

class KanbanController extends GetxController {
  var todoTasks = <KanbanTask>[].obs;
  var inProgressTasks = <KanbanTask>[].obs;
  var doneTasks = <KanbanTask>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTasks();
    _checkExpiredTasks();
  }

Future<void> fetchAllTasks() async {
  try {
    isLoading.value = true;
    final tasks = await KanbanService.fetchTasks(); // rethrow error dari service
  
    todoTasks.value = tasks['todo'] ?? [];
    inProgressTasks.value = tasks['in_progress'] ?? [];
    doneTasks.value = tasks['done'] ?? [];
    

    isLoading.value = false;
  } catch (e) {
    isLoading.value = false;
  
    Get.snackbar(
      "Error",
      "Gagal memuat data: $e",
      backgroundColor: Colors.red,
      colorText: Colors.white,
   
      snackPosition: SnackPosition.TOP,
      borderRadius: 10,
      margin: const EdgeInsets.all(10),
    );
  }
}


  Future<void> addTaskWithDescription(
    String title,
    String dueDate,
    String column,
    String description,
  ) async {
    try {
      final parsedDate = _parseIndonesianDate(dueDate);

      if (parsedDate == null) {
        Get.snackbar(
          "Error",
          "Format tanggal tidak valid",
          backgroundColor: Colors.red,
          colorText: Colors.white,
  
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final newTask = KanbanTask(
        title: title,
        description: description,
        status: column,
        dueDate: parsedDate,
      );

      final result = await KanbanService.createTask(newTask);

      if (result['success'] == true) {
        await fetchAllTasks();

        Get.snackbar(
          "Berhasil",
          "Task berhasil ditambahkan ke $column!",
          backgroundColor: Colors.green,
          colorText: Colors.white,

          snackPosition: SnackPosition.TOP,
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "Gagal",
          result['message'] ?? "Gagal menambahkan task",
          backgroundColor: Colors.red,
          colorText: Colors.white,
       
          snackPosition: SnackPosition.TOP,
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
     
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> updateTaskWithDescription(
    RxList<KanbanTask> oldColumnTasks,
    int index,
    String newTitle,
    String newDue,
    String newDescription,
    String oldColumn,
    String newColumn,
  ) async {
    try {
      final task = oldColumnTasks[index];

      if (task.id == null) {
        Get.snackbar("Error", "Task ID tidak valid");
        return;
      }

      final parsedDate = _parseIndonesianDate(newDue);

      if (parsedDate == null) {
        Get.snackbar(
          "Error",
          "Format tanggal tidak valid",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final updatedTask = KanbanTask(
        id: task.id,
        title: newTitle,
        description: newDescription,
        status: newColumn,
        dueDate: parsedDate,
      );

      final result = await KanbanService.updateTask(task.id!, updatedTask);

      if (result['success'] == true) {
        await fetchAllTasks();

        String message = oldColumn != newColumn
            ? "Task berhasil diupdate dan dipindahkan ke $newColumn!"
            : "Task berhasil diupdate!";

        Get.snackbar(
          "Berhasil",
          message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
   
          snackPosition: SnackPosition.TOP,
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "Gagal",
          result['message'] ?? "Gagal mengupdate task",
          backgroundColor: Colors.red,
          colorText: Colors.white,
      
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteTask(RxList<KanbanTask> columnTasks, int index) async {
    try {
      final task = columnTasks[index];

      if (task.id == null) {
        Get.snackbar("Error", "Task ID tidak valid");
        return;
      }

      final result = await KanbanService.deleteTask(task.id!);

      if (result['success'] == true) {
        await fetchAllTasks();

        Get.snackbar(
          "Berhasil",
          "Task berhasil dihapus!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
     
          snackPosition: SnackPosition.TOP,
          borderRadius: 10,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "Gagal",
          result['message'] ?? "Gagal menghapus task",
          backgroundColor: Colors.red,
          colorText: Colors.white,
       
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _checkExpiredTasks() {
    Future.delayed(const Duration(seconds: 30), () {
      fetchAllTasks();
      _checkExpiredTasks();
    });
  }

  // 🔥 UPDATED: Format lengkap, support ISO + Indonesia
  DateTime? _parseIndonesianDate(String dateStr) {
    // 1️⃣ Format dari DatePicker → yyyy-MM-dd HH:mm:ss
    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateStr);
    } catch (_) {}

    // 2️⃣ Format yyyy-MM-dd HH:mm (tanpa detik)
    try {
      return DateFormat("yyyy-MM-dd HH:mm").parse(dateStr);
    } catch (_) {}

    // 3️⃣ Format Indonesia
    final formats = [
      DateFormat('d MMMM yyyy, HH:mm', 'id_ID'),
      DateFormat('dd MMMM yyyy, HH:mm', 'id_ID'),
      DateFormat('d MMM yyyy, HH:mm', 'id_ID'),
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID'),
    ];

    for (var format in formats) {
      try {
        return format.parse(dateStr);
      } catch (_) {}
    }

    return null;
  }
}
