import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:intl/intl.dart';

/// Modal ajukan bimbingan yang meniru tampilan dan validasi di `jadwal_pages.dart`.
void showAjukanBimbinganModal({
  required BuildContext context,
  /// onSubmit menerima satu Map berisi: `judul`, `tanggal`(yyyy-MM-dd), `waktu`, `lokasi`, `jenis`, `catatan`
  Function(Map<String, dynamic> data)? onSubmit,
}) {
  final TextEditingController judulCtrl = TextEditingController();
  final TextEditingController tanggalCtrl = TextEditingController();
  final TextEditingController waktuCtrl = TextEditingController();
  final TextEditingController lokasiCtrl = TextEditingController();
  final TextEditingController catatanCtrl = TextEditingController();

  String _selectedJenisBimbingan = 'offline';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (modalContext) {
      return StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Ajukan Bimbingan',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                  // Judul
_buildLabel('Judul'),
const SizedBox(height: 6),
TextField(
  controller: judulCtrl,
  decoration: _fieldDecoration(),
),
const SizedBox(height: 12),


                      // Tanggal
                      _buildLabel('Tanggal'),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(modalContext).unfocus();
                          DateTime? pickedDate = await showDatePicker(
                            context: modalContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
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
                            setModalState(() {
                              tanggalCtrl.text = DateFormat(
                                'EEEE, dd MMMM yyyy',
                                'id_ID',
                              ).format(pickedDate);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            controller: tanggalCtrl,
                            decoration: _fieldDecoration().copyWith(
                              hintText: 'Pilih tanggal bimbingan',
                              suffixIcon: Icon(
                                Icons.calendar_today_outlined,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Waktu (INPUT MANUAL - ICON DIHAPUS)
                      _buildLabel('Waktu (contoh: 10:30)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: waktuCtrl,
                        keyboardType: TextInputType.datetime,
                        decoration: _fieldDecoration(),
                      ),
                      const SizedBox(height: 12),

                      // Jenis bimbingan
                      _buildLabel('Jenis Bimbingan'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Offline'),
                              value: 'offline',
                              groupValue: _selectedJenisBimbingan,
                              onChanged: (v) => setModalState(
                                  () => _selectedJenisBimbingan = v!),
                              activeColor: primaryColor,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Online'),
                              value: 'online',
                              groupValue: _selectedJenisBimbingan,
                              onChanged: (v) => setModalState(
                                  () => _selectedJenisBimbingan = v!),
                              activeColor: primaryColor,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Lokasi / Link
                      _buildLabel(
                        _selectedJenisBimbingan == 'online'
                            ? 'Link'
                            : 'Lokasi',
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: lokasiCtrl,
                        decoration: _fieldDecoration().copyWith(
                          hintText: _selectedJenisBimbingan == 'online'
                              ? ''
                              : '',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Catatan
                      _buildLabel('Catatan (Opsional)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: catatanCtrl,
                        maxLines: 3,
                        decoration: _fieldDecoration()
                            .copyWith(hintText: ''),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Ajukan
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
                          onPressed: () {
                            if (judulCtrl.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Judul bimbingan harus diisi',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            if (tanggalCtrl.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Tanggal harus dipilih',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            if (waktuCtrl.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Waktu harus diisi',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            if (lokasiCtrl.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Lokasi harus diisi',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              return;
                            }

                            try {
                              final DateFormat inputFormat = DateFormat(
                                'EEEE, dd MMMM yyyy',
                                'id_ID',
                              );
                              final DateTime parsedDate =
                                  inputFormat.parse(tanggalCtrl.text);
                              final String formattedDate =
                                  DateFormat('yyyy-MM-dd')
                                      .format(parsedDate);

                              final timeRegex = RegExp(
                                  r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
                              if (!timeRegex
                                  .hasMatch(waktuCtrl.text.trim())) {
                                Get.snackbar(
                                  'Error',
                                  'Format waktu harus HH:mm (contoh: 10:30)',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final data = {
                                'judul': judulCtrl.text.trim(),
                                'tanggal': formattedDate,
                                'waktu': waktuCtrl.text.trim(),
                                'lokasi': lokasiCtrl.text.trim(),
                                'jenis': _selectedJenisBimbingan,
                                'catatan': catatanCtrl.text.trim().isEmpty
                                    ? null
                                    : catatanCtrl.text.trim(),
                              };

                              if (onSubmit != null) onSubmit(data);
                              Navigator.of(modalContext).pop();
                          } catch (e) {
                              Get.snackbar(
                                'Error',
                                'Gagal mengajukan jadwal: $e',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            }
                          },
                          child: const Text(
                            'Ajukan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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

InputDecoration _fieldDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: primaryColor.withOpacity(0.2),
    contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide:
          BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
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
