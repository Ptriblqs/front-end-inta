class DosenModel {
final int id;
final String namaLengkap;
final String email;
final String bidang_keahlian; // tambahan baru
final String program_studi; // versi lama
final String fotoProfil;
final int kuota; // versi lama

// Versi pengajuan dosen pembimbing
final String prodi; // bisa sama dengan program_studi
final String bimbingan; // contoh: "5 dari 10 Mahasiswa"
final int jumlahBimbingan;
final int maksimalBimbingan;

DosenModel({
required this.id,
required this.namaLengkap,
required this.email,
required this.program_studi,
required this.fotoProfil,
required this.bidang_keahlian,
required this.kuota,
required this.prodi,
required this.bimbingan,
required this.jumlahBimbingan,
required this.maksimalBimbingan,
});

// Parse dari JSON/Map
factory DosenModel.fromJson(Map<String, dynamic> json) {
return DosenModel(
id: json['id'] ?? 0,
namaLengkap: json['nama_lengkap'] ?? "-",
email: json['email'] ?? "-",
fotoProfil: json['foto_profil'] ?? "",
program_studi: json['program_studi'] ?? "-",
kuota: json['kuota'] ?? 0,
bidang_keahlian: json['bidang_keahlian'] ?? json['bidangKeahlian'] ?? "-",

  // Untuk pengajuan dosen pembimbing
  prodi: json['prodi'] ?? (json['program_studi'] ?? "-"),
  bimbingan: json['bimbingan'] ?? "0 dari ${json['maksimal_bimbingan'] ?? 10} Mahasiswa",
  jumlahBimbingan: json['jumlah_bimbingan'] ?? 0,
  maksimalBimbingan: json['maksimal_bimbingan'] ?? 10,
);
}

// Convert ke JSON/Map
Map<String, dynamic> toJson() {
return {
'id': id,
'nama_lengkap': namaLengkap,
'email': email,
'program_studi': program_studi,
'foto_profil': fotoProfil,
'kuota': kuota,
'prodi': prodi,
'bimbingan': bimbingan,
'jumlah_bimbingan': jumlahBimbingan,
'maksimal_bimbingan': maksimalBimbingan,
'bidang_keahlian': bidang_keahlian,
};
}

// Check apakah dosen masih bisa menerima mahasiswa
bool get masihBisaMenerima => jumlahBimbingan < maksimalBimbingan;
}
