class KanbanTask {
  final int? id;
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;
  final bool isExpired; // ✅ Gunakan ini saja

  KanbanTask({
    this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    this.isExpired = false,
  });

  factory KanbanTask.fromJson(Map<String, dynamic> json) {
    return KanbanTask(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      status: json['status'],
      dueDate: DateTime.parse(json['due_date']),
      isExpired: json['is_expired']  == 1 || json['is_expired'] == true, // ✅ Parse dari database
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'due_date': dueDate.toIso8601String(),
    };
  }
  

  String get formattedDueDate {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return "${dueDate.day} ${months[dueDate.month - 1]} ${dueDate.year}, ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}";
  }
}