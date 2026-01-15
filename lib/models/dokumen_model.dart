class DokumenModel {
  final int id;
  final String title;
  final String bab;
  final String description;
  final String status;
  final String fileName;
  final String date;
  final String catatanDosen;
  final String fileRevisi;

  DokumenModel({
    required this.id,
    required this.title,
    required this.bab,
    required this.description,
    required this.status,
    required this.fileName,
    required this.date,
    this.catatanDosen = "",
    this.fileRevisi = "",
  });

  factory DokumenModel.fromJson(Map<String, dynamic> json) {
    return DokumenModel(
      id: json['id'],
      title: json['title'] ?? '',
      bab: json['bab'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'menunggu',
      fileName: json['file'] ?? json['file_path'] ?? '',
      date: json['date'] ?? '',
      catatanDosen: json['catatan_revisi'] ?? '',
      fileRevisi: json['file_revisi'] ?? json['file_revisi_path'] ?? json['file_path'] ?? json['file'] ?? '',
    );
  }
}
