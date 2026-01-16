class Pengumuman {
  final int id;
  final String judul;
  final String isi;
  final String? attachment;
  final String? attachmentName; // ← TAMBAHKAN INI
  final String tglMulai;
  final String tglSelesai;

  Pengumuman({
    required this.id,
    required this.judul,
    required this.isi,
    this.attachment,
    this.attachmentName, // ← TAMBAHKAN INI
    required this.tglMulai,
    required this.tglSelesai,
  });

  factory Pengumuman.fromJson(Map<String, dynamic> json) {
    return Pengumuman(
      id: json['id'],
      judul: json['judul'],
      isi: json['isi'],
      attachment: json['attachment'],
      attachmentName: json['attachment_name'], // ← TAMBAHKAN INI
      tglMulai: json['tgl_mulai'],
      tglSelesai: json['tgl_selesai'],
    );
  }
}