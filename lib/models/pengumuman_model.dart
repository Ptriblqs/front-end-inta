class Pengumuman {
  final int id;
  final String judul;
  final String isi;
  final String? attachment;
  final String tglMulai;
  final String tglSelesai;

  Pengumuman({
    required this.id,
    required this.judul,
    required this.isi,
    this.attachment,
    required this.tglMulai,
    required this.tglSelesai,
  });

  factory Pengumuman.fromJson(Map<String, dynamic> json) {
    return Pengumuman(
      id: json['id'],
      judul: json['judul'],
      isi: json['isi'],
      attachment: json['attachment'],
      tglMulai: json['tgl_mulai'],
      tglSelesai: json['tgl_selesai'],
    );
  }
}