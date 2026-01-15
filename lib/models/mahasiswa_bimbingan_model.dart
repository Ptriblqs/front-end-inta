class MahasiswaBimbinganModel {
  final int mahasiswaId;
  final int userId;
  final String nim;
  final String namaMahasiswa;
  final String programStudi;

  MahasiswaBimbinganModel({
    required this.mahasiswaId,
    required this.userId,
    required this.nim,
    required this.namaMahasiswa,
    required this.programStudi,
  });

  factory MahasiswaBimbinganModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaBimbinganModel(
      mahasiswaId: json['mahasiswa_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nim: json['nim'] ?? '-',
      namaMahasiswa: json['nama_mahasiswa'] ?? 'Tidak Diketahui',
      programStudi: json['program_studi'] ?? '-',
    );
  }
}