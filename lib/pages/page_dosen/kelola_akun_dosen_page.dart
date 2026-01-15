import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inta301/shared/shared.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class KelolaAkunDosenPage extends StatefulWidget {
  const KelolaAkunDosenPage({super.key});

  @override
  State<KelolaAkunDosenPage> createState() => _KelolaAkunDosenPageState();
}

class _KelolaAkunDosenPageState extends State<KelolaAkunDosenPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final nikController = TextEditingController();
  final phoneController = TextEditingController();
  final bidangKeahlianController = TextEditingController();

  List<Map<String, dynamic>> prodiList = [];
  Map<String, dynamic>? selectedProdi;
  XFile? _pickedImage;
  String? _currentPhotoUrl;
  String displayName = "Nama Lengkap";
  bool isLoading = true;
  bool isUpdating = false;
  bool isLoadingProdi = true;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    nameController.addListener(() {
      setState(() {
        displayName = nameController.text.isNotEmpty 
            ? nameController.text 
            : "Nama Lengkap";
      });
    });
    
    _initializeData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    nikController.dispose();
    phoneController.dispose();
    bidangKeahlianController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadProgramStudi();
    await _loadProfile();
  }

  Future<void> _loadProgramStudi() async {
    setState(() => isLoadingProdi = true);

    try {
      print("🔄 Loading program studi...");
      final prodi = await AuthService.getProgramStudi();

      setState(() {
        prodiList = prodi;
        isLoadingProdi = false;
      });

      print("✅ Program studi loaded: ${prodiList.length} items");
    } catch (e) {
      print("❌ Error loading prodi: $e");
      setState(() => isLoadingProdi = false);
      _showErrorSnackbar("Gagal memuat data program studi: $e");
    }
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);

    try {
      print("🔄 Loading profile dosen...");
      final result = await AuthService.getDosenProfile();

      print("Profile result: $result");

      if (result['success'] == true) {
        final data = result['data'];

        print("Profile data: $data");

        setState(() {
          nameController.text = data['nama_lengkap'] ?? '';
          displayName = data['nama_lengkap'] ?? 'Nama Lengkap';
          emailController.text = data['email'] ?? '';
          nikController.text = data['nik'] ?? '';
          phoneController.text = data['no_telepon'] ?? '';
          bidangKeahlianController.text = data['bidang_keahlian'] ?? '';
          _currentPhotoUrl = data['foto_profil'];

          print("📸 Foto URL: $_currentPhotoUrl");
          print("👤 Nama: ${nameController.text}");
          print("📧 Email: ${emailController.text}");
          print("🆔 NIK: ${nikController.text}");
          print("📞 Telepon: ${phoneController.text}");
          print("🏫 Prodi ID: ${data['prodi_id']}");

          if (data['prodi_id'] != null && prodiList.isNotEmpty) {
            try {
              selectedProdi = prodiList.firstWhere(
                (p) => p['id'] == data['prodi_id'],
              );
              print("✅ Selected prodi: ${selectedProdi!['nama_program_studi']}");
            } catch (e) {
              print("⚠️ Prodi ID ${data['prodi_id']} tidak ditemukan di list");
              selectedProdi = null;
            }
          }
        });

        print("✅ Profile loaded successfully");
      } else {
        print("❌ Profile load failed: ${result['message']}");
        _showErrorSnackbar(result['message'] ?? 'Gagal memuat profil');
      }
    } catch (e) {
      print("❌ Error loading profile: $e");
      _showErrorSnackbar('Terjadi kesalahan: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
        print("✅ Foto dipilih: ${pickedFile.name}");
      }
    } catch (e) {
      _showErrorSnackbar('Gagal memilih foto: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedProdi == null) {
      _showErrorSnackbar('Pilih program studi terlebih dahulu');
      return;
    }

    setState(() => isUpdating = true);

    try {
      print("🔄 Updating profile dosen...");
      print("📸 Foto: ${_pickedImage?.name ?? 'tidak ada'}");
      
      final result = await AuthService.updateProfilDosen(
        nama_lengkap: nameController.text.trim(),
        email: emailController.text.trim(),
        prodi_id: selectedProdi!['id'],
        nik: nikController.text.trim(),
        no_telepon: phoneController.text.trim(),
        bidang_keahlian: bidangKeahlianController.text.trim(),
        fotoProfil: _pickedImage,
      );

      if (result['success'] == true) {
        _showSuccessSnackbar(result['message'] ?? 'Profil berhasil diperbarui');
        await Future.delayed(const Duration(seconds: 1));
        Get.back(result: true);
      } else {
        _showErrorSnackbar(result['message'] ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      print("❌ Error: $e");
      _showErrorSnackbar('Terjadi kesalahan: $e');
    } finally {
      setState(() => isUpdating = false);
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Nama Lengkap"),
                          const SizedBox(height: 6),
                          _buildTextField(
                              nameController, 'Masukkan nama lengkap'),
                          const SizedBox(height: 15),

                          _buildFieldLabel("Program Studi"),
                          const SizedBox(height: 6),
                          _buildProdiDropdown(),
                          const SizedBox(height: 15),

                          _buildFieldLabel("NIK"),
                          const SizedBox(height: 6),
                          _buildTextField(nikController, 'Masukkan NIK'),
                          const SizedBox(height: 15),

                          _buildFieldLabel("No Telepon"),
                          const SizedBox(height: 6),
                          _buildTextField(
                              phoneController, 'Masukkan nomor telepon'),
                          const SizedBox(height: 15),

                          _buildFieldLabel("Email"),
                          const SizedBox(height: 6),
                          _buildTextField(emailController, 'Masukkan email'),
                          const SizedBox(height: 15),

                          _buildFieldLabel("Bidang Keahlian"),
                          const SizedBox(height: 6),
                          _buildTextField(bidangKeahlianController,
                              'Masukkan bidang keahlian'),
                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isUpdating ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: dangerColor,
                                disabledBackgroundColor:
                                    dangerColor.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isUpdating
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Update Profile",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, dangerColor],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 26),
                ),
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 26),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: _buildProfileImage(),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            displayName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const Text(
            "Dosen",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_pickedImage != null) {
      if (kIsWeb) {
        return Image.network(
          _pickedImage!.path,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Icon(Icons.person, color: primaryColor, size: 60);
          },
        );
      } else {
        return Image.file(
          File(_pickedImage!.path),
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Icon(Icons.person, color: primaryColor, size: 60);
          },
        );
      }
    }

    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return Image.network(
        _currentPhotoUrl!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          print("Error loading image from: $_currentPhotoUrl");
          return const Icon(Icons.person, color: primaryColor, size: 60);
        },
      );
    }

    return const Icon(Icons.person, color: primaryColor, size: 60);
  }

  Widget _buildProdiDropdown() {
    return DropdownButtonFormField2<Map<String, dynamic>>(
      value: selectedProdi,
      isExpanded: true,
      hint: const Text(
        "Pilih Program Studi",
        style: TextStyle(color: Colors.black54),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF88BDF2).withOpacity(0.3),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF88BDF2).withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF88BDF2).withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF88BDF2),
            width: 1.5,
          ),
        ),
      ),
      buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 250,
        decoration: BoxDecoration(
          color: const Color(0xFFDDEEFF),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      items: prodiList
          .map((prodi) => DropdownMenuItem<Map<String, dynamic>>(
                value: prodi,
                child: Text(prodi['nama_prodi'] ?? prodi['nama_program_studi'] ?? ''),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedProdi = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Pilih program studi';
        }
        return null;
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}