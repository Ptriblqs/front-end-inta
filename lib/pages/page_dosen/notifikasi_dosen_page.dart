import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/services/notifikasi_service.dart';
class NotifikasiDosenPage extends StatefulWidget {
  const NotifikasiDosenPage({super.key});

  @override
  State<NotifikasiDosenPage> createState() => _NotifikasiDosenPageState();
}

class _NotifikasiDosenPageState extends State<NotifikasiDosenPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    final data = await NotificationService.fetchNotifications();
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'ajuan':
        return Icons.schedule_send_outlined;
      case 'diterima':
        return Icons.check_circle_outline;
      case 'ditolak':
        return Icons.cancel_outlined;
      case 'update':
        return Icons.upload_file_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Future<void> _markAsRead(int id, int index) async {
    final res = await NotificationService.markAsRead(id);
    if (res['success'] == true) {
      setState(() {
        if (index >= 0 && index < notifications.length) {
          notifications[index]['read'] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, dangerColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 100, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Belum ada notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return GestureDetector(
                        onTap: () => _markAsRead(notif['id'], index),
                        child: _buildNotificationItem(
                          icon: _iconForType((notif['jenis'] ?? '').toString()),
                          title: notif['jenis'] ?? 'Notifikasi',
                          message: notif['pesan'] ?? '',
                          time: notif['waktu'] ?? '',
                          isRead: notif['read'] == true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    bool isRead = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isRead ? 0.08 : 0.35),
            blurRadius: isRead ? 4 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: dangerColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: dangerColor, size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isRead ? Colors.grey[800] : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: isRead ? Colors.grey[700] : Colors.black,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF616161),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
