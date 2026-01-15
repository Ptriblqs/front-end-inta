import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:inta301/shared/shared.dart';
import 'package:inta301/routes/app_pages.dart';
import 'package:inta301/services/bimbingan_service.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final BimbinganService _bimbinganService = BimbinganService();
  DateTime today = DateTime.now();

  bool isLoading = true;
  bool hasDosen = false;
  List<dynamic> jadwalList = [];
  Set<DateTime> jadwalDiterimaDates = {};

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  String _selectedJenisBimbingan = 'offline';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _tanggalController.dispose();
    _waktuController.dispose();
    _lokasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final response = await _bimbinganService.getJadwalMahasiswa();

      print('📥 Response from API: $response'); // Debug log

      if (response['success'] == true) {
        setState(() {
          // ✅ Handle null dengan default value false
          hasDosen = response['has_dosen'] ?? false;
          jadwalList = response['data'] ?? [];
        });

        print('✅ hasDosen: $hasDosen'); // Debug log
        print('✅ jadwalList: ${jadwalList.length} items'); // Debug log

        if (hasDosen) {
          await _loadKalender();
        }
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      print('❌ Error loading data: $e'); // Debug log
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadKalender() async {
    try {
      final response = await _bimbinganService.getKalenderMahasiswa();

      if (response['success'] == true) {
        setState(() {
          jadwalDiterimaDates = (response['data'] as List)
              .map((item) => DateTime.parse(item['date']))
              .toSet();
        });
      }
    } catch (e) {
      print('❌ Error loading kalender: $e');
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  void _showTambahJadwalModal(BuildContext context) {
    final BuildContext pageContext = context;
    _judulController.clear();
    _tanggalController.clear();
    _waktuController.clear();
    _lokasiController.clear();
    _catatanController.clear();
    _selectedJenisBimbingan = 'offline';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
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
                        const SizedBox(height: 8),
                        // Restored: Judul dan Tanggal agar form valid
                        _buildLabel("Judul"),
                        _buildField(_judulController, ""),
                        const SizedBox(height: 15),
                        _buildLabel("Tanggal"),
                        _buildDatePicker(modalContext, setModalState),
                        const SizedBox(height: 15),
                        _buildLabel("Waktu (contoh: 10:30)"),
                        _buildField(_waktuController, ""),
                        const SizedBox(height: 15),
                        _buildLabel("Jenis Bimbingan"),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Offline',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                value: 'offline',
                                groupValue: _selectedJenisBimbingan,
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedJenisBimbingan = value!;
                                  });
                                },
                                activeColor: primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Online',
                                  style: TextStyle(fontFamily: 'Poppins'),
                                ),
                                value: 'online',
                                groupValue: _selectedJenisBimbingan,
                                onChanged: (value) {
                                  setModalState(() {
                                    _selectedJenisBimbingan = value!;
                                  });
                                },
                                activeColor: primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        _buildLabel("Lokasi"),
                        _buildField(
                          _lokasiController,
                          _selectedJenisBimbingan == 'online'
                              ? ""
                              : "",
                        ),
                        const SizedBox(height: 15),
                        _buildLabel("Catatan (Opsional)"),
                        _buildField(
                          _catatanController,
                          "",
                          maxLines: 3,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dangerColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _submitJadwal(pageContext),
                            child: const Text(
                              "Ajukan",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: 'Poppins',
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
      },
    );
  }

  Future<void> _submitJadwal([BuildContext? rootContext]) async {
    // Validasi
  if (_judulController.text.trim().isEmpty) {
  const msg = 'Judul bimbingan harus diisi';

  Get.snackbar(
    "",
    "",
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    titleText: const Text(
      "Gagal",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: const Text(
      msg,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );

  return;
}

   if (_tanggalController.text.isEmpty) {
  const msg = 'Tanggal harus dipilih';

  Get.snackbar(
    "",
    "",
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    titleText: const Text(
      "Gagal",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: const Text(
      msg,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );

  return;
}

    if (_waktuController.text.trim().isEmpty) {
  const msg = 'Waktu harus diisi';

  Get.snackbar(
    "",
    "",
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    titleText: const Text(
      "Gagal",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: const Text(
      msg,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );

  return;
}

   if (_lokasiController.text.trim().isEmpty) {
  const msg = 'Lokasi harus diisi';

  Get.snackbar(
    "",
    "",
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    titleText: const Text(
      "Gagal",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: const Text(
      msg,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );

  return;
}


    try {
      // Parse tanggal
      final DateFormat inputFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
      final DateTime parsedDate = inputFormat.parse(_tanggalController.text);
      final String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      // Validasi waktu
      final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
      if (!timeRegex.hasMatch(_waktuController.text.trim())) {
        final msg = 'Format waktu harus HH:mm (contoh: 10:30)';
        if (rootContext != null) {
          ScaffoldMessenger.of(rootContext).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red[100],
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          Get.snackbar('Error', msg);
        }
        return;
      }

      // Debug log
      print('📤 Submitting jadwal...');
      print('Judul: ${_judulController.text.trim()}');
      print('Tanggal: $formattedDate');
      print('Waktu: ${_waktuController.text.trim()}');
      print('Lokasi: ${_lokasiController.text.trim()}');
      print('Jenis: $_selectedJenisBimbingan');
      print('Catatan: ${_catatanController.text.trim()}');

      final response = await _bimbinganService.ajukanBimbinganMahasiswa(
        judul: _judulController.text.trim(),
        tanggal: formattedDate,
        waktu: _waktuController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        jenisBimbingan: _selectedJenisBimbingan,
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );

      print('📥 Response: $response'); // Debug log

      if (response['success'] == true) {
        Get.back(); // Tutup modal
        final msg = response['message'] ?? 'Jadwal bimbingan berhasil diajukan';
        Get.snackbar(
  "",
  "",
  backgroundColor: Colors.green,
  snackPosition: SnackPosition.TOP,
  margin: const EdgeInsets.all(16),
  duration: const Duration(seconds: 3),
  titleText: const Text(
    "Berhasil",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  messageText: Text(
    msg,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
  ),
);

        await _loadData(); // Reload data
     } else {
  final msg = response['message'] ?? 'Gagal mengajukan jadwal';

  Get.snackbar(
    "",
    "",
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    titleText: const Text(
      "Gagal",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: Text(
      msg,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );
}

    } catch (e) {
  print('❌ Error: $e'); // Debug log
  final msg = 'Gagal mengajukan jadwal: $e';

  Get.snackbar(
    "",
    "",
    backgroundColor: Colors.red,
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(16),
    titleText: const Text(
      "Gagal",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: Text(
      msg,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );
    }
  }


  Widget _buildDatePicker(BuildContext modalContext, StateSetter setModalState) {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(modalContext).unfocus();
        DateTime? pickedDate = await showDatePicker(
          context: modalContext,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
          locale: const Locale('id', 'ID'),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          // ✅ Gunakan setModalState untuk update UI di modal
          setModalState(() {
            _tanggalController.text = DateFormat(
              'EEEE, dd MMMM yyyy',
              'id_ID',
            ).format(pickedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: _tanggalController,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
          decoration: _fieldDecoration().copyWith(
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              color: primaryColor,
            ),
          
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: primaryColor.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      decoration: _fieldDecoration().copyWith(hintText: hint),
    );
  }

  Widget _buildJadwalCard(Map<String, dynamic> item) {
    final status = (item["status"] ?? "Menunggu").toString();
    final statusLower = status.toLowerCase();
    Color statusColor;

    if (statusLower.contains('diterima') || statusLower.contains('disetujui') || statusLower.contains('dijadwalkan')) {
      statusColor = Colors.green;
    } else if (statusLower.contains('ditolak')) {
      statusColor = Colors.red;
    } else if (statusLower.contains('menunggu')) {
      statusColor = Colors.blueAccent;
    } else if (statusLower.contains('ajuan') && statusLower.contains('dosen')) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    final bool isAjuanDosen = statusLower.contains('ajuan') && statusLower.contains('dosen');
    final bool isPengajuDosen = (item['pengaju'] ?? '').toString().toLowerCase() == 'dosen';

    return GestureDetector(
      onTap: () {
        final s = (item['status'] ?? '').toString().toLowerCase();
        final bool isPengajuDosen = (item['pengaju'] ?? '').toString().toLowerCase() == 'dosen';
        final int id = (item['id'] ?? item['jadwalId']) is int
            ? (item['id'] ?? item['jadwalId'])
            : int.parse((item['id'] ?? item['jadwalId']).toString());

        if (s.contains('diterima') || s.contains('disetujui') || s.contains('dijadwalkan')) {
          // Jika sudah diterima -> buka detail
          Get.toNamed(
            Routes.FORM_JADWAL,
            arguments: {"jadwalId": id},
          )?.then((_) => _loadData());
          return;
        }

        // Jika pengaju adalah dosen dan masih menunggu, tampilkan modal detail + aksi
        if (isPengajuDosen && s.contains('menunggu')) {
          _showDosenAjuanDetail(item);
          return;
        }

        // Fallback untuk ajuan bertipe khusus
        if (isAjuanDosen) {
          _showAjuanDialog(item);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isAjuanDosen
              ? Border.all(color: Colors.orange, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item["judul"] ?? "-",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      fontFamily: 'Poppins',
                      color: dangerColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (isPengajuDosen)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 12, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text(
                              'Dosen',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${item["tanggal"] ?? "-"} | ${item["waktu"] ?? "-"}",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item["lokasi"] ?? "-",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (isAjuanDosen)
  Row(
    children: [
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _acceptAjuan(item),
          child: const Text(
            'Setuju',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _rejectAjuan(item),
          child: const Text(
            'Tolak',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
  )
          ],
        ),
      ),
    );
  }

  Future<void> _acceptAjuan(Map<String, dynamic> item) async {
    final int id = (item['id'] ?? item['jadwalId']) is int
        ? (item['id'] ?? item['jadwalId'])
        : int.parse((item['id'] ?? item['jadwalId']).toString());

    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: primaryColor)),
    );

    try {
      final response = await _bimbinganService.terimaAjuanMahasiswa(id);
      Navigator.of(context).pop(); // close loading

      if (response['success'] == true) {
        Get.snackbar('Berhasil', response['message'] ?? 'Jadwal disetujui',
            backgroundColor: Colors.green, colorText: Colors.white);
        await _loadData();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Gagal menyetujui',
            backgroundColor: Colors.red[100], colorText: Colors.red[900]);
      }
    } catch (e) {
      Navigator.of(context).pop();
      Get.snackbar('Error', 'Gagal: $e', backgroundColor: Colors.red[100]);
    }
  }

 Future<void> _rejectAjuan(Map<String, dynamic> item) async {
  final TextEditingController alasanController = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
     barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Tolak Ajuan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 17,
          ),
        ),
        content: TextField(
          controller: alasanController,
          maxLines: 4,
          decoration:
           InputDecoration(
            hintText: 'Masukkan alasan penolakan',
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (alasanController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Alasan harus diisi',
                  backgroundColor: Colors.red,
                  colorText: Colors.white
                );
                return;
              }
              Navigator.of(ctx).pop(true);
            },
            child: const Text(
              'Tolak',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );

  // ⬇⬇⬇ INI HARUS DI LUAR showDialog ⬇⬇⬇
  if (result != true) return;

  final alasan = alasanController.text.trim();
  final int id = (item['id'] ?? item['jadwalId']) is int
      ? (item['id'] ?? item['jadwalId'])
      : int.parse((item['id'] ?? item['jadwalId']).toString());

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: primaryColor),
    ),
  );

  try {
    final response = await _bimbinganService.tolakAjuanMahasiswa(id, alasan);
    Navigator.of(context).pop();

    if (response['success'] == true) {
      Get.snackbar(
        'Berhasil',
        response['message'] ?? 'Ajuan ditolak',
        backgroundColor: Colors.green,
        colorText: Colors.white,  
      );
      await _loadData();
    } else {
      Get.snackbar(
        'Error',
        response['message'] ?? 'Gagal menolak',
        backgroundColor: Colors.red[100],
      );
    }
  } catch (e) {
    Navigator.of(context).pop();
    Get.snackbar(
      'Error',
      'Gagal: $e',
      backgroundColor: Colors.red[100],
    );
  }
}


  void _showAjuanDialog(Map<String, dynamic> item) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ajuan Dosen', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda ingin menerima atau menolak ajuan jadwal ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _rejectAjuan(item);
              },
              child: const Text('Tolak', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(ctx).pop();
                _acceptAjuan(item);
              },
              child: const Text('Setuju'),
            ),
          ],
        );
      },
    );
  }

  void _showDosenAjuanDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (ctx, scrollController) {
            final String judul = item['judul'] ?? '-';
            final String tanggal = item['tanggal'] ?? '-';
            final String waktu = item['waktu'] ?? '-';
            final String lokasi = item['lokasi'] ?? '-';
            final String catatan = item['catatan'] ?? '';

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                      child: Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(height: 12),
                    Text(judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    Text('Tanggal: $tanggal', style: const TextStyle(fontFamily: 'Poppins')),
                    const SizedBox(height: 6),
                    Text('Waktu: $waktu', style: const TextStyle(fontFamily: 'Poppins')),
                    const SizedBox(height: 6),
                    Text('Lokasi: $lokasi', style: const TextStyle(fontFamily: 'Poppins')),
                    if (catatan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                      const SizedBox(height: 6),
                      Text(catatan, style: const TextStyle(fontFamily: 'Poppins')),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(modalCtx).pop();
                              _rejectAjuan(item);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white, 
                              padding: const EdgeInsets.symmetric(vertical: 14)
                              ),
                            child: const Text(
                              'Tolak', 
                              style: TextStyle(fontFamily: 'Poppins')
                              ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(modalCtx).pop();
                              _acceptAjuan(item);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14)),
                            child: const Text(
                              'Setuju', 
                              style: TextStyle(fontFamily: 'Poppins')
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

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        "Jadwal Bimbingan",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, dangerColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        bottomNavigationBar: const _BottomNavBar(),
      );
    }


    // Sembunyikan tombol 'Ajukan' jika sudah ada jadwal yang disetujui
    final bool hasAccepted = jadwalList.any((item) {
      final s = (item['status'] ?? '').toString().toLowerCase();
      return s.contains('diterima') || s.contains('disetujui') || s.contains('dijadwalkan');
    });

  
    //     appBar: _buildAppBar(),
    //     body: const Padding(
    //       padding: EdgeInsets.only(top: 100),
    //       child: Center(
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Icon(Icons.person_off, size: 80, color: Colors.grey),
    //             SizedBox(height: 20),
    //             Text(
    //               "Belum memiliki dosen pembimbing.",
    //               style: TextStyle(
    //                 fontSize: 16,
    //                 fontWeight: FontWeight.w600,
    //                 color: Color(0xFF616161),
    //                 fontFamily: 'Poppins',
    //               ),
    //             ),
    //             SizedBox(height: 10),
    //             Text(
    //               "Silakan hubungi admin untuk penugasan dosen.",
    //               textAlign: TextAlign.center,
    //               style: TextStyle(
    //                 fontSize: 13,
    //                 color: Colors.grey,
    //                 fontFamily: 'Poppins',
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     bottomNavigationBar: const _BottomNavBar(),
    //   );
    // }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TableCalendar(
                  locale: 'id_ID',
                  rowHeight: 45,
                  focusedDay: today,
                  // when user swipes or navigates months, update focusedDay
                  onPageChanged: (focusedDay) {
                    setState(() => today = focusedDay);
                  },
                  // allow swipe gestures
                  availableGestures: AvailableGestures.all,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  selectedDayPredicate: (day) => isSameDay(day, today),
                  onDaySelected: _onDaySelected,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (jadwalDiterimaDates.any((d) => isSameDay(d, date))) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: dangerColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Builder(builder: (context) {
                  if (jadwalList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Belum ada jadwal bimbingan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tekan tombol + untuk mengajukan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final acceptedList = jadwalList.where((item) {
                    final s = (item['status'] ?? '').toString().toLowerCase();
                    return s.contains('diterima') || s.contains('disetujui') || s.contains('dijadwalkan');
                  }).toList();

                  final pendingList = jadwalList.where((item) {
                    final s = (item['status'] ?? '').toString().toLowerCase();
                    return !(s.contains('diterima') || s.contains('disetujui') || s.contains('dijadwalkan'));
                  }).toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 12),
                    children: [
                      if (acceptedList.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Text('Jadwal Disetujui', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                        ...acceptedList.map((e) => _buildJadwalCard(e)).toList(),
                        const SizedBox(height: 12),
                      ],

                      if (pendingList.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Text('Sedang Diajukan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ),
                        ...pendingList.map((e) => _buildJadwalCard(e)).toList(),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahJadwalModal(context),
        backgroundColor: dangerColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// Bottom navigation bar
class _BottomNavBar extends StatefulWidget {
  const _BottomNavBar();

  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar> {
  String currentPage = Routes.JADWAL;

  void _onTap(String route) {
    if (route == currentPage) return;
    setState(() {
      currentPage = route;
    });
    Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, dangerColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.home,
            label: "Beranda",
            isActive: currentPage == Routes.home,
            onTap: () => _onTap(Routes.home),
          ),
          _BottomNavItem(
            icon: Icons.calendar_month,
            label: "Jadwal",
            isActive: currentPage == Routes.JADWAL,
            onTap: () => _onTap(Routes.JADWAL),
          ),
          _BottomNavItem(
            icon: Icons.bar_chart_outlined,
            label: "Kanban",
            isActive: currentPage == Routes.KANBAN,
            onTap: () => _onTap(Routes.KANBAN),
          ),
          _BottomNavItem(
            icon: Icons.description_outlined,
            label: "Dokumen",
            isActive: currentPage == Routes.DOKUMEN,
            onTap: () => _onTap(Routes.DOKUMEN),
          ),
          _BottomNavItem(
            icon: Icons.person_outline,
            label: "Profile",
            isActive: currentPage == Routes.PROFILE,
            onTap: () => _onTap(Routes.PROFILE),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.yellow : Colors.white, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.yellow : Colors.white,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}