import 'package:get/get.dart';
import '../../services/dokumen_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_config.dart';

class DokumenModel {
  int? id;
  String title;
  String bab;
  String description;
  String status;
  String fileName;
  String date;
  String catatanDosen;
  String fileRevisi;
  int revisi;

  DokumenModel({
    this.id,
    required this.title,
    required this.bab,
    required this.description,
    required this.status,
    required this.fileName,
    required this.date,
    this.catatanDosen = "",
    this.fileRevisi = "",
    this.revisi = 0,
  });

  factory DokumenModel.fromJson(Map<String, dynamic> json) {
    return DokumenModel(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse('${json['id']}') : null),
      title: json['judul'] ?? json['title'] ?? '',
      bab: json['bab'] ?? '',
      description: json['deskripsi'] ?? json['description'] ?? '',
      status: json['status'] ?? '',
      fileName: json['file_name'] ?? json['file'] ?? json['file_path'] ?? json['fileName'] ?? '',
      date: json['created_at'] ?? json['date'] ?? '',
      catatanDosen: json['catatan_revisi'] ?? json['catatanDosen'] ?? '',
      fileRevisi: json['file_revisi'] ?? json['file_revisi_path'] ?? json['fileRevisi'] ?? json['file_path'] ?? json['file'] ?? '',
      revisi: json['revisi'] is int
          ? json['revisi']
          : (json['revisi'] != null ? int.tryParse('${json['revisi']}') ?? 0 : 0),
    );
  }
}

class DokumenController extends GetxController {
  var menungguList = <DokumenModel>[].obs;
  var revisiList = <DokumenModel>[].obs;
  var selesaiList = <DokumenModel>[].obs;

  /// Ambil dari API dan populate list berdasarkan status
  Future<void> refresh() async {
    try {
      final resp = await DokumenService.getAllDokumen();

      List<dynamic> data = [];
      if (resp.containsKey('data') && resp['data'] is List) {
        data = resp['data'];
      } else if (resp.containsKey('dokumen') && resp['dokumen'] is List) {
        data = resp['dokumen'];
      }

      menungguList.clear();
      revisiList.clear();
      selesaiList.clear();

      for (var item in data) {
        try {
          final d = DokumenModel.fromJson(Map<String, dynamic>.from(item));
          final statusLower = d.status.toLowerCase();
          if (statusLower.contains('menunggu')) {
            menungguList.add(d);
          } else if (statusLower.contains('revisi')) {
            revisiList.add(d);
          } else {
            selesaiList.add(d);
          }
        } catch (_) {
          // skip malformed item
        }
      }
    } catch (e) {
      // ignore or notify
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Grab initial data from API
    refresh();
  }

  /// Tambah dokumen ke list sesuai status
  void addDokumen(DokumenModel d) {
    switch (d.status) {
      case "Menunggu":
        menungguList.add(d);
        break;
      case "Revisi":
        revisiList.add(d);
        break;
      default:
        selesaiList.add(d);
    }
  }

  /// Edit dokumen (hapus versi lama berdasarkan title)
  Future<void> editDokumen(DokumenModel d) async {
    // If the model contains an id, try to update via API
    if (d.id != null) {
      try {
        await DokumenService.updateDokumen(
          dokumenId: d.id!,
          judul: d.title,
          bab: d.bab,
          deskripsi: d.description,
        );
        await refresh();
        return;
      } catch (_) {
        // fallback to local update if API fails
      }
    }

    // Local update: remove any existing and re-add
    menungguList.removeWhere((e) => e.title == d.title);
    revisiList.removeWhere((e) => e.title == d.title);
    selesaiList.removeWhere((e) => e.title == d.title);
    addDokumen(d);
  }

  /// Hapus dokumen dari semua list
  Future<void> deleteDokumen(DokumenModel d) async {
    if (d.id != null) {
      try {
        await DokumenService.deleteDokumen(dokumenId: d.id!);
        await refresh();
        return;
      } catch (_) {
        // fallback to local removal
      }
    }

    menungguList.remove(d);
    revisiList.remove(d);
    selesaiList.remove(d);
  }

  Future<void> downloadDokumen(DokumenModel d) async {
  if (d.fileName.isEmpty) {
    Get.snackbar('Error', 'File tidak tersedia');
    return;
  }

  try {
    if (kIsWeb) {
      // WEB: browser memang download
      final url = '${ApiConfig.baseUrl}/storage/dokumen/${d.fileName}';
      await launchUrl(Uri.parse(url));
      return;
    }

    // MOBILE / DESKTOP
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/${d.fileName}';

    await DokumenService.downloadDokumen(
      id: d.id!,
    fileName: d.fileName,   
 );

    // 🔥 INI YANG BIKIN WORD / PDF KEBUKA
    await OpenFilex.open(savePath);

  } catch (e) {
    Get.snackbar(
      'Gagal',
      'Tidak bisa membuka dokumen',
      snackPosition: SnackPosition.TOP,
    );
  }
}
}


