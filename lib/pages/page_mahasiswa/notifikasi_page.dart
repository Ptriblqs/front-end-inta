import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:inta301/services/notifikasi_service.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
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

  Future<void> _deleteNotification(int notificationId, int index) async {
    final result = await NotificationService.deleteNotification(notificationId);

    if (result['success'] == true) {
      setState(() {
        notifications.removeAt(index);
      });
      Get.snackbar(
        'Berhasil',
        result['message'] ?? 'Notifikasi berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Gagal',
        result['message'] ?? 'Gagal menghapus notifikasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _deleteAllNotifications() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Hapus Semua Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await NotificationService.deleteAllNotifications();
      
      if (result['success'] == true) {
        setState(() {
          notifications.clear();
        });
        Get.snackbar(
          'Berhasil',
          result['message'] ?? 'Semua notifikasi berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Gagal',
          result['message'] ?? 'Gagal menghapus notifikasi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    final result = await NotificationService.markAsRead(notificationId);
    if (result['success'] == true) {
      setState(() {
        if (index >= 0 && index < notifications.length) {
          notifications[index]['read'] = true;
        }
      });
    }
  }

  IconData _getIconByJenis(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'update':
        return Icons.update;
      case 'ajuan':
        return Icons.schedule_send_outlined;
      case 'diterima':
        return Icons.check_circle_outline;
      case 'ditolak':
        return Icons.cancel_outlined;
      case 'pengingat':
        return Icons.notifications_active_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _getTitleByJenis(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'update':
        return 'Update Terbaru';
      case 'ajuan':
        return 'Ajuan Jadwal Bimbingan';
      case 'diterima':
        return 'Ajuan Diterima';
      case 'ditolak':
        return 'Ajuan Ditolak';
      case 'pengingat':
        return 'Pengingat!';
      default:
        return 'Notifikasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
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
          actions: [
            if (notifications.isNotEmpty)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'delete_all') {
                    _deleteAllNotifications();
                  } else if (value == 'refresh') {
                    _loadNotifications();
                  } else if (value == 'mark_all_read') {
                    NotificationService.markAllAsRead().then((res) {
                      if (res['success'] == true) {
                        setState(() {
                          for (var n in notifications) {
                            n['read'] = true;
                          }
                        });
                        Get.snackbar('Berhasil', res['message'] ?? 'Semua notifikasi ditandai terbaca', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, margin: const EdgeInsets.all(16), duration: const Duration(seconds: 2));
                      } else {
                        Get.snackbar('Gagal', res['message'] ?? 'Gagal menandai semua notifikasi', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, margin: const EdgeInsets.all(16), duration: const Duration(seconds: 2));
                      }
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: primaryColor, size: 20),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read, color: primaryColor, size: 20),
                        SizedBox(width: 8),
                        Text('Tandai Terbaca'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Hapus Semua'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            : notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 100,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Notifikasi akan muncul di sini',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
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

                        return Dismissible(
                          key: Key(notif['id'].toString()),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await Get.dialog<bool>(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: const Text(
                                  'Hapus Notifikasi',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Apakah Anda yakin ingin menghapus notifikasi ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Get.back(result: true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, color: Colors.white, size: 30),
                                SizedBox(height: 4),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteNotification(notif['id'], index);
                          },
                          child: InkWell(
                            onTap: () => _markAsRead(notif['id'], index),
                            child: _buildNotificationItem(
                              icon: _getIconByJenis(notif["jenis"] ?? ""),
                              title: _getTitleByJenis(notif["jenis"] ?? ""),
                              message: notif["pesan"] ?? "",
                              time: notif["waktu"] ?? "",
                              isRead: notif['read'] == true,
                            ),
                          ),
                        );
                      },
                    ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isRead ? 0.08 : 0.2),
            blurRadius: isRead ? 4 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dangerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: dangerColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isRead ? Colors.grey[800] : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: isRead ? Colors.grey[700] : Colors.grey[800],
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
